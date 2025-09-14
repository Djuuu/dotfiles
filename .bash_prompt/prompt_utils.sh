#!/usr/bin/env bash

###################################################################################################
# https://github.com/emilis/emilis-config/blob/master/.bash_ps1

promptFillStart="─"
promptFillBase="─"
promptFillEnd="─┤"

[[ -z "$VIM" ]] \
  && status_style=${pt_reset}'\[\033[0;90m\]' \
  || status_style=${pt_reset}'\[\033[0;90;107m\]'

prompt_ssh_tunnels() {
  promptSshTunnels="${SSH_TUNNELS}"
  [[ $promptCheckTunnels = true ]] && promptSshTunnels="${SSH_TUNNELS:-$(ssh-list-tunnel-ports)}"
}

prompt_separator() {
  # create a $promptFill of all screen width minus the time and command exit indicator
  local promptFillSize=$((COLUMNS - 14))
  local promptFill="$promptFillEnd"

  [[ -n $promptSshTunnels ]] && {
    [[ -n $SSH_TUNNELS ]] &&
      promptFill="[🚇 ${promptSshTunnels}]${promptFill}" ||
      promptFill="[🕳️ ${promptSshTunnels}]${promptFill}"
    (( promptFillSize -= ${#promptSshTunnels} + 5 ))
  }

  while [ "$promptFillSize" -gt "0" ]; do
    promptFill="${promptFillBase}${promptFill}"
    ((promptFillSize -= 1))
  done
  promptFill="${promptFillStart}${promptFill}"

  local exitIcon
  #[[ $EXIT -eq 0 ]] && exitIcon="✔️" || exitIcon="❌"
  [[ $EXIT -eq 0 ]] && exitIcon="✅" || exitIcon="❌"

  promptSeparator="${status_style}${promptFill}$exitIcon \t\n${pt_reset}"
}

###################################################################################################
# Set window title
prompt_window_title() {
  local defaultTitle="${DEFAULT_WINDOW_TITLE:-\h · \W}"
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
    . ~/.dotfiles/.bash_prompt/prompt.sh
}
