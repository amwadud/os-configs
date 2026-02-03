# Create for me a script that installs the configs on an arch linux system

#!/bin/bash

echo "Updating system and installing packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm \
    zsh \
    git \
    neovim \
    tmux \
    fzf \
    ripgrep \
    starship \
    alacritty \
    htop

cp -r ./configs/. ~/configs/
