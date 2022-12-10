#!/usr/bin/env bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Initializing local files"

while IFS= read -r -d '' filePath
do
  srcFileName=$(basename "$filePath")
  dstFileName="${srcFileName%.example}"

  if [[ ! -f ~/"${dstFileName}" ]]; then
    cp "$filePath" ~/"${dstFileName}"
    echo "  Initialized ~/${dstFileName}"
  else
    echo "  ~/${dstFileName} already exists"
  fi

done < <(find "$BASEDIR" -iname "*.local.example" -print0)
