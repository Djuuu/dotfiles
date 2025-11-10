#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

get_example_value() {
    echo -n "example"
}

# Run command supplied as arguments
if [ "$#" -gt 0 ]; then
    "$@"
    exit $?
fi

# Run plugin

example_interpolation=(
    "\#{example_value}"
)

example_commands=(
    "#(${CURRENT_DIR}/example-plugin.tmux get_example_value)"
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
    for ((i=0; i<${#example_commands[@]}; i++)); do
        all_interpolated=${all_interpolated//${example_interpolation[$i]}/${example_commands[$i]}}
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
