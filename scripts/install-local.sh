#!/usr/bin/env bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR="${BASEDIR%/scripts}"


lightblue='\e[94m'
lightpurple='\e[95m'
reset='\e[0m'

# Init .local files
while IFS= read -r -d '' filePath
do
    srcFileName=$(basename "$filePath")
    dstFilePath="$(dirname "$filePath")/${srcFileName%.example}"
    dstFilePathName="${dstFilePath/#${HOME}/'~'}"

    if [[ ! -f "$dstFilePath" ]]; then
        echo -e "${lightblue}  Creating file ${dstFilePathName}${reset}"
        cp "$filePath" "$dstFilePath"
    else
        echo -e "${lightblue}  File exists ${dstFilePathName}${reset}"
    fi

done < <(find "$BASEDIR/" -iname "*.local.example" -print0)


# Init Git-Fork custom commands link (for easier editing comparing to .example)
if [[ -x $(command -v powershell.exe) ]]; then
    winUser=$(powershell.exe '$env:UserName' | tr -d '\r\n')
    case "$(uname -s)" in
        CYGWIN*|MINGW*) c="/c"     ;;
        *)              c="/mnt/c" ;;
    esac

    src="${c}/Users/${winUser}/AppData/Local/Fork/custom-commands.json"
    dst="${HOME}/.dotfiles/config/Fork/custom-commands.json"

    srcName=${src/#"${c}/Users/${winUser}/AppData/Local"/'%localappdata%'}
    dstName=${dst/#${HOME}/'~'}

    if [[ ! -f "${dst}" ]]; then
        if [[ -f "$src" ]]; then
            echo -e "${lightblue}  Linking ${dstName} -> ${srcName}${reset}"
            ln -sf "$src" "$dst"
        else
            echo -e "${lightpurple}  ${srcName} not found${reset}"
        fi
    else
        echo -e "${lightblue}  Link exists ${dstName} -> ${srcName}${reset}"
    fi
else
    echo -e "  ${lightpurple}powershell.exe not found or not executable${reset}"
fi
