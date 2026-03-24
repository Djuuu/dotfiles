#!/usr/bin/env bash

# Prompt colors - normal / bold
pt_black="\[\e[0;30m\]";  pt_blackBold="\[\e[1;30m\]"
pt_red="\[\e[0;31m\]";    pt_redBold="\[\e[1;31m\]"
pt_green="\[\e[0;32m\]";  pt_greenBold="\[\e[1;32m\]"
pt_yellow="\[\e[0;33m\]"; pt_yellowBold="\[\e[1;33m\]"
pt_blue="\[\e[0;34m\]";   pt_blueBold="\[\e[1;34m\]"
pt_purple="\[\e[0;35m\]"; pt_purpleBold="\[\e[1;35m\]"
pt_cyan="\[\e[0;36m\]";   pt_cyanBold="\[\e[1;36m\]"
pt_white="\[\e[0;37m\]";  pt_whiteBold="\[\e[1;37m\]"

# Prompt colors - reset
pt_reset="\[\e[0m\]"

# Prompt colors - custom
c_userBlGr="\e[38;2;0;190;135m"      #00BE87 custom color
pt_userBlGr="\[\e[38;2;0;190;135m\]" #00BE87 custom color (prompt usage)
pt_x160_Red3="\[\e[38;5;160m\]"

# Includes
# shellcheck source=_prompt_git.sh
. ~/.dotfiles/bash_prompt/_prompt_git.sh
# shellcheck source=_prompt_git_pretty.sh
. ~/.dotfiles/bash_prompt/_prompt_git_pretty.sh
# shellcheck source=_prompt_utils.sh
. ~/.dotfiles/bash_prompt/_prompt_utils.sh

# user vs. root color
[[ "$(id -u)" -eq 0 ]] &&
    pt_color="${promptRootColor:-${pt_x160_Red3}}" ||
    pt_color="${promptUserColor:-${pt_userBlGr}}"

# user@host:/current/path
pt_base="${pt_color}\u@${PROMPT_HOSTNAME:-\h}${pt_reset}:${pt_blueBold}\w${pt_reset}"

#pt_end='\$ ' # $ or # if root
#pt_end="${pt_color}❯${pt_reset} " # heavy right-pointing angle quotation mark ornament
pt_end="${pt_color}${pt_reset} " # \uf054 nf-fa-chevron_circle_down (nerd font)

# default prompt
PS1="${pt_base} ${pt_end}"


# Pre-prompt hooks
PROMPT_COMMAND=(
  'EXIT=$?'
  prompt_window_title
  prompt_ssh_tunnels
  prompt_separator
  prompt_git
  prompt_newline
  prompt_git_dyn_graph_width

  # simple/default
  #'PS1="${pt_base} ${pt_end}"'

  # custom
  #'PS1="${pt_title}${pt_separator}${pt_base} ${pt_git}${pt_newline}${pt_end}"'

  # custom, multiline git
  'PS1="${pt_title}${pt_separator}${pt_base} ${pt_gitBranchInfo}${pt_newline}${pt_gitAction}${pt_gitState}${pt_reset}${pt_end}"'
)
