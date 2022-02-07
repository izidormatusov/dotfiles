set -e

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

if ! command -v brew >/dev/null
then
    heading "Installing brew"
    /usr/bin/ruby -e "$(curl -fsSL \
      https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

heading "Fixing permissions for brew"
sudo chown -R $(whoami) \
  /usr/local/bin \
  /usr/local/etc \
  /usr/local/sbin \
  /usr/local/share \
  /usr/local/share/doc

heading "Brew cleanup"
brew cleanup
heading "Brew update"
brew update

heading "Installing packages from ~/.Brewfile"
brew bundle --global --no-upgrade

# Installing pdftk which is not on Homebrew
if ! pkgutil --packages | grep -q  com.pdflabs.pdftkThePdfToolkit
then
  heading "Installing PDFtk"
  curl -o /tmp/pdftk_download.pkg \
      https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg
  sudo installer -pkg /tmp/pdftk_download.pkg -target /
fi

fi
