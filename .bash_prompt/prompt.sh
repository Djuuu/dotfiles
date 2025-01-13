#!/usr/bin/env bash

. ~/.dotfiles/.bash_prompt/colors.sh
. ~/.dotfiles/.bash_prompt/prompt_git.sh
. ~/.dotfiles/.bash_prompt/prompt_git_pretty.sh
. ~/.dotfiles/.bash_prompt/prompt_utils.sh


#promptUserColor=${promptUserColor:-$(pColor x036_DarkCyan)}     #00AF87
promptUserColor=${promptUserColor:-"\[\e[38;2;0;190;135m\]"}     #00BE87
#promptUserColor=${promptUserColor:-$(pColor x042_SpringGreen2)} #00D787
promptRootColor=${promptRootColor:-$(pColor x124_Red3)}

[[ "$(id -u)" -eq 0 ]] &&
    promptColor="$promptRootColor" ||
    promptColor="$promptUserColor"

# user@host:/current/path
[[ "$(id -u)" -eq 0 ]] &&
  promptBase="${promptColor}\u@${PROMPT_HOSTNAME:-\h}$(pColor white):$(pColor cyan)\w$(pResetColor)" ||
  promptBase="${promptColor}\u@${PROMPT_HOSTNAME:-\h}$(pColor white):$(pColor blueBold)\w$(pResetColor)"


#promptEnd='\$ ' # $ or # if root
#promptEnd="${promptColor}❯$(pResetColor) " # heavy right-pointing angle quotation mark ornament
promptEnd="${promptColor}$(pResetColor) " # \uf054 nf-fa-chevron_circle_down (nerd font)

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
