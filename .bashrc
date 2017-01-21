
# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return


# Completion options
[[ -f /etc/bash_completion ]] && . /etc/bash_completion


# History Options
#
# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
#
# Whenever displaying the prompt, write the previous line to disk
export PROMPT_COMMAND="history -a"


# Aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi


# Functions
if [ -f "${HOME}/.bash_functions" ]; then
  source "${HOME}/.bash_functions"
fi


### # Git
### unset GIT_SSH
### export GIT_PS1_SHOWDIRTYSTATE=true
### [[ -f ~/.git-prompt.sh ]] && . ~/.git-prompt.sh
###
### # Prompt
### [[ -f ~/.bash_prompt ]] && . ~/.bash_prompt


# prompt
[[ -f ~/.bash_prompt/prompt.sh ]] && . ~/.bash_prompt/prompt.sh

###
###   # Umask
###   # /etc/profile sets 022, removing write perms to group + others.
###   umask 002
###
###   # ssh-pageant
###   eval $(/usr/bin/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")
###
###
###   # Environment
###   export SF_ENV='dev'
###   export COMPOSER_HOME=~/.composer
###
###   ## https://github.com/git-for-windows/git/wiki/OpenSSH-Integration-with-Pageant#starting-ssh-pageant-manually-from-git-bash
###   # ssh-pageant allows use of the PuTTY authentication agent (Pageant)
###   SSH_PAGEANT="$(command -v ssh-pageant)"
###   if [ -x "$SSH_PAGEANT" ]; then
###      eval $("$SSH_PAGEANT" -qra "${SSH_AUTH_SOCK:-${TEMP:-/tmp}/.ssh-pageant-win-$USERNAME}")
###   fi
###   unset SSH_PAGEANT
###
###
