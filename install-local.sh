#!/usr/bin/env bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Initializing local files"

while IFS= read -r -d '' filePath
do
  srcFileName=$(basename "$filePath")
  dstFileName="${srcFileName%.example}"
  dstFilePath="${BASEDIR}/${srcFileName%.example}"

  if [[ ! -f "$dstFilePath" ]]; then
    cp "$filePath" "$dstFilePath"
    echo "  Initialized ${dstFilePath}"
  else
    echo "  ${dstFilePath} already exists"
  fi

done < <(find "$BASEDIR/" -iname "*.local.example" -print0)
