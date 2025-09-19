#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#CACHE_DIR="/tmp"
CACHE_DIR="/dev/shm"

battery_icon_cached() {
    cached "battery_icon" \
        "${CURRENT_DIR}/../tmux-battery/scripts/battery_icon.sh" \
        120
}

battery_percentage_cached() {
    cached "battery_percentage" \
        "${CURRENT_DIR}/../tmux-battery/scripts/battery_percentage.sh" \
        120
}

cached() {
    local name=${1}
    local command=${2}
    local ttl=${3:-60}

    local cache_file="${CACHE_DIR}/${name}_cached"
    if [[ -f "${cache_file}" ]]; then
        local now;       now=$(date +%s)
        local cacheDate; cacheDate=$(date -r "${cache_file}" +%s)
        if [[ $now -lt $(( cacheDate + ttl )) ]]; then
            cat "${cache_file}"
            return
        fi
    fi

    "${command}" | tee "${cache_file}"
}

battery_status_get() {
    source "${CURRENT_DIR}/../tmux-battery/scripts/helpers.sh"
    battery_status
}

# Run command supplied as arguments
if [ "$#" -gt 0 ]; then
    "$@"
    exit $?
fi


# Run plugin

status_cache_interpolation=(
    "\#{battery_icon_cached}"
    "\#{battery_percentage_cached}"\

    "\#{battery_status}"
)

status_cache_commands=(\
    "#(${CURRENT_DIR}/status-cache.tmux battery_icon_cached)"
    "#(${CURRENT_DIR}/status-cache.tmux battery_percentage_cached)"\

    "#(${CURRENT_DIR}/status-cache.tmux battery_status_get)"
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
    for ((i=0; i<${#status_cache_commands[@]}; i++)); do
        all_interpolated=${all_interpolated//${status_cache_interpolation[$i]}/${status_cache_commands[$i]}}
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
