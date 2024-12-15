# See https://github.com/git/git/blob/master/contrib/completion/git-completion.bash

# bash completion support for git-mu
#
# Source this file in one of your shell startup scripts (e.g. .bashrc):
#
#   . ~/.dotfiles/git-mu-completion.bash
#
# Git completion is required.
#

_git_mu() {
    # Disable default bash completion (current directory file names, etc.)
    compopt +o bashdefault +o default 2>/dev/null

    local mu_cmds="
    group
    list
    register
    sh
    st
    "
    local git_cmds="
    add
    branch
    checkout clean cleargui commit config
    describe diff difftool
    fetch fsck
    gc grep
    help
    log
    maintenance merge mv
    prune pull push
    reflog remote reset restore rm
    shortlog show show-branch stage stash status submodule switch
    tag
    whatchanged worktree
    "
    local aliases="
    ss sp
    fast-forward ff
    update
    sup
    graph context-graph cg
    uncommit prev-commit recommit
    force-push fp
    pushall fpushall
    mr
    gca
    gone
    forget
    branches
    contains
    mb nmb stmb stnmb rnob rrnob
    transfer-remote
    recurse
    "

    __gitcomp "${mu_cmds} ${git_cmds} ${aliases}"
}

# Load git completion if not loaded yet and available at usual paths
if ! declare -f __git_complete &>/dev/null; then
    if [[ -f "${HOME}/.local/share/bash-completion/completions/git" ]]; then
           . "${HOME}/.local/share/bash-completion/completions/git"
    elif [[ -f "/usr/share/bash-completion/completions/git" ]]; then
             . "/usr/share/bash-completion/completions/git"
    fi
fi

# Add completion for aliases
if declare -f __git_complete > /dev/null; then
    for a in $(alias -p | grep "git[- ]mu" | cut -d' ' -f2 | cut -d= -f1); do
        __git_complete "$a" _git_mu
    done
fi
