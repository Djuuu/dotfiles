#
# ~/.bash_profile: executed by bash(1) for login shells.
#

# source the users profile if it exists
[ -f "${HOME}/.profile" ] && . "${HOME}/.profile"

# source the users bashrc if it exists
[ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"


# Set PATH so it includes user's private bin if it exists
[ -d "${HOME}/bin" ] && PATH="${HOME}/bin:${PATH}"

# Set MANPATH so it includes users' private man if it exists
[ -d "${HOME}/man" ] && MANPATH="${HOME}/man:${MANPATH}"

# Set INFOPATH so it includes users' private info if it exists
[ -d "${HOME}/info" ] && INFOPATH="${HOME}/info:${INFOPATH}"

# Git custom commands
[ -d "${HOME}/.dotfiles/git-context-graph" ] && PATH="${PATH}:${HOME}/.dotfiles/git-context-graph"
[ -d "${HOME}/.dotfiles/git-mr" ]            && PATH="${PATH}:${HOME}/.dotfiles/git-mr"

# Set user-defined locale
#export LANG=$(locale -uU)

# editor
export EDITOR="vim"
export VISUAL="vim"
