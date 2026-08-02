# forgit - https://github.com/wfxr/forgit

export FORGIT_NO_ALIASES=1

# Per-command Options
export FORGIT_LOG_GIT_CMD="git context-graph"
export FORGIT_LOG_GIT_OPTS='-n1500'
export FORGIT_LOG_PREVIEW_GIT_OPTS="-m"
FORGIT_LOG_FZF_OPTS=
FORGIT_LOG_FZF_OPTS+=' --bind="ctrl-f:execute-silent(git context-graph --fold-toggle)+reload(git forgit log_list)"'
FORGIT_LOG_FZF_OPTS+=' --bind="ctrl-a:reload(git forgit log_list -n-1)"'
export FORGIT_LOG_FZF_OPTS

# Pagers
export FORGIT_PAGER="delta --features='common highlight'"

# FZF Options
export FORGIT_FZF_DEFAULT_OPTS="
--height='100%'
--layout=reverse-list
--preview-window='right,55%,wrap,wrap-word,~3'
"

# Other Options
export FORGIT_LOG_GRAPH_ENABLE=true
export FORGIT_PREVIEW_CONTEXT=5


## Plugin
#if [ -f ~/.dotfiles/lib/forgit/forgit.plugin.sh ]; then
#    # shellcheck source=../../lib/forgit/forgit.plugin.sh
#    . ~/.dotfiles/lib/forgit/forgit.plugin.sh
#fi


# Completion
if [ -f ~/.dotfiles/lib/forgit/completions/git-forgit.bash ]; then
    # shellcheck source=../../lib/forgit/completions/git-forgit.bash
    . ~/.dotfiles/lib/forgit/completions/git-forgit.bash

    # Complete `fg` custom alias.
    # _git_forgit reads COMP_WORDS[1] to detect aliases, but git only rewrites its internal words[1] on alias expansion,
    # so it mistakes `fg` for an alias holding a subcommand and completes nothing.
    # Feed it the word it expects. git prefers _git_<alias> over alias expansion, so this wins.
    _git_fg() {
        local COMP_WORDS=("${COMP_WORDS[@]}")
        COMP_WORDS[1]=forgit
        _git_forgit
    }
fi
