#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/scripts/helpers.sh"

gitmux_if_repo() {
    local ppath; ppath=$(tmux display-message -p "#{pane_current_path}")

    if ! git -C "${ppath}" rev-parse --git-dir > /dev/null 2>&1; then
        return
    fi

    echo -n " "; gitmux -cfg "$HOME/.gitmux.conf" "${ppath}"
}

catppuccin_gitmux_if_repo() {
    local ppath; ppath=$(tmux display-message -p "#{pane_current_path}")

    if ! git -C "${ppath}" rev-parse --git-dir > /dev/null 2>&1; then
        return
    fi

    catppuccin_module_header "gitmux"
    echo -n " "; gitmux -cfg "$HOME/.gitmux.conf" "${ppath}"
    catppuccin_module_footer
}

# Run command supplied as arguments
if [ "$#" -gt 0 ]; then
    "$@"
    exit $?
fi

# Run plugin

gitmux_interpolation=(
    "\#{gitmux_opt}"
    "\#{@catppuccin_status_gitmux_opt}"
)

gitmux_commands=(
    "#(${CURRENT_DIR}/gitmux-opt.tmux gitmux_if_repo)"
    "#(${CURRENT_DIR}/gitmux-opt.tmux catppuccin_gitmux_if_repo)"
)

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value; option_value="$(tmux show-option -gqv "$option")"
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

set_tmux_option() {
    local option="$1"
    local value="$2"
    tmux set-option -gq "$option" "$value"
}

do_interpolation() {
    local all_interpolated="$1"
    local i
    for ((i=0; i<${#gitmux_commands[@]}; i++)); do
        all_interpolated=${all_interpolated//${gitmux_interpolation[$i]}/${gitmux_commands[$i]}}
    done
    echo "$all_interpolated"
}

update_tmux_option() {
    local option="$1"
    local option_value; option_value="$(get_tmux_option "$option")"
    local new_option_value; new_option_value="$(do_interpolation "$option_value")"
    set_tmux_option "$option" "$new_option_value"
}

main() {
    update_tmux_option "status-right"
    update_tmux_option "status-left"
}
main
