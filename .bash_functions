#!/usr/bin/env bash



set_window_title() {
	export FORCED_WINDOW_TITLE="$@"
    printf '\e]2;%s\a' "$@"
}

unset_window_title() {
	unset FORCED_WINDOW_TITLE
	printf '\e]2;%s\a' "${DEFAULT_WINDOW_TITLE:-${USERNAME}@${HOSTNAME} - $(pwd)}"
}

git-context-graph-page() {
    local lines=$(( LINES - 8 ))
    gg "-n${lines}" "$@" | head -n $lines
}

################################################################################
# Laravel Homestead

homestead () {
	( cd ~/www/Homestead && vagrant $* )
}

################################################################################
# Docker

source ~/.dotfiles/dockerize-clis/dockerize-clis.sh
