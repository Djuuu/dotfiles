
function set_window_title {
	export FORCED_WINDOW_TITLE="$@"
    printf '\e]2;%s\a' "$@"
}

function unset_window_title {
	unset FORCED_WINDOW_TITLE
	printf '\e]2;%s\a' "${DEFAULT_WINDOW_TITLE:-${USERNAME}@${HOSTNAME} - $(pwd)}"
}

################################################################################
# Laravel Homestead

homestead () {
	( cd ~/www/Homestead && vagrant $* )
}

################################################################################
# Docker

source ~/dockerize-clis/dockerize-clis.sh
