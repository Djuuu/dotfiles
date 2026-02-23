#!/usr/bin/env bash

dir="${HOME}/.ssh/ssh_config.d"

if [ -d "${dir}/.git" ]; then
    git -C "${dir}" pull
fi
