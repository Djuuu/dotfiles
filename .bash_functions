
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

ssh-list-tunnels() {
    # -a       This option causes list selection options to be ANDed.
    # -b       Causes lsof to avoid kernel functions that might block (lstat, readlink, stat).
    # -l       This option inhibits the conversion of user ID numbers to login names.
    # -n       This option inhibits the conversion of network numbers to host names for network files.
    # -P       This option inhibits the conversion of port numbers to port names for network files.
    # +|-w     Enables (+) or disables (-) the suppression of warning messages.
    # -T [t]   This option controls the reporting of some TCP/TPI information
    #          -T with no following key characters disables TCP/TPI information reporting.
    # -i [i]   This option selects the listing of files any of whose Internet address matches the address specified in i.
    # -c c     This option selects the listing of files for processes executing the command that begins with the characters of c.
    #          If c begins and ends with a slash ('/'), the characters between the slashes are interpreted as a regular expression.
    # -u s     This option selects the listing of files for the user whose login names or user ID numbers are in the comma-separated set s
    # -s [p:s] The optional -s p:s form is available only for selected dialects, and only when the -h or -? help output lists it.
    #          When the optional form is available, the s may be followed by a protocol name (p), either TCP or UDP, a colon (`:') and a
    #          comma-separated protocol state name list, the option causes open TCP and UDP files to be excluded if their state name(s) are
    #          in the list (s) preceded by a `^'; or included if their name(s) are not preceded by a `^'.
    lsof -ablnPw -T -i4  -c '/^ssh$/' -u$USER -s TCP:LISTEN
}

ssh-list-tunnel-ports() {
    local sshTunnels
    sshTunnels="$(ssh-list-tunnels | tail -n +2 | cut -d: -f2 | tr '\n' ',')"
    sshTunnels=${sshTunnels%,}
    [[ -n $sshTunnels ]] && echo $sshTunnels
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
