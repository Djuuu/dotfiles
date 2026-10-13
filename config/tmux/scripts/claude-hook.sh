#!/usr/bin/env bash

# Claude Code hook: reflect Claude state in tmux
#   @claude_state window option (working / waiting / done), shown in window flags
#   @claude_session window option: session owning the state (last one to receive a prompt),
#                  so that other sessions resolving to the same window leave it alone
#   "Claude finished" message when Claude stops in a background window
# Usage (Claude settings.json, for UserPromptSubmit, PreToolUse (AskUserQuestion), PostToolUse, PostToolUseFailure,
#        Notification, Stop, SessionEnd):
#   ~/.config/tmux/scripts/claude-hook.sh [--bell] [--log]
#   --bell: also ring the bell in Claude's pane on notifications needing input
#   --log:  log each event to ~/claude-hook.log
#           TMUX_CLAUDE_HOOK_LOG=true|false overrides it (unset: --log decides)
#           TMUX_CLAUDE_HOOK_LOG=debug also logs the full payload to ~/claude-hook.debug.log

icon="" # nf-cod-claude

bell=
log=
debug=

pane=
_pane_from="?"

for arg; do
    case $arg in
        --bell) bell=1 ;;
        --log) log=1 ;;
    esac
done

case $TMUX_CLAUDE_HOOK_LOG in
    true) log=1 ;;
    false) log= ;;
    debug) log=1 debug=1 ;;
esac

# Hook payload (JSON on stdin), parsed in a single jq pass;
# fields joined with \x1f: as a non-whitespace IFS, it keeps empty fields in place
input=$(cat)
IFS=$'\x1f' read -r event session_id cwd tool_name notification_type transcript_path < <(
    jq -r '[.hook_event_name, .session_id, .cwd, .tool_name, .notification_type, .transcript_path] | map(. // "") | join("\u001f")' <<<"$input"
)

# Background sessions run outside tmux (no TMUX_PANE):
# fall back to the pane running the claude front-end in the session directory
get_claude_pane() {
    if [[ -n $TMUX_PANE ]]; then
        pane=$TMUX_PANE
        _pane_from="env"
        return
    fi

    pane=$(tmux list-panes -a -F $'#{pane_id}\t#{pane_current_command}\t#{pane_current_path}' 2>/dev/null |
        awk -F '\t' -v cwd="$cwd" '$2 == "claude" && $3 == cwd { print $1; exit }')
    _pane_from="guess"
}

claim_window() {
    tmux set -w -t "$pane" @claude_session "$session_id"
}

owns_window() {
    local owner
    owner=$(tmux show -wv -t "$pane" @claude_session 2>/dev/null)
    [[ $owner == "$session_id" ]] && return 0

    if [[ -n $log ]]; then
        printf '%s %s %s %s\n' "$(date +%Y-%m-%d-%H%M%S)" "$event" "${pane:--}" "-> Ignored (owner: ${owner:--})"  \
            >>"$HOME/claude-hook.log"
    fi
    return 1
}

set_state() {
    tmux set -w -t "$pane" @claude_state "$1"
    if [[ -n $log ]]; then
        printf '%s %s %s %s\n' "$(date +%Y-%m-%d-%H%M%S)" "$event" "${pane:--}" "-> Setting @claude_state: $1"  \
            >>"$HOME/claude-hook.log"
    fi
}

unset_state() {
    tmux set -wu -t "$pane" @claude_state
    tmux set -wu -t "$pane" @claude_session
    if [[ -n $log ]]; then
        printf '%s %s %s %s\n' "$(date +%Y-%m-%d-%H%M%S)" "$event" "${pane:--}" "-> Unset @claude_state"  \
            >>"$HOME/claude-hook.log"
    fi
}

get_claude_pane

if [[ -n $log ]]; then
    printf '%s %s %s %s\n' "$(date +%Y-%m-%d-%H%M%S)" "$event" "${pane:--}" "session=$session_id tool=${tool_name:--} notification=${notification_type:--}" \
        >>"$HOME/claude-hook.log"

    if [[ -n $debug ]]; then
        printf '%s %s %s %s\n' "$(date +%Y-%m-%d-%H%M%S)" "$event" "${pane:--} (${_pane_from})" "$(jq -c . <<<"$input")" \
            >>"$HOME/claude-hook.debug.log"
    fi
fi

if [[ -z $pane ]]; then
    if [[ -n $log ]]; then
        printf '%s %s %s %s\n' "$(date +%Y-%m-%d-%H%M%S)" "$event" "${pane:--}" "-- Unknown tmux pane"  \
            >>"$HOME/claude-hook.log"
    fi
    exit 0
fi

case $event in
    UserPromptSubmit)
        claim_window
        set_state "working"
        ;;
    PostToolUse | PostToolUseFailure)
        owns_window || exit 0
        set_state "working"
        ;;
    PreToolUse | Notification)
        [[ $event == PreToolUse && $tool_name != AskUserQuestion ]] && exit 0
        [[ $event == Notification && $notification_type != @(permission_prompt|elicitation_dialog) ]] && exit 0
        owns_window || exit 0
        set_state "waiting"
        [[ -n $bell ]] && printf '\a' >"$(tmux display -p -t "$pane" '#{pane_tty}')"
        ;;
    Stop)
        owns_window || exit 0
        set_state "done"
        if [[ $(tmux display -p -t "$pane" '#{window_active}') != 1 ]]; then
            tmux display-message -d 5000 -t "$pane" \
                "#[fg=#{@thm_green}]${icon}#[default] #{window_index}:#{b:pane_current_path} Claude finished"
        fi
        ;;
    SessionEnd)
        # Experimental, might need refining: leaving Claude from the session listing ends a transient session
        # with no transcript (reason "other"), never the session owning the window, so clear regardless of owner
        [[ -f $transcript_path ]] || { unset_state; exit 0; }
        owns_window || exit 0
        unset_state
        ;;
esac

exit 0
