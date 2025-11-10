#!/usr/bin/env bash

catppuccin_module_header() {
    local module=$1

    echo -n "#[fg=#{E:@catppuccin_status_${module}_icon_bg}]"
    echo -n "#{E:@catppuccin_status_left_separator}"
    echo -n "#[fg=#{E:@catppuccin_status_${module}_icon_fg},bg=#{E:@catppuccin_status_${module}_icon_bg}]"
    echo -n "#{E:@catppuccin_${module}_icon}"
    echo -n "#{E:@catppuccin_status_middle_separator}"
    echo -n "#[fg=#{E:@catppuccin_status_${module}_text_fg},bg=#{E:@catppuccin_status_module_text_bg}]"
}

catppuccin_module_footer() {
    echo -n "#[fg=#{E:@catppuccin_status_module_text_bg}]"
    echo -n "#{?#{==:#{@catppuccin_status_connect_separator},yes},,#[bg=default]}"
    echo -n "#{E:@catppuccin_status_right_separator}"
}
