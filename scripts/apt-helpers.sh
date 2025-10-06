#!/usr/bin/env bash

apt_install_github_release() {
    local repo="$1"
    local match="${2:-'.*amd64.deb$'}"

    local dpkg_arch syst_arch
    dpkg_arch=$(dpkg --print-architecture) || {
        echo "dpkg not found"
        return 1
    }
    syst_arch=$(uname -m)
    match=${match/"{ARCH}"/"(${dpkg_arch}|${syst_arch})"}

    local release_data
    release_data=$(curl -sL "https://api.github.com/repos/${repo}/releases/latest")

    local pkg_url
    pkg_url=$(echo "${release_data}" |
        jq -r ".assets[] | select(.name? | match(\"${match}\")) | .browser_download_url")

    [[ -n $pkg_url ]] || {
        echo "No package found for '${repo}' on arch '${syst_arch}' ('${dpkg_arch}')"
        return 1
    }

    local pkg_file
    pkg_file=$(basename "${pkg_url}")

    wget -P /tmp/ "${pkg_url}"
    apt install -y "/tmp/${pkg_file}"
    rm "/tmp/${pkg_file}"
}
