
# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return


# Completion options
[[ -f /etc/bash_completion ]] && . /etc/bash_completion


# History Options

# Don't put duplicate lines in the history.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well


# Aliases
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi


# Functions
if [ -f "${HOME}/.bash_functions" ]; then
  source "${HOME}/.bash_functions"
fi


# prompt
[[ -f ~/.bash_prompt/prompt.sh ]] && . ~/.bash_prompt/prompt.sh


# local config
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
