# ~/.bashrc: executed by bash(1) for non-login shells.

# Load local environment variables
# shellcheck source=.bashrc.env.local
[ -f ~/.dotfiles/.bashrc.env.local ] && . ~/.dotfiles/.bashrc.env.local

# Set XDG defaults
# https://specifications.freedesktop.org/basedir/latest/
# https://wiki.archlinux.org/title/XDG_Base_Directory
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}   # user-specific data files
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}    # user-specific configuration files
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state} # user-specific state files
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}       # user-specific non-essential data files
export XDG_BIN_HOME=${XDG_BIN_HOME:-$HOME/.local/bin}       # user-specific executable files (non-standard var)

# If not running interactively, don't do anything more
[[ "$-" != *i* ]] && return

# Completion options
[ -f /etc/bash_completion ]           && . /etc/bash_completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# History Options

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls'

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Enable color support of ls
if command -v dircolors > /dev/null 2>&1; then
    if [[ -r ~/.dircolors ]]
        then eval "$(dircolors -b ~/.dircolors)"
        else eval "$(dircolors -b)"
    fi
fi

export CLICOLOR=1 # Mac

# Aliases
# shellcheck source=.bash_aliases
[[ -f ~/.dotfiles/.bash_aliases ]] && . ~/.dotfiles/.bash_aliases

# Functions
# shellcheck source=.bash_functions
[[ -f ~/.dotfiles/.bash_functions ]] && . ~/.dotfiles/.bash_functions

# Prompt
# shellcheck source=.bash_prompt/prompt.sh
[[ -f ~/.dotfiles/.bash_prompt/prompt.sh ]] && . ~/.dotfiles/.bash_prompt/prompt.sh

# Local config
# shellcheck source=.bashrc.local
[[ -f ~/.dotfiles/.bashrc.local ]] && . ~/.dotfiles/.bashrc.local

# Custom completions
for f in ~/.local/share/bash-completion/completions/*; do
    # shellcheck disable=SC1090
    [[ -f "$f" ]] && . "$f"
done; unset f

# LazyGit - https://github.com/jesseduffield/lazygit
LG_CONFIG_FILE="$(home_path ".dotfiles/.config/lazygit/config.yml")"
LG_CONFIG_FILE="${LG_CONFIG_FILE},$(home_path ".dotfiles/.config/lazygit/config.keybinding.yml")"
[ -f "$(home_path ".dotfiles/.config/lazygit/config.local.yml")" ] &&
    LG_CONFIG_FILE="${LG_CONFIG_FILE},$(home_path ".dotfiles/.config/lazygit/config.local.yml")"
export LG_CONFIG_FILE

# Vim
export VIMINIT="source ${XDG_CONFIG_HOME}/vim/vimrc"
#export VIMINIT="if has('nvim') | source ${XDG_CONFIG_HOME}/nvim/init.vim
#                else           | source ${XDG_CONFIG_HOME}/vim/vimrc | endif"
