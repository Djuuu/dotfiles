#!/usr/bin/env bash

echo "Installing fonts"

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

echo "CascadiaMono NerdFont"
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.tar.xz
tar xf CascadiaMono.tar.xz
rm CascadiaMono.tar.xz
rm CaskaydiaMonoNerdFontPropo*
rm CaskaydiaMonoNerdFontMono*

echo "JetBrainsMono NerdFont"
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar xf JetBrainsMono.tar.xz
rm JetBrainsMono.tar.xz
rm JetBrainsMonoNerdFontPropo*
rm JetBrainsMonoNerdFontMono*

cd -
