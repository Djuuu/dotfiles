#!/usr/bin/env bash

# shellcheck source=colors.sh
. ~/.dotfiles/.bash_prompt/colors.sh
# shellcheck source=prompt_git.sh
. ~/.dotfiles/.bash_prompt/prompt_git.sh
# shellcheck source=prompt_git_pretty.sh
. ~/.dotfiles/.bash_prompt/prompt_git_pretty.sh
# shellcheck source=prompt_utils.sh
. ~/.dotfiles/.bash_prompt/prompt_utils.sh


promptUserColor=${promptUserColor:-${pt_userBlGr:-"\[\e[38;2;0;190;135m\]"}}
promptRootColor=${promptRootColor:-${pt_x160_Red3:-"\[\e[38;5;160m\]"}}

[[ "$(id -u)" -eq 0 ]] &&
    promptColor="$promptRootColor" ||
    promptColor="$promptUserColor"

# user@host:/current/path
[[ "$(id -u)" -eq 0 ]] &&
  promptBase="${promptColor}\u@${PROMPT_HOSTNAME:-\h}${pt_white}:${pt_cyan}\w${pt_reset}" ||
  promptBase="${promptColor}\u@${PROMPT_HOSTNAME:-\h}${pt_white}:${pt_blueBold}\w${pt_reset}"


#promptEnd='\$ ' # $ or # if root
#promptEnd="${promptColor}❯${pt_reset} " # heavy right-pointing angle quotation mark ornament
promptEnd="${promptColor}${pt_reset} " # \uf054 nf-fa-chevron_circle_down (nerd font)

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

  #'PS1="${promptTitle}${promptSeparator}${promptBase} ${promptGit}${promptNewline}${promptEnd}"'
  'PS1="${promptTitle}${promptSeparator}${promptBase} ${promptGitBranchInfo}${promptNewline}${promptGitAction}${promptGitState}${pt_reset}${promptEnd}"'
)
