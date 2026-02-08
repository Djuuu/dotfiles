#!/usr/bin/env bash

# Tmux window title for SSH panes (user@host)
# Inspired by: https://github.com/erikw/tmux-powerline/discussions/448

pane_current_command="${1}"
pane_pid="${2}"

IS_BUSYBOX_PS=
detect_busybox_ps() {
    local ps_path

    ps_path=$(command -v ps) || return 1

    [[ -L "$ps_path" ]] &&
        [[ $(readlink "$ps_path") == *busybox ]] &&
        IS_BUSYBOX_PS="true"
}

get_child_pid() {
    local parent_pid=$1

    if [[ -n $IS_BUSYBOX_PS ]]; then
        # BusyBox: parse output manually (columns: PID PPID ...)
        ps -o pid,ppid | awk -v ppid="$parent_pid" '$2 == ppid { print $1; exit }'
    else
        # GNU ps: use --ppid option
        ps --no-headers --ppid="$parent_pid" -o pid | xargs
    fi
}

get_process_args() {
    local pid=$1

    if [[ -n $IS_BUSYBOX_PS ]]; then
        # BusyBox: extract pid from list and get args
        ps -o pid,args | awk -v pid="$pid" '$1 == pid { for(i=2; i<=NF; i++) printf "%s ", $i; exit }' | sed 's/ $//'
    else
        # GNU ps: query proper pid directly (-q) and output args
        ps --no-headers -q "$pid" -o args
    fi
}

get_ssh_args() {
    local sshpid=$1
    local sshargs=""
    local arg sshuser
    local cmdline

    # Get full command line
    cmdline=$(get_process_args "$sshpid")

    # Extract ssh args (skip command name and options)
    for arg in $(echo "$cmdline" | cut -d' ' -f2-); do
        [[ ! $arg =~ ^- ]] &&
            sshargs="${sshargs}${arg} "
    done
    sshargs="${sshargs% }"

    # Add default ssh user if not specified
    if [[ ! $sshargs =~ @ ]]; then
        sshuser=$(ssh -G "$sshargs" 2>/dev/null | awk '/^user / { print $2; exit }')
        sshargs="${sshuser}@${sshargs}"
    fi

    echo -n "$sshargs"
}

main() {
    detect_busybox_ps

    if [[ $pane_current_command == "ssh" ]]; then
        sshpid=$(get_child_pid "$pane_pid")
        get_ssh_args "$sshpid"
        return
    fi

    if [[ $pane_current_command == "sshs" ]]; then
        sshspid=$(get_child_pid "$pane_pid")
        sshpid=$(get_child_pid "$sshspid")
        if [[ -n $sshpid ]]; then
            get_ssh_args "$sshpid"
            return
        fi
    fi

    echo -n "#{E:@_w_default_title}"
}

main
