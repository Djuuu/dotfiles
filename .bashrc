
# Load local environment variables
if [ -f ~/.bashrc.env.local ]; then
	source ~/.bashrc.env.local
fi


# If not running interactively, don't do anything more
[[ "$-" != *i* ]] && return


# Completion options
[ -f /etc/bash_completion ]           && . /etc/bash_completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

#/usr/local/etc

# History Options

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls'

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Aliases
if [ -f ~/.dotfiles/.bash_aliases ]; then
	source ~/.dotfiles/.bash_aliases
fi

# Functions
if [ -f ~/.dotfiles/.bash_functions ]; then
	source ~/.dotfiles/.bash_functions
fi

# prompt
if [ -f ~/.dotfiles/.bash_prompt/prompt.sh ]; then
	source ~/.dotfiles/.bash_prompt/prompt.sh
fi

# local config
if [ -f ~/.bashrc.local ]; then
	source ~/.bashrc.local
fi
