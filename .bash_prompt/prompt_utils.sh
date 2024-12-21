#!/usr/bin/env bash

###################################################################################################
# https://github.com/emilis/emilis-config/blob/master/.bash_ps1

promptFillStart="─"
promptFillBase="─"
promptFillEnd="───┤"

[[ -z "$VIM" ]] \
  && status_style=$resetColor'\[\033[0;90m\]' \
  || status_style=$resetColor'\[\033[0;90;107m\]'

prompt_separator() {
  # create a $promptFill of all screen width minus the time and command exit indicator
  local promptFillSize=$((COLUMNS - 16))
  local promptFill="$promptFillEnd"
  while [ "$promptFillSize" -gt "0" ]; do
    promptFill="${promptFillBase}${promptFill}"
    ((promptFillSize -= 1))
  done
  promptFill="${promptFillStart}${promptFill}"

  local exitIcon
  [[ $EXIT -eq 0 ]] && exitIcon="✔️" || exitIcon="❌"

  promptSeparator="${status_style}${promptFill}$exitIcon \t\n${resetColor}"
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
