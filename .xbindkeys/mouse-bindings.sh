#!/usr/bin/env bash

########################################################################################################################
# Mouse buttons wrapper script for use with xbindkeys
#
# Available buttons:
#
#   Thumb
#   Scroll_L
#   Scroll_R
#   WScroll_L (MX Master thumb wheel)
#   WScroll_R (MX Master thumb wheel)
#   Back
#   Forward
#
# Modifiers:
#
#   "Shift"
#   "Control"
#   "Alt"
#   "Shift+Control"
#   "Shift+Alt"
#   "Control+Alt"
#   "Shift+Control+Alt"
#

button=$1
modifiers=$2

# Horizontal scroll sensitivity reduction
hScrollModulo=3
hScrollIndexBuffer="/dev/shm/LogitechMXMaster3HScroll"

# https://askubuntu.com/questions/97213/application-specific-key-combination-remapping
Wid=`xdotool getactivewindow`
Wname=`xprop -id ${Wid} |awk '/WM_CLASS/{print $4}'`

## Debug (for use with `xbindkeys -v`)
# echo "modifiers Wname:$Wname ; button:$button ; modifiers:$modifiers"


# Logitech MX Master thumb wheel throttling
function throttleHorizontalScroll {

    local newDirection=$@;

    # read buffer
    local buffer=(`cat $hScrollIndexBuffer`)
    local oldDirection=${buffer[0]}
    local value=${buffer[1]}

    if [ "$oldDirection" = "$newDirection" ]; then
        # increment
        ((value++))
        ((value%=$hScrollModulo))
    else
        # reset on direction change
        value=1
    fi

    # write buffer
    echo "$newDirection $value" > $hScrollIndexBuffer || value=0

    # temporize scroll
    [ ${value} -ne 0 ] && exit;
}

case "$button" in
    "WScroll_L") throttleHorizontalScroll "L"; ;;
    "WScroll_R") throttleHorizontalScroll "R"; ;;
esac


case "$button" in

    "WScroll_L" | "Scroll_L")

        case "$Wname" in

            '"jetbrains-phpstorm"')
                case "$modifiers" in
                    "Alt") xdotool key Down; ;; # Shrink selection

                    "Shift+Alt") xdotool key Left; ;; # Navigate back

                    "Control")       xdotool key minus; ;; # Collapse
                    "Shift+Control") xdotool key minus; ;; # Collapse all
                    "Control+Alt")   xdotool key minus; ;; # Collapse recursively

                    *) xdotool key --clearmodifiers alt+Left; ;; # Select previous tab
                esac
                ;;

            *) xdotool key --clearmodifiers ctrl+shift+Tab; ;; # Previous tab
        esac
        ;;

    "WScroll_R" | "Scroll_R")

        case "$Wname" in

            '"jetbrains-phpstorm"')
                case "$modifiers" in
                    "Alt") xdotool key Up; ;; # Extend selection

                    "Shift+Alt") xdotool key Right; ;; # Navigate forward

                    "Control")       xdotool key equal; ;; # Expand
                    "Shift+Control") xdotool key equal; ;; # Expand all
                    "Control+Alt")   xdotool key equal; ;; # Expand recursively

                    *) xdotool key --clearmodifiers alt+Right; ;; # Select next tab
                esac
                ;;

            *) xdotool key --clearmodifiers ctrl+Tab; ;; # Next tab
        esac
        ;;

    "Back")
        case "$Wname" in

            '"Tilix"')
                xdotool key ctrl+shift+X # Maximize terminal
            ;;

            '"Firefox"' | '"Google-chrome"')
                xdotool key F12 # Developer tools
                ;;

            '"jetbrains-phpstorm"')
                case "$modifiers" in

                    "Alt") xdotool key --clearmodifiers Left \
                                   key --clearmodifiers alt+l \
                                   keydown alt; ;; # (move left and) Align carets

                    "Control+Alt") xdotool key l; ;; # Reformat code

                    *) xdotool key ctrl+shift+F12; ;; # Hide all tool windows
                esac
                ;;
        esac
        ;;

    "Forward")
        case "$Wname" in

            '"Tilix"')
                xdotool key ctrl+shift+C # Copy
            ;;

            '"Firefox"' | '"Google-chrome"')
                case "$modifiers" in
                    "Control") xdotool key f;  ;; # Find
                    "Shift")   xdotool key F3; ;; # Find previous
                    *)         xdotool key F3; ;; # Find next
                esac
                ;;

            '"jetbrains-phpstorm"')
                case "$modifiers" in
                    "Alt")               xdotool key j; ;; # Add selection for next occurrence
                    "Shift+Alt")         xdotool key j; ;; # Unselect occurrence
                    "Shift+Control+Alt") xdotool key j; ;; # Select all occurrences

                    "Shift")   xdotool key F3; ;; # Find previous
                    "Control") xdotool key F3; ;; # Find word at caret
                    *)         xdotool key F3; ;; # Find next
                esac
                ;;
        esac
        ;;
esac
