#!/bin/bash

set -euo pipefail

# Only on Mac
if [ `uname -s` = "Darwin" ]
then

heading() {
  echo -e "\033[33;1m$@\033[0m"
}

heading "Installing Mac dev tools"
if /usr/bin/xcode-select --install 2>/dev/null
then
    heading "Press enter once tools are installed"
    read
fi

# A new installation might not have correct PATH yet: hardcode path
BREW=/opt/homebrew/bin/brew

if [[ ! -x "$BREW" ]] ; then
    heading "Installing brew"
    /bin/bash -c "$(curl -fsSL \
      https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

heading "Brew cleanup"
$BREW cleanup
heading "Brew update"
$BREW update

heading "Installing packages from ~/.Brewfile"
$BREW bundle --global --no-upgrade

# Installing pdftk which is not on Homebrew. Long time no updates. I might need
# to eventually switch to `pdftk-java`
if ! pkgutil --packages | grep -q  com.pdflabs.pdftkThePdfToolkit
then
  heading "Installing PDFtk"
  echo
  echo "Might require installing rosetta:"
  echo "  sudo softwareupdate --install-rosetta"

  curl -o /tmp/pdftk_download.pkg \
      https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg
  sudo installer -pkg /tmp/pdftk_download.pkg -target /
fi

fi
