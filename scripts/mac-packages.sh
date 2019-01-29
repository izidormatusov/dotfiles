PlistBuddy="/usr/libexec/PlistBuddy"
MUNKI_FILE="/Library/Managed Installs/manifests/SelfServeManifest"


# Add a package to list of apps to be installed
# Credits to https://technology.siprep.org/terminal-command-to-mark-a-munki-optional-install-for-installation/
install_managed_software() {
    local pkg="$1"
    if ! $PlistBuddy -c print:managed_installs "$MUNKI_FILE" | grep -q "$pkg"
    then
        sudo $PlistBuddy -c "Add :managed_installs: string '$pkg'" "$MUNKI_FILE"
    fi
}


if [ "$IS_MAC" = "true" ]
then

# Munki is "Managed Software" app on Mac.
# https://github.com/munki/munki
# Install "Optional software" from the catalogue
if [ -d "/usr/local/munki" ]
then
    echo "Installing managed software packages"
    install_managed_software "Cyberduck"
    install_managed_software "Firefox"
    install_managed_software "GIMP"
    install_managed_software "Google OpenVPN"
    install_managed_software "MacVim"
    install_managed_software "SnipIt"
    install_managed_software "Spectacle"
    install_managed_software "VLC media player"
    install_managed_software "Wireshark"
    install_managed_software "XQuartz"
    install_managed_software "detangle"
    install_managed_software "iTerm2"
    install_managed_software "tmux"

    echo "Update managed software list"
    sudo /usr/local/munki/managedsoftwareupdate
    echo "Install managed software"
    sudo /usr/local/munki/managedsoftwareupdate --installonly
fi

fi
