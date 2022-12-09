
###################################################################################################
# https://github.com/emilis/emilis-config/blob/master/.bash_ps1

# Fill with minuses (this is recalculated every time the prompt is shown in function prompt_command)
promptFill="--- "
[[ -z "$VIM" ]] \
  && status_style=$resetColor'\[\033[0;90m\]' \
  || status_style=$resetColor'\[\033[0;90;107m\]'

# Reset color for command output (this one is invoked every time before a command is executed):
#trap 'echo -ne "\e[0m"' DEBUG
prompt_separator() {
  # create a $promptFill of all screen width minus the time string and a space:
  let promptFillSize=${COLUMNS}-9
  promptFill=""
  while [ "$promptFillSize" -gt "0" ]; do
    promptFill="-${promptFill}" # fill with underscores to work on
    let promptFillSize=${promptFillSize}-1
  done

  promptSeparator="$status_style"'$promptFill \t\n'"${resetColor}"
}

###################################################################################################
# Set window title
prompt_window_title() {
  local defaultTitle="${DEFAULT_WINDOW_TITLE:-\h - \W}"
  promptTitle="\[\e]0;${FORCED_WINDOW_TITLE:-${defaultTitle}}\a\]"
}

###################################################################################################
# Send prompt sign to new line when available columns are below $PROMPT_COLUMN_LIMIT
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

  echo '\[\e]8;;'"${href}"'\e\\\]'"${text}"'\[\e]8;;\e\\\]'
}
