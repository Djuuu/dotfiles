
# Dynamic git log subject width
GIT_DYN_GRAPH_TPL=${GIT_DYN_GRAPH_TPL:-'%C(auto)%h%d %<|(__sw__)%s %C(bold blue) ✏ %<(12,trunc)%aN %Creset%C(green)⏱  %<(12,trunc)%ar'}
GIT_DYN_GRAPH_TPL_T=${GIT_DYN_GRAPH_TPL_T:-'%C(auto)%h%d %<|(__sw__,mtrunc)%s %C(bold blue) ✏ %<(12,trunc)%aN %Creset%C(green)⏱  %<(12,trunc)%ar'}

GIT_MSG_COLUMN_MARGIN=${GIT_MSG_COLUMN_MARGIN:-34}
GIT_LG_COLUMN_MARGIN=${GIT_LG_COLUMN_MARGIN:-12}

prompt_git_dyn_graph_width() {
    [ -z "$COLUMNS" ] && return

    GIT_MSG_COLUMNS_OLD=$GIT_MSG_COLUMNS
    GIT_MSG_COLUMNS=$((COLUMNS - GIT_MSG_COLUMN_MARGIN))
    GIT_LG_COLUMNS=$(( GIT_MSG_COLUMNS * 2 / 3 - GIT_LG_COLUMN_MARGIN ))

    if [[ $GIT_MSG_COLUMNS -ne $GIT_MSG_COLUMNS_OLD ]]; then
        local configFile; [[ -f "${HOME}/.dotfiles/.gitconfig.local" ]] &&
            configFile="${HOME}/.dotfiles/.gitconfig.local" ||
            configFile="${HOME}/.gitconfig"

        git config -f "$configFile" pretty.graph-dyn "${GIT_DYN_GRAPH_TPL//__sw__/${GIT_MSG_COLUMNS}}"
        git config -f "$configFile" pretty.graph-dyn-t "${GIT_DYN_GRAPH_TPL_T//__sw__/${GIT_MSG_COLUMNS}}"
        git config -f "$configFile" pretty.graph-dyn-lg "${GIT_DYN_GRAPH_TPL//__sw__/${GIT_LG_COLUMNS}}"
    fi
}
