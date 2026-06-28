#!/usr/bin/env bash

# Tmux window title for SSH panes (user@host)
# Inspired by: https://github.com/erikw/tmux-powerline/discussions/448

window_name="${1}"
pane_current_command="${2}"
pane_pid="${3}"

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

    if [[ -z $sshargs ]]; then
        return 1 # Fail (can happen when the ssh connection is closed but $window_name hasn't updated yet)
    fi

    # Add default ssh user if not specified
    if [[ ! $sshargs =~ @ ]]; then
        sshuser=$(ssh -G "$sshargs" 2>/dev/null | awk '/^user / { print $2; exit }')
        sshargs="${sshuser}@${sshargs}"
    fi

    echo -n "$sshargs"
}

main() {
    local _w_path="#{?#{==:#{pane_current_path},${HOME}},~,#{b:pane_current_path}}"
    local _w_title="  #W"

    # echo -n "|w:${window_name}|c:${pane_current_command}|p:${pane_pid}| "

    case "${window_name}" in
        bash|fish|ksh|zsh|sh)  _w_title=" "  ;;
        '[tmux]')              _w_title=" "  ;;

        ssh)
            detect_busybox_ps
            local sshpid; sshpid=$(get_child_pid "$pane_pid")
            get_ssh_args "$sshpid" && return || _w_title=" "
            ;;

        sshs)
            detect_busybox_ps
            local sshspid; sshspid=$(get_child_pid "$pane_pid")
            local sshpid; sshpid=$(get_child_pid "$sshspid")
            if [[ -n $sshpid ]]; then
                get_ssh_args "$sshpid" && return || _w_title=" "
            fi
            ;;

        python)
            detect_busybox_ps
            local pythonpid; pythonpid=$(get_child_pid "$pane_pid")
            local cmdline; cmdline=$(get_process_args "$pythonpid")
            if [[ $cmdline =~ 'ansible/bin/python' ]]; then
                _w_title="  ansible"
            fi
            ;;

    esac

    echo -n "${_w_path}${_w_title}"
}

main
