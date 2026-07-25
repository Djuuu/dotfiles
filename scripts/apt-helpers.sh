#!/usr/bin/env bash

green='\e[32m'
lightgreen='\e[92m'
lightblue='\e[94m'
lightpurple='\e[95m'
reset='\e[0m'

# .deb asset patterns, per repo - see https://github.com/<repo>/releases/latest
declare -A APT_GITHUB_PACKAGES=(
                ['sharkdp/bat']="bat_.*_{ARCH}.deb\$"            # avoid bat-musl
           ['dandavison/delta']="git-delta_.*{ARCH}.deb\$"       # avoid git-delta-musl
          ['quantumsheep/sshs']="sshs-linux-{ARCH}.deb\$"
    ['fastfetch-cli/fastfetch']="fastfetch-linux-{ARCH}.deb\$"
               ['junegunn/fzf']="fzf_.*{ARCH}.deb\$"
                 ['rtk-ai/rtk']="rtk_.*{ARCH}.deb\$"
         ['burntsushi/ripgrep']="ripgrep_.*{ARCH}.deb\$"
                 ['sharkdp/fd']="fd_.*{ARCH}.deb\$"              # avoid fd-musl
)

# binary names, when differing from the repo name
declare -A APT_GITHUB_BINARIES=(
    ['burntsushi/ripgrep']="rg"
)

# post-install steps, per binary - `apt-post-install-<bin>`, called when defined
apt-post-install-bat() {
    unalias bat 2>/dev/null || true

    # bat-extras is user-owned: drop back to the invoking user when running under sudo
    local as_user=() home="$HOME"
    if [[ $EUID -eq 0 && -n ${SUDO_USER:-} ]]; then
        as_user=(sudo --user "$SUDO_USER")
        home="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
    fi

    [[ -d "./lib/bat-extras" ]] || {
        "${as_user[@]}" git clone https://github.com/eth-p/bat-extras.git ./lib/bat-extras
        "${as_user[@]}" ./lib/bat-extras/build.sh --minify=none --install --prefix "$home/.local"
    }
}
apt-post-install-rtk() {
    echo -e "${lightblue}  To initialize rtk, run:\n    ${reset}rtk init -g"
}

apt-install-github() {
    local repo="$1"
    local opts="${*:2}"
    local name bin match

    name="$(basename "$repo")"

    bin="${APT_GITHUB_BINARIES[$repo]:-$name}"
    match="${APT_GITHUB_PACKAGES[$repo]:-}"

    if [[ ! -x "$(command -v "$bin")" || $opts =~ "--force" ]]; then
        echo -e "${lightgreen}Installing ${repo}${reset}"
        apt-install-github-release "$repo" "$match" "$opts"
        printf "  ${lightblue}Installed %-10s : %s${reset}\n" "$name" "$($bin --version | head -n 1)"

        if declare -F "apt-post-install-${bin}" >/dev/null; then "apt-post-install-${bin}"; fi

    elif [[ $opts =~ "-V" ]]; then
        printf "  ${lightblue}Installed %-10s : %s${reset}\n" "$name" "$($bin --version | head -n 1)"
    fi
}

apt-install-github-release() {
    local repo="$1"
    local match="$2"
    local opts="${*:3}"

    local name; name="$(basename "$repo")"

    # compute arch
    local dpkg_arch syst_arch
    dpkg_arch=$(dpkg --print-architecture) || {
        echo "dpkg not found" >&2
        return 1
    }
    syst_arch=$(uname -m)

    # compute matching regex
    [[ -z $match ]] && match="${name}[-_].*{ARCH}.deb\$"
    match=${match/"{ARCH}"/"(${dpkg_arch}|${syst_arch})"}

    [[ $opts =~ "--verbose" ]] && printf "  ${lightblue}matching: /%s/${reset}\n" "$match"

    # get release info
    local latest_release_url="https://api.github.com/repos/${repo}/releases/latest"
    local auth=() # authenticate when possible
    [[ -n ${GITHUB_TOKEN:-} ]] && auth=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
    local release_data; release_data=$(curl --silent --location "${auth[@]}" "$latest_release_url")

    [[ -n $release_data ]] || {
        echo "Error getting release data from ${latest_release_url}" >&2
        return 1
    }

    local pkg_url; pkg_url=$(echo "${release_data}" \
        | jq -r "[.assets[] | select(.name? | match(\"${match}\")) | .browser_download_url][0]")

    [[ -n $pkg_url && $pkg_url != null ]] || {
        echo "  No package found for '${repo}' on arch '${syst_arch}' ('${dpkg_arch}')" >&2
        echo "    https://github.com/${repo}/releases/latest" >&2
        return 1
    }

    # download
    [[ $opts =~ "--verbose" ]] && printf "  ${lightblue}downloading %s${reset}\n" "$pkg_url"

    local pkg_file; pkg_file=$(basename "${pkg_url}")
    curl --fail --silent --show-error --location --remove-on-error \
        --output "/tmp/${pkg_file}" \
        "${pkg_url}" || {
        echo "Error downloading: ${pkg_url}" >&2
        return 1
    }

    # install
    [[ $opts =~ "--verbose" ]] && printf "  ${lightblue}installing %s${reset}\n" "/tmp/${pkg_file}"

    apt install -y "/tmp/${pkg_file}"

    # cleanup
    rm "/tmp/${pkg_file}"
}
