
# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# ls aliases
alias ls='ls --color=auto'
alias  l='ls -lhA'
alias ll='ls -lh'

# Default to human-readable figures
alias df='df -h'
alias du='du -h'

# Misc.
alias less='less -R'              # RAW control characters
alias grep='grep --color=auto'    # show differences in colour
alias egrep='egrep --color=auto'  # show differences in colour
alias fgrep='fgrep --color=auto'  # show differences in colour
alias rsynca='rsync -avzP'
alias h='history'

alias please='sudo $(fc -nl -1)'

alias bat="batcat"
alias rat="batcat --paging=never"

alias sshagentstart='eval `ssh-agent -s` && ssh-add'

alias ff='fastfetch'

alias wget='wget --hsts-file=${XDG_DATA_HOME:-$HOME/.local/share}/wget-hsts'

# Git
alias gg='git-context-graph-page --pretty=graph-dyn-t'
alias ggs='git-graph-status-page --pretty=graph-dyn-t'

alias ggg='git context-graph --first-parent --pretty=graph-dyn-t'
alias gga='git context-graph --first-parent --pretty=graph-dyn-t --all'
alias ggv='git context-graph --pretty=graph-dyn-t'
alias ggva='git context-graph --pretty=graph-dyn-t --all'

alias lg='lazygit'
alias zg='lazygit'

# Git - mu-repo
alias gm='git mu'
alias gmst='git mu status --short --branch'
alias gmr='git mu register'
alias gml='git mu list'
alias gmg='git mu group'
alias gmgs='git mu group switch'

# Tmux
alias t=tmac
complete -F _tmac_complete t

# Docker
alias dc='docker compose'
alias lzd='lazydocker'
