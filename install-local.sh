#!/usr/bin/env bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for file_name in \
	".bashrc.local" \
	".gitconfig.local" \
	".gitconfig.url.local"
do
	if [ ! -f ~/${file_name} ]; then
		cp ${BASEDIR}/${file_name} ~/${file_name}
		echo "Initialized ~/${file_name}"
	else
		echo "~/${file_name} already exists"
	fi
done
