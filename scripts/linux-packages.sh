#!/bin/bash

set -euo pipefail

heading() {
  echo -e "\033[33;1m$@\033[0m"
}

if [ $(uname -s) = "Linux" ]; then
  # List installed packages on the system
  # $ apt --installed list | grep -v automatic

  heading "Linux packages: apt update"
  sudo apt update

  heading "Linux packages: apt install"

  packages=(
      bat
      binwalk
      btop
      colordiff
      d-feet
      entr
      exiftool
      fd-find
      fdupes
      flatpak
      fzf
      gimp
      graphviz
      htop
      inkscape
      iotop
      ipython3
      irssi
      jq
      ncdu
      nmap
      pandoc
      pdftk
      qrencode
      ripgrep
      rofi
      spotify-client
      sqlite3
      tzwatch
      vlc
      wireshark
      wmctrl
      youtube-dl
  )

  sudo apt install --assume-yes ${packages[@]}

  heading "Linux packages: flatpak"
  flatpak remote-add --if-not-exists \
    flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  # Pomodoro timer
  flatpak install flathub org.gnome.Solanum
fi
