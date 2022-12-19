
. ~/.dotfiles/.bash_prompt/colors.sh
. ~/.dotfiles/.bash_prompt/prompt_git.sh
. ~/.dotfiles/.bash_prompt/prompt_git_pretty.sh
. ~/.dotfiles/.bash_prompt/prompt_utils.sh

# user@host:/current/path
[[ "$(id -u)" -eq 0 ]] \
  && promptBase="${redTxt}\u@${PROMPT_HOSTNAME:-\h}${whiteTxt}:${cyanTxt}\w${resetColor}" \
  || promptBase="${greenTxt}\u@${PROMPT_HOSTNAME:-\h}${whiteTxt}:${blueBold}\w${resetColor}"

# $ or # if root
promptEnd='\$ '

# default
PS1="${promptBase} ${promptEnd}"


# Pre-prompt hooks
PROMPT_COMMAND=(
  prompt_window_title
  prompt_separator
  prompt_git
  prompt_newline
  prompt_git_dyn_graph_width

  'PS1="${promptTitle}${promptSeparator}${promptBase} ${promptGit}${promptNewline}${promptEnd}"'
)
