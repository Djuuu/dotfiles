#!/usr/bin/env bash

###################################################################################################
# https://github.com/emilis/emilis-config/blob/master/.bash_ps1

prompt_ssh_tunnels() {
  promptSshTunnels="${SSH_TUNNELS}"
  [[ $promptCheckTunnels = true ]] && promptSshTunnels="${SSH_TUNNELS:-$(ssh-list-tunnel-ports)}"
}

# Prompt separator
# Ex:
# ──────────────────────────────────┤✅ 01:23:45
# ────────────────────────[🕳️ 3128]─┤❌ 01:23:45
prompt_separator() {
    local reset='\[\e[0m\]'
    local style="${reset}\[\e[0;90m\]"
    local sep="────────────────────────────────────────────────────────────────────────────────────────────────────" # 100 chars
    local fillStock="${sep}${sep}${sep}${sep}" # 400 chars
    local end="─┤"

    # Disable separator in IDE terminals
    [[ $TERMINAL_EMULATOR == "JetBrains"* ]] && return
    [[ $TERM_PROGRAM      == "vscode"*    ]] && return

    local promptFillSize=$COLUMNS

    # Ensure new line
    local start; start="$(printf "%$((COLUMNS))s\r")"

    local tunnel
    if [[ -n $promptSshTunnels ]]; then
        if [[ -n $SSH_TUNNELS ]]; then
            tunnel="[🚇 ${promptSshTunnels}]"
            (( promptFillSize -= 1 ))
        else
            tunnel="[🕳️ ${promptSshTunnels}]"
        fi
        (( promptFillSize -= ${#tunnel} ))
    fi

    local exitIcon
    if [[ $EXIT -eq 0 ]]
        then exitIcon="✅"
        else exitIcon="❌"
        # else exitIcon="${EXIT}·❌"
    fi
    (( promptFillSize -= ${#exitIcon} + 1 ))

    local fill="${fillStock:0:$((promptFillSize - 11))}"

    # bashsupport disable=BP2001
    # shellcheck disable=SC2154,SC2034
    promptSeparator="${start}${style}${fill}${tunnel}${end}${exitIcon} \t\n${reset}"
}

###################################################################################################
# Set window title
# bashsupport disable=BP2001
# shellcheck disable=SC2034
prompt_window_title() {
  local defaultTitle="${DEFAULT_WINDOW_TITLE:-\h · \W}"
  promptTitle="\[\e]0;${FORCED_WINDOW_TITLE:-${defaultTitle}}\a\]"
}

###################################################################################################
# Send prompt sign to new line when available columns are below $PROMPT_COLUMN_LIMIT
# bashsupport disable=BP2001
# shellcheck disable=SC2034
prompt_newline() {
  promptNewline=

  [[ $COLUMNS -ge ${PROMPT_COLUMN_LIMIT:-120} ]] && return
  [[ -n "$promptGit" ]] && [[ "$promptGit" =~ "☈" ]] && return # Git rebase status already go multiline

  promptNewline=$'\n'
}

###################################################################################################
# https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
prompt_link() {
  local href=$1
  local text=$2

  # shellcheck disable=SC2028
  echo '\[\e]8;;'"${href}"'\e\\\]'"${text}"'\[\e]8;;\e\\\]'
}

###################################################################################################
# Color setting

prompt_color_index=${prompt_color_index:-0}

prompt_cycle_color() {
    local color_names=(
        "$pt_userBlGr"      # (blue green - 00BE87)
        "x038_DeepSkyBlue2" # (light blue)
        "x032_DeepSkyBlue3" # (blue)
        "x134_MediumOrchid" # (purple)
        "x212_Orchid2"      # (pink)
        "x160_Red3"         # (red)
        "x215_SandyBrown"   # (orange)
        "x220_Gold1"        # (yellow)
        "x047_SpringGreen2" # (bright green)
        "x040_Green3"       # (green)
    )

    prompt_color_index=$(((prompt_color_index + 1) % ${#color_names[@]}))
    local _name; _name=${color_names[$prompt_color_index]}
    local _value; _value=$(pColor "$_name")

    echo "promptUserColor=\"$_value\" # $_name"

    prompt_set_color "$_value"
}

prompt_set_color() {
    promptUserColor=$(pColor "${1:-$pt_userBlGr}")

    # shellcheck source=prompt.sh
    . ~/.dotfiles/bash_prompt/prompt.sh
}
