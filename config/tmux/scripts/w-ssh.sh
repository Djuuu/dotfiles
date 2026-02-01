#!/usr/bin/env bash

# Tmux window title for SSH panes (user@host)
# Inspired by: https://github.com/erikw/tmux-powerline/discussions/448

pane_current_command="${1}"
pane_pid="${2}"


get_ssh_args() {
    local sshpid=$1
    local sshargs=""
    local arg sshuser

    # Extract ssh args
    for arg in $(ps --no-headers -q "$sshpid" -o args | cut -d' ' -f2-); do
        [[ ! $arg =~ ^- ]] &&
            sshargs="${sshargs}${arg} "
    done
    sshargs="${sshargs% }"

    # Add default ssh user if not specified
    if [[ ! $sshargs =~ @ ]]; then
        sshuser=$(ssh -G "$sshargs" 2>/dev/null | awk '/^user / { print $2; exit }')
        sshargs="${sshuser}@${sshargs}"
    fi

    echo "$sshargs"
}


if [[ $pane_current_command == "ssh" ]]; then
    sshpid=$(ps --no-headers --ppid="${pane_pid}" -o pid | xargs)
    get_ssh_args "$sshpid"
    exit 0
fi


if [[ $pane_current_command == "sshs" ]]; then
    sshspid=$(ps --no-headers --ppid="${pane_pid}" -o pid | xargs)
    sshpid=$(ps --no-headers --ppid="${sshspid}" -o pid | xargs)
    if [[ -n $sshpid ]]; then
        get_ssh_args "$sshpid"
        exit 0
    fi
fi


echo -n "#{E:@_w_default_title}"
