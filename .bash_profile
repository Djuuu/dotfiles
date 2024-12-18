# ~/.bash_profile: executed by bash(1) for login shells.

# source the users bashrc if it exists
[ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# Add go/bin to PATH
[ -d "/usr/local/go/bin" ] && PATH="$PATH:/usr/local/go/bin"

# Set PATH so it includes user's bin/ directories
[ -d "${HOME}/go/bin" ]     && PATH="${HOME}/go/bin:${PATH}"
[ -d "${HOME}/bin" ]        && PATH="${HOME}/bin:${PATH}"
[ -d "${HOME}/.local/bin" ] && PATH="${HOME}/.local/bin:${PATH}"

# Set MANPATH so it includes users' private man if it exists
[ -d "${HOME}/man" ] && MANPATH="${HOME}/man:${MANPATH}"

# Set INFOPATH so it includes users' private info if it exists
[ -d "${HOME}/info" ] && INFOPATH="${HOME}/info:${INFOPATH}"

# editor
export EDITOR="vim"
export VISUAL="vim"
