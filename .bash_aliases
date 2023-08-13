
# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

export LS_OPTIONS='--color=auto'
if [ -x "$(command -v dircolors)" ]; then
    eval "$(dircolors)"
else
    #export LS_OPTIONS=''
    export CLICOLOR=1
fi

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lh'
alias  l='ls $LS_OPTIONS -lhA'

# Default to human-readable figures
alias df='df -h'
alias du='du -h'

# Misc
alias less='less -r'                          # raw control characters
alias whence='type -a'                        # where, of a sort
alias grep='grep --color=auto'                # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour
alias rsynca='rsync -avzP'
alias h='history'

alias please='sudo $(fc -nl -1)'

alias sshagentstart='eval `ssh-agent -s` && ssh-add'

# Git
alias gg='git context-graph --pretty=graph-dyn'
alias gga='git context-graph --pretty=graph-dyn --all'
alias ggo='git context-graph --pretty=oneline'
alias ggp='git-context-graph-page'
alias lg='lazygit'

# Git - mu-repo
alias gm='git mu'
alias gmr='git mu register'
alias gml='git mu list'
alias gmg='git mu group'
alias gmgs='git mu group switch'

# Docker
alias d='docker'
alias dc='docker compose'
