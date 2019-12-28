#!/usr/bin/env bash

button=$1
modifiers=$2

# https://askubuntu.com/questions/97213/application-specific-key-combination-remapping
Wid=`xdotool getactivewindow`
Wname=`xprop -id ${Wid} |awk '/WM_CLASS/{print $4}'`

########################################################################################################################
# Logitech MX Master 3 wrapper script for use with xbindkeys
#
# Available buttons:
#
#   Thumb
#   Scroll_L
#   Scroll_R
#   Back
#   Forward
#
# Window names:
#
#   '"Firefox"'
#   '"Google-chrome"'
#   '"jetbrains-phpstorm"'
#   '"Gnome-terminal"'
#   '"GitKraken"'
#
# Modifiers:
#
#   "Shift"
#   "Control"
#   "Alt"&
#   "Shift+Control"
#   "Shift+Alt"
#   "Control+Alt"
#   "Shift+Control+Alt"
#

## Debug (for use with `xbindkeys -v`)
# echo "modifiers Wname:$Wname ; button:$button ; modifiers:$modifiers"

case "$button" in

    "Thumb")
        # xdotool key --clearmodifiers --delay 6 super+s ; # Overview

        # Open Gnome overview programmatically (Thumb button sends Super_L on release, which might break any super-based shortcut depending on timing)
        # https://askubuntu.com/questions/1095553/invoking-gnome-activities-overview-from-command-line/1095614#1095614
        dbus-send --session --type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'Main.overview.toggle();'

        xdotool keyup --delay 100 shift+ctrl+alt+super; # ensure modifiers reset
        ;;

    "Scroll_L")
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

    "Scroll_R")
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
            '"Firefox"' | '"Google-chrome"')
                xdotool key F12 # Developer tools
                ;;
            '"jetbrains-phpstorm"')
                case "$modifiers" in

                    "Shift")             ;;
                    "Control")           ;;
                    "Shift+Control")     ;;
                    "Shift+Alt")         ;;
                    "Shift+Control+Alt") ;;

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
