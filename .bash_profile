#
# ~/.bash_profile: executed by bash(1) for login shells.
#

# source the users bashrc if it exists
[ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# Set PATH so it includes user's bin/ directories
[ -d "${HOME}/go/bin" ]     && PATH="${HOME}/go/bin:${PATH}"
[ -d "${HOME}/bin" ]        && PATH="${HOME}/bin:${PATH}"
[ -d "${HOME}/.local/bin" ] && PATH="${HOME}/.local/bin:${PATH}"

# Set MANPATH so it includes users' private man if it exists
[ -d "${HOME}/man" ] && MANPATH="${HOME}/man:${MANPATH}"

# Set INFOPATH so it includes users' private info if it exists
[ -d "${HOME}/info" ] && INFOPATH="${HOME}/info:${INFOPATH}"

# Git custom commands
[ -d "${HOME}/.dotfiles/git-context-graph" ] && PATH="${PATH}:${HOME}/.dotfiles/git-context-graph"
[ -d "${HOME}/.dotfiles/git-mr" ]            && PATH="${PATH}:${HOME}/.dotfiles/git-mr"

[ -f "${HOME}/.dotfiles/git-context-graph/git-context-graph-completion.bash" ] &&
   . "${HOME}/.dotfiles/git-context-graph/git-context-graph-completion.bash"

[ -f "${HOME}/.dotfiles/git-mr/git-mr-completion.bash" ] &&
   . "${HOME}/.dotfiles/git-mr/git-mr-completion.bash"

# LazyGit - https://github.com/jesseduffield/lazygit
LG_CONFIG_FILE="$(home_path ".dotfiles/.config/lazygit/config.yml")"
LG_CONFIG_FILE="${LG_CONFIG_FILE},$(home_path ".dotfiles/.config/lazygit/config.keybinding.yml")"
[ -f "$(home_path ".dotfiles/.config/lazygit/config.local.yml")" ] &&
    LG_CONFIG_FILE="${LG_CONFIG_FILE},$(home_path ".dotfiles/.config/lazygit/config.local.yml")"
export LG_CONFIG_FILE


# Set user-defined locale
#export LANG=$(locale -uU)

# editor
export EDITOR="vim"
export VISUAL="vim"
