# ~/.bashrc: executed by bash(1) for non-login shells.

# Environment - common to all shell types
# shellcheck source=.bashrc.env
. ~/.dotfiles/.bashrc.env

# If not running interactively, don't do anything more
[[ "$-" != *i* ]] && return

# If running for WSLGit, don't do anything more (https://github.com/andy-5/wslgit#wslgit-1)
[[ $WSLGIT == 1 ]] && return

# Completion options
source_if /etc/bash_completion
source_if /usr/local/etc/bash_completion
# Custom completions
for f in "${XDG_DATA_HOME}/bash-completion/completions/"*; do # shellcheck disable=SC1090
    source_if "$f"
done; unset f

# History Options
HISTFILE="${XDG_STATE_HOME}/bash/history"
HISTCONTROL=ignoreboth # Don't put duplicate lines or lines starting with space in the history.
HISTIGNORE=$'[ \t]*:&:[bf]g:clear:exit:history:h:ls:l:pwd' # Ignore patterns ('&': suppress duplicate entries)
shopt -s histappend # Append to the history file, don't overwrite it
HISTSIZE=2000
HISTFILESIZE=6000

# Enable color support of ls
if command -v dircolors > /dev/null 2>&1; then
    if [[ -r ~/.dircolors ]]
        then eval "$(dircolors -b ~/.dircolors)"
        else eval "$(dircolors -b)"; fi fi

export CLICOLOR=1 # Mac

# Aliases
# shellcheck source=.bash_aliases
source_if ~/.dotfiles/.bash_aliases

# Functions
# shellcheck source=.bash_functions
source_if ~/.dotfiles/.bash_functions

# Prompt
# shellcheck source=bash_prompt/prompt.sh
source_if ~/.dotfiles/bash_prompt/prompt.sh

# bat-extras - https://github.com/eth-p/bat-extras
[[ -x "$(command -v batman)"  ]] && eval "$(batman --export-env)"

# Set up fzf key bindings and fuzzy completion
if command -v fzf > /dev/null 2>&1; then
    eval "$(fzf --bash)"
fi

# forgit - https://github.com/wfxr/forgit
# shellcheck source=config/forgit/forgit.sh
. ~/.dotfiles/config/forgit/forgit.sh

# LazyGit - https://github.com/jesseduffield/lazygit
LG_CONFIG_FILE="$(home_path ".dotfiles/config/lazygit/config.yml")"
LG_CONFIG_FILE="${LG_CONFIG_FILE},$(home_path ".dotfiles/config/lazygit/config.keybinding.yml")"
[ -f "$(home_path ".dotfiles/config/lazygit/config.local.yml")" ] &&
    LG_CONFIG_FILE="${LG_CONFIG_FILE},$(home_path ".dotfiles/config/lazygit/config.local.yml")"
export LG_CONFIG_FILE

# Local overrides
# shellcheck source=.bashrc.local
source_if ~/.dotfiles/.bashrc.local
