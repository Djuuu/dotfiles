#!/usr/bin/env bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

lightblue='\e[94m'
reset='\e[0m'

while IFS= read -r -d '' filePath
do
  srcFileName=$(basename "$filePath")
  dstFilePath="${BASEDIR}/${srcFileName%.example}"
  dstFilePathName="${dstFilePath/#${HOME}/'~'}"

  if [[ ! -f "$dstFilePath" ]]; then
    echo -e "${lightblue}  Creating file ${dstFilePathName}${reset}"
    cp "$filePath" "$dstFilePath"
  else
    echo -e "${lightblue}  File exists ${dstFilePathName}${reset}"
  fi

done < <(find "$BASEDIR/" -iname "*.local.example" -print0)
