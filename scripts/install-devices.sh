#!/usr/bin/env bash

# Exit if xbindkeys does not exist
[ ! "$(command -v xbindkeys)" ] && exit 0;

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR="${BASEDIR%/scripts}"

# Available device bindings
declare -A DEVICE_BINDINGS
DEVICE_BINDINGS["Logitech MX Master 3"]="MX-Master-3.xbindkeysrc"
DEVICE_BINDINGS["Logitech M705"]="M705.xbindkeysrc"


echo "Building ~/.xbindkeysrc"

# Common .xbindkeysrc
cat "${BASEDIR}/.xbindkeys/common.xbindkeysrc" > ~/.xbindkeysrc


# Device-specific .xbindkeysrc

CURRENT_MOUSE=${CURRENT_MOUSE:-Logitech MX Master 3}

bindingFileName=${DEVICE_BINDINGS[$CURRENT_MOUSE]}
bindingFilePath=${BASEDIR}/.xbindkeys/${bindingFileName}

if [ -n "$bindingFileName" ] && [ -f "$bindingFilePath" ]; then
    echo "  Adding $CURRENT_MOUSE bindings"
    cat "$bindingFilePath" >> ~/.xbindkeysrc
fi


# (Re)start xbindkeys
if pgrep xbindkeys > /dev/null; then
    echo "  Restarting xbindkeys"
    pkill xbindkeys
else
    echo "  Starting xbindkeys"
fi
xbindkeys
