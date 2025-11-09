#!/usr/bin/env bash

# Exit if xbindkeys does not exist
[ ! "$(command -v xbindkeys)" ] && exit 0;

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR="${BASEDIR%/scripts}"

# Available device bindings
declare -A DEVICE_BINDINGS
DEVICE_BINDINGS["Logitech MX Master 3"]="MX-Master-3.xbindkeysrc"
DEVICE_BINDINGS["Logitech M705"]="M705.xbindkeysrc"


echo "Building ${XDG_CONFIG_HOME}/xbindkeys/config"

# Common .xbindkeysrc
cat "${BASEDIR}/.config/xbindkeys/common.xbindkeysrc" > "${XDG_CONFIG_HOME}/xbindkeys/config"


# Device-specific .xbindkeysrc

CURRENT_MOUSE="${CURRENT_MOUSE:-Logitech MX Master 3}"

bindingFileName="${DEVICE_BINDINGS[$CURRENT_MOUSE]}"
bindingFilePath="${BASEDIR}/.config/xbindkeys/${bindingFileName}"

if [ -n "$bindingFileName" ] && [ -f "$bindingFilePath" ]; then
    echo "  Adding $CURRENT_MOUSE bindings"
    echo                   >> "${XDG_CONFIG_HOME}/xbindkeys/config"
    cat "$bindingFilePath" >> "${XDG_CONFIG_HOME}/xbindkeys/config"
fi


# (Re)start xbindkeys
if pgrep xbindkeys > /dev/null; then
    echo "  Restarting xbindkeys"
    pkill xbindkeys
else
    echo "  Starting xbindkeys"
fi
xbindkeys -f "${XDG_CONFIG_HOME}/xbindkeys/config"
