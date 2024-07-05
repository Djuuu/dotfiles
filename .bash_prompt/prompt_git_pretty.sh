
# Dynamic git log columns width
GIT_DYN_GRAPH_TPL=${GIT_DYN_GRAPH_TPL:-'%C(auto)%h%d %<|(__sw__)%s %C(bold blue) ✏ %<(__uw__,trunc)%aN %C(green)⏱  %<(__tw__,trunc)%ar%C(reset)'}
GIT_DYN_GRAPH_TPL_T=${GIT_DYN_GRAPH_TPL_T:-'%C(auto)%h%d %<|(__sw__,trunc)%s %C(bold blue)✏ %<(__uw__,trunc)%aN %C(green)⏱  %<(__tw__,trunc)%ar%C(reset)'}

GIT_MSG_COLUMN_MARGIN=${GIT_MSG_COLUMN_MARGIN:-34}
GIT_LG_COLUMN_MARGIN=${GIT_LG_COLUMN_MARGIN:-12}

prompt_git_dyn_graph_width() {
    [ -z "$COLUMNS" ] && return

    GIT_MSG_COLUMNS_OLD=$GIT_MSG_COLUMNS
    GIT_MSG_COLUMNS=$((COLUMNS - GIT_MSG_COLUMN_MARGIN))
    GIT_LG_COLUMNS=$(( GIT_MSG_COLUMNS * 2 / 3 - GIT_LG_COLUMN_MARGIN ))

    local user_columns=12
    local time_columns=12

    local git_dyn_graph_value="${GIT_DYN_GRAPH_TPL}"
    local git_dyn_graph_t_value="${GIT_DYN_GRAPH_TPL_T}"
    local git_dyn_graph_lg_value="${GIT_DYN_GRAPH_TPL_T}"

    git_dyn_graph_lg_value="${git_dyn_graph_lg_value//__sw__/${GIT_LG_COLUMNS}}"
    git_dyn_graph_lg_value="${git_dyn_graph_lg_value//__uw__/${user_columns}}"
    git_dyn_graph_lg_value="${git_dyn_graph_lg_value//__tw__/${time_columns}}"

    if [[ $COLUMNS -ge 160 ]]; then
        user_columns=18 # + 6
        time_columns=16 # + 4
        GIT_MSG_COLUMNS=$((GIT_MSG_COLUMNS - 10))
    fi

    git_dyn_graph_value="${git_dyn_graph_value//__sw__/${GIT_MSG_COLUMNS}}"
    git_dyn_graph_value="${git_dyn_graph_value//__uw__/${user_columns}}"
    git_dyn_graph_value="${git_dyn_graph_value//__tw__/${time_columns}}"

    git_dyn_graph_t_value="${git_dyn_graph_t_value//__sw__/${GIT_MSG_COLUMNS}}"
    git_dyn_graph_t_value="${git_dyn_graph_t_value//__uw__/${user_columns}}"
    git_dyn_graph_t_value="${git_dyn_graph_t_value//__tw__/${time_columns}}"

    if [[ $GIT_MSG_COLUMNS -ne $GIT_MSG_COLUMNS_OLD ]]; then
        local configFile; [[ -f "${HOME}/.dotfiles/.gitconfig.local" ]] &&
            configFile="${HOME}/.dotfiles/.gitconfig.local" ||
            configFile="${HOME}/.gitconfig"

        git config -f "$configFile" pretty.graph-dyn "${git_dyn_graph_value}"
        git config -f "$configFile" pretty.graph-dyn-t "${git_dyn_graph_t_value}"
        git config -f "$configFile" pretty.graph-dyn-lg "${git_dyn_graph_lg_value}"
    fi
}
