#!/usr/bin/env bash

. ~/.dotfiles/.bash_prompt/colors.sh
. ~/.dotfiles/.bash_prompt/prompt_git.sh
. ~/.dotfiles/.bash_prompt/prompt_git_pretty.sh
. ~/.dotfiles/.bash_prompt/prompt_utils.sh


promptUserColor=${promptUserColor:-"\[\e[38;5;36m\]"} # x036_DarkCyan
#promptUserColor="\[\e[38;5;42m\]" # x042_SpringGreen2
#promptUserColor="\[\e[38;5;48m\]" # x048_SpringGreen1

promptRootColor=${promptRootColor:-"\[\e[38;5;124m\]"} # x124_Red3
#promptRootColor="\[\e[38;5;125m\]" # x125_DeepPink4
#promptRootColor="\[\e[38;5;160m\]" # x160_Red3

[[ "$(id -u)" -eq 0 ]] &&
    promptColor="$promptRootColor" ||
    promptColor="$promptUserColor"

# user@host:/current/path
[[ "$(id -u)" -eq 0 ]] &&
  promptBase="${promptColor}\u@${PROMPT_HOSTNAME:-\h}${whiteTxt}:${cyanTxt}\w${resetColor}" ||
  promptBase="${promptColor}\u@${PROMPT_HOSTNAME:-\h}${whiteTxt}:${blueBold}\w${resetColor}"


#promptEnd='\$ ' # $ or # if root
#promptEnd="${promptColor}❯${resetColor} " # heavy right-pointing angle quotation mark ornament
#promptEnd="${promptColor}${resetColor} " # \ue0b1 nf-pl-left_soft_divider (nerd font)
promptEnd="${promptColor}${resetColor} " # \uf054 nf-fa-chevron_circle_down (nerd font)

# default
PS1="${promptBase} ${promptEnd}"


# Pre-prompt hooks
PROMPT_COMMAND=(
  'EXIT=$?'
  prompt_window_title
  prompt_ssh_tunnels
  prompt_separator
  prompt_git
  prompt_newline
  prompt_git_dyn_graph_width

  'PS1="${promptTitle}${promptSeparator}${promptBase} ${promptGit}${promptNewline}${promptEnd}"'
)
