
# Load local environment variables
[ -f ~/.dotfiles/.bashrc.env.local ] && . ~/.dotfiles/.bashrc.env.local

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
[[ -f ~/.dotfiles/.bash_aliases ]] && . ~/.dotfiles/.bash_aliases

# Functions
[[ -f ~/.dotfiles/.bash_functions ]] && . ~/.dotfiles/.bash_functions

# Prompt
[[ -f ~/.dotfiles/.bash_prompt/prompt.sh ]] && . ~/.dotfiles/.bash_prompt/prompt.sh

# Local config
[[ -f ~/.dotfiles/.bashrc.local ]] && . ~/.dotfiles/.bashrc.local
