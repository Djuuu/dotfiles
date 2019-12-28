#!/usr/bin/env bash

# Exit if xbindkeys does not exist
[ ! `command -v xbindkeys` ] && exit 0;

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Available device bindings
declare -A DEVICE_BINDINGS
DEVICE_BINDINGS["Logitech MX Master 3"]="MX-Master-3.xbindkeysrc"


echo "Building ~/.xbindkeysrc"

# Common .xbindkeysrc
cat ${BASEDIR}/.xbindkeys/common.xbindkeysrc > ~/.xbindkeysrc


# Device-specific .xbindkeysrc
devices=`xinput list`
for device in "${!DEVICE_BINDINGS[@]}"
do
    bindingFileName=${DEVICE_BINDINGS[$device]}
    bindingFilePath=${BASEDIR}/.xbindkeys/${bindingFileName}

    if grep -q "${device}" <<<${devices}; then
        if [ -f "$bindingFilePath" ]; then
            echo "  Adding $device bindings"
            cat $bindingFilePath >> ~/.xbindkeysrc
        else
            echo "  Binding file not found: $bindingFilePath"
        fi
    fi
done


# (Re)start xbindkeys
if pgrep xbindkeys > /dev/null; then
    echo "  Restarting xbindkeys"
    pkill xbindkeys
else
    echo "  Starting xbindkeys"
fi
xbindkeys
