
set_window_title() {
    export FORCED_WINDOW_TITLE="$@"
    printf '\e]2;%s\a' "$@"
}

unset_window_title() {
    unset FORCED_WINDOW_TITLE
    printf '\e]2;%s\a' "${DEFAULT_WINDOW_TITLE:-${USERNAME}@${HOSTNAME} - $(pwd)}"
}

is_win() {
    case "$(uname -s)" in
        CYGWIN*|MINGW*) return 0 ;;
        *)              return 1 ;;
    esac
}

home_path() {
    is_win &&
        echo "$USERPROFILE\\${1//\//\\}" ||
        echo "$HOME/$1"
}


dotfiles-update () {
    (cd ~/.dotfiles && git update)
    ~/.dotfiles/install
}

dotfiles-diff-local () {
    BASEDIR=~/.dotfiles

    while IFS= read -r -d '' srcFilePath
    do
        dstFilePath="${srcFilePath%.example}"
        [[ -f "${dstFilePath}" ]] || dstFilePath=/dev/null

        git diff --no-index "${srcFilePath}" "${dstFilePath}"

        has_diff=$?
        echo
        [[ $has_diff -eq 0 ]] && {
            local silver="\e[38;5;7m"
            local grey="\e[38;5;8m"
            local reset="\e[0m"
            local dstSize=${#dstFilePath}

            echo -en "${grey}"; for ((i=1; i<=((dstSize + 2)); i++)); do echo -n '─'; done; echo "┐"
            echo -e "${silver}${dstFilePath}: ${grey}│"
            for ((i=1; i<=((dstSize + 2)); i++)); do echo -n '─'; done
            echo -n "┴"
            for ((i=1; i<=((COLUMNS - dstSize - 3)); i++)); do echo -n '─'; done; echo
            echo -e "\n      ${silver}\e[3munchanged${reset}\n"
        }
    done < <(find "$BASEDIR" -iname "*.local.example" -print0)
}

git-context-graph-page() {
    local margin=8
    local lines=$((LINES - margin))
    git context-graph --first-parent --pretty=graph-dyn "-n${lines}" "$@" | head -n $lines
}

# shellcheck disable=SC2086
git-graph-status-page() {
    local margin=12
    local reset="\e[0m"
    local grey="\033[0;90m"

    #local status_options=""
    local status_options="-s -b"
    local status; status=$(git -c color.status=always status ${status_options})

    local slines; slines=$(wc -l <<< "$status")
    local minlines=10
    local lines=$((LINES - slines - margin))
    lines=$((lines < minlines ? minlines : lines))

    local separator; separator="${grey}$(eval "printf -- '-%.s' {1..${COLUMNS}}")${reset}"

    # clear -x
    #echo -e "$separator"
    echo
    git context-graph --first-parent --pretty=graph-dyn "-n${lines}" "$@" | head -n ${lines}
    echo
    echo -e "$separator"
    echo
    echo "$status"
    echo
}

################################################################################
# Docker

source ~/.dotfiles/dockerize-clis/dockerize-clis.sh
