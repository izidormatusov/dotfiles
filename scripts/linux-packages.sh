set -e
if [ `uname -s` = "Linux" ]
then

heading() {
  echo -e "\033[33;1m$@\033[0m"
}

# List installed packages on the system
# $ apt --installed list | grep -v automatic

heading "Linux packages: apt update"
sudo apt update

heading "Linux packages: apt install"
sudo apt install --assume-yes \
    binwalk \
    colordiff \
    d-feet \
    entr \
    exiftool \
    fdupes \
    fzf \
    gimp \
    graphviz \
    htop \
    inkscape \
    iotop \
    ipython3 \
    irssi \
    jq \
    nmap \
    pandoc \
    pdftk \
    ripgrep \
    spotify-client \
    tzwatch \
    vlc \
    wireshark \
    wmctrl \
    youtube-dl

fi
