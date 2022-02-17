#!/bin/sh

[ "${SHELL##/*/}" != "zsh" ] && echo "You might need to change default shell to zsh: `chsh -s /bin/zsh`"

dir="$HOME/dotfiles/"
fontdir="$HOME/dotfiles/fonts"

mkdir -p "$dir"

cd "$dir" || exit
git clone --recursive https://github.com/kanariezwart/dotfiles.git .

## install fonts in fonts dir
git clone https://github.com/powerline/fonts.git --depth=1 "${fontdir}"
cd "${fontdir}" || exit
./install.sh

## symlink dotfiles into home folder
