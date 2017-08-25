
# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lh'
alias  l='ls $LS_OPTIONS -lhA'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -r'                          # raw control characters
alias whence='type -a'                        # where, of a sort
alias grep='grep --color'                     # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour
alias rsynca='rsync -avzP'
alias h='history'

alias please='sudo $(fc -nl -1)'

alias sshagentstart='eval `ssh-agent -s` && ssh-add'

# Vagrant
alias  vu='vagrant up'
alias  vd='vagrant destroy'
alias  vr='vagrant reload'
alias vrp='vagrant reload --provision'
alias vsh='vagrant ssh'
alias vsp='vagrant suspend'
alias  vh='vagrant halt'

# PHP
alias phpd="php -dxdebug.remote_enable=On -dxdebug.remote_autostart=On -dxdebug.idekey=php-xdebug -dxdebug.remote_host=`echo $SSH_CLIENT | cut -d "=" -f 2 | awk '{print $1}'`"

# Symfony

# alias sf='./symfony --color' # Sf 1.x
# alias sf='./app/console' # Sf 2.x
# alias sf='./bin/console' # Sf 3.x

# alias sfd='phpd ./symfony --color' # Sf 1.x
# alias sfd='phpd ./app/console' # Sf 2.x
# alias sfd='phpd ./bin/console' # Sf 3.x

# alias sfatoum='sf atoum:test --no-code-coverage --force-terminal' # Sf 1.x


# Laravel
alias artisan='php artisan'
alias art='php artisan'

alias ggw='gulp && gulp watch'

function homestead() {
	( cd ~/www/Homestead && vagrant $* )
}
