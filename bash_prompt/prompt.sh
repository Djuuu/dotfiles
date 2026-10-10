#!/usr/bin/env bash

## Prompt colors
# shellcheck disable=SC2034
{
    pt_black="\[\e[0;30m\]";  pt_blackBold="\[\e[1;30m\]"
    pt_red="\[\e[0;31m\]";    pt_redBold="\[\e[1;31m\]"
    pt_green="\[\e[0;32m\]";  pt_greenBold="\[\e[1;32m\]"
    pt_yellow="\[\e[0;33m\]"; pt_yellowBold="\[\e[1;33m\]"
    pt_blue="\[\e[0;34m\]";   pt_blueBold="\[\e[1;34m\]"
    pt_purple="\[\e[0;35m\]"; pt_purpleBold="\[\e[1;35m\]"
    pt_cyan="\[\e[0;36m\]";   pt_cyanBold="\[\e[1;36m\]"
    pt_white="\[\e[0;37m\]";  pt_whiteBold="\[\e[1;37m\]"
    pt_reset="\[\e[0m\]"

    c_userBlGr="\e[38;2;0;190;135m" #00BE87 custom color
    pt_userBlGr="\[${c_userBlGr}\]"
    pt_x160_Red3="\[\e[38;5;160m\]" #D70000
}

## Includes
# shellcheck source=_prompt_utils.sh
. ~/.dotfiles/bash_prompt/_prompt_utils.sh
# shellcheck source=_prompt_git.sh
. ~/.dotfiles/bash_prompt/_prompt_git.sh
# shellcheck source=_prompt_git_pretty.sh
. ~/.dotfiles/bash_prompt/_prompt_git_pretty.sh

# user vs. root color
[[ "$(id -u)" -eq 0 ]] &&
    pt_color="${promptRootColor:-${pt_x160_Red3}}" ||
    pt_color="${promptUserColor:-${pt_userBlGr}}"

# user@host:/current/path
pt_base="${pt_color}\u@${PROMPT_HOSTNAME:-\h}${pt_reset}:${pt_blueBold}\w${pt_reset}"

#pt_end='\$ ' # $ or # if root
#pt_end="${pt_color}❯${pt_reset} " # heavy right-pointing angle quotation mark ornament
pt_end="${pt_color}${pt_reset} " # \uf054 nf-fa-chevron_circle_down (nerd font)

# Semantic prompt marks (OSC 133) - prompt start, input start, output start
# https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md
pt_markPrompt='\[\e]133;A\a\]'; pt_base="${pt_markPrompt}${pt_base}" # prompt start
pt_markInput='\[\e]133;B\a\]';  pt_end="${pt_end}${pt_markInput}"    # input start
PS0='\e]133;C\a'                                                     # output start

# Mark command end (OSC 133) - only after an actual command, not on startup or empty input
prompt_mark_finished() {
    local cmdNum='\#'; cmdNum=${cmdNum@P}
    if [[ $cmdNum != "${pt_lastCmdNum:-0}" ]]; then
        printf '\e]133;D;%s\a' "$EXIT"
    fi
    pt_lastCmdNum=$cmdNum
}

# Prompt base
PS1="${pt_base} ${pt_end}"

## Pre-prompt hooks
# shellcheck disable=SC2016
PROMPT_COMMAND=(
  'EXIT=$?'
  prompt_mark_finished       # OSC 133 command end
  prompt_window_title        # ${pt_title}
  prompt_ssh_tunnels         # ${pt_sshTunnels}
  prompt_separator           # ${pt_separator}
  prompt_git                 # ${pt_git} ${pt_gitBranchInfo} ${pt_gitAction} ${pt_gitState}
  prompt_git_dyn_graph_width # git config pretty.graph-dyn*
  prompt_newline             # ${pt_newline}

  'PS1="${pt_title}${pt_separator}${pt_base} ${pt_git}${pt_newline}${pt_end}"'
)
