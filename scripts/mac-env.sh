set -e

# Only on Mac
if [ `uname -s` = "Darwin" ]
then

heading() {
  echo -e "\033[33;1m$@\033[0m"
}

# Set computer hostname if needed
setHostname() {
    sudo scutil --set ComputerName "$1"
    sudo scutil --set HostName "$1"
    sudo scutil --set LocalHostName "$1"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$1"
}

PlistDefine() {
    local name="$1"
    local type="$2"
    local value="$3"
    local file="$4"
    if ! PlistBuddy -c "print $name" "$file" > /dev/null 2>&1
    then
        PlistBuddy -c "Add $name $type $value" "$file"
    else
        PlistBuddy -c "Set $name $value" "$file"
    fi
}


heading "Setting up mac environment"

# Use Dark Mojave theme
defaults write -g AppleInterfaceStyle Dark

# Show scroll bars when scrolling
defaults write -g AppleShowScrollBars Automatic

# Do not automatically switch to a space with the open windows for the application
defaults write -g AppleSpacesSwitchOnActivate -bool false


# Fix the mouse scrolling
defaults write -g com.apple.swipescrolldirection -bool false

# Save screenshots into Downloads folder
defaults write com.apple.screencapture location ~/Downloads

# Remove items from the menubar
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.appleuser" -bool false
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.bluetooth" -bool false

defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.Spotlight "NSStatusItem Visible Item-0" -bool false
defaults write com.apple.airplay showInMenuBarIfPresent -bool false

defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Clock" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible DoNotDisturb" -bool true
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true

defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible KeyboardBrightness" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible UserSwitcher" -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Set screensaver to Flurry
# Preference is stored in ByHost folder so -currentHost is required
defaults -currentHost write com.apple.screensaver moduleDict -dict \
    moduleName Flurry path "/System/Library/Screen Savers/Flurry.saver" type 0
# Show clock on the screensaver
defaults -currentHost write com.apple.screensaver showClock -int 1

# Disable chime noise when plugging in power charger
# (source: https://apple.stackexchange.com/a/309947/327859)
# To make it take effect: killall PowerChime
# NOTE: this works only when the user is logged in. It does not work when the
# laptop lid is closed
defaults write com.apple.PowerChime ChimeOnNoHardware -bool true

# Keyboard mappings (CapsLock -> ESC) are per keyboard.
# The mapping includes the vendor id and product id of the keyboard which
# obviously varies for each type of the keyboard. Instead of hardcoding the
# values here, just check if there are any existing ones otherwise instruct
# user to change it.
# More context: https://apple.stackexchange.com/q/4813
if ! defaults -currentHost read -g | grep -q com.apple.keyboard.modifiermapping
then
    heading "Please map CapsLock to ESC in System Preferences -> Keyboard > Modifier keys"
    exit 1
fi

# Disable automatic text corrections
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g WebAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticTextCompletionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# Tab should focus for everything
defaults write -g AppleKeyboardUIMode -int 2

# Set fast key repeat rate
defaults write -g KeyRepeat -int 6
defaults write -g InitialKeyRepeat -int 15

## Trackpad
# Allow tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Disable UI sound effects
defaults write -g com.apple.sound.uiaudio.enabled -bool false

# Disable feedback when volume is changed
defaults write -g com.apple.sound.beep.feedback -bool false

# Show volume in menubar
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.volume" -bool true

# Set the format of clock to something like "7 Feb 22:57"
defaults write com.apple.menuextra.clock DateFormat "d MMM HH:mm"

# Show battery percentage in the menu
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Setting the wallpaper
WALLPAPER="$HOME/Documents/wallpaper.jpg"
if [ -f "$WALLPAPER" ]
then
    heading "Setting the wallpaper"
    osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER\""
else
    echo "No wallpaper, skipping"
fi

heading "Dock"
# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Put dock on the left side
defaults write com.apple.dock orientation -string left

# Make the icons smaller
defaults write com.apple.dock tilesize -int 31

# Make the icons smaller
defaults write com.apple.dock "show-recents" -int 0

heading "Hot corners"
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard (dashboard was deprecated)
# 10: Put display to sleep
# 11: Launchpad
# 12: Notifications center
# Top left: Mission control
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right: Notifications center
defaults write com.apple.dock wvous-tr-corner -int 12
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left: Put display to sleep
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
# Bottom right: no-op
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

killall -HUP Dock

heading "Finder"

# Show `Library` folder
chflags nohidden ~/Library/

# Prevent .DS_Store on network & USB disks
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRecentTags -bool false

# By default open Downloads folder
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads"

# When searching, search the current folder
# SCev -> This Mac
# SCcf -> Current Folder
# SCsp -> Previous Scope
defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'

# Set the preferred view
# Flwv -> Cover Flow View
# Nlsv -> List View
# clmv -> Column View
# icnv -> Icon View
defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'

# Sort folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Show all filename extensions
defaults write -g AppleShowAllExtensions -bool true

# Show the full path in title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Writing of .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

defaults write com.apple.finder "NSToolbar Configuration Browser" '{
    "TB Default Item Identifiers" = (
        "com.apple.finder.BACK",
        NSToolbarFlexibleSpaceItem,
        "com.apple.finder.SWCH",
        "com.apple.finder.ARNG",
        "com.apple.finder.ACTN",
        "com.apple.finder.SHAR",
        "com.apple.finder.LABL",
        NSToolbarFlexibleSpaceItem,
        NSToolbarFlexibleSpaceItem,
        "com.apple.finder.SRCH"
    );
    "TB Display Mode" = 2;
    "TB Icon Size Mode" = 1;
    "TB Is Shown" = 1;
    "TB Item Identifiers" = (
        "com.apple.finder.BACK",
        "com.apple.finder.PATH",
        NSToolbarFlexibleSpaceItem,
        "com.apple.finder.SWCH",
        "com.apple.finder.ACTN",
        "com.apple.finder.NFLD",
        "com.apple.finder.TRSH",
        NSToolbarFlexibleSpaceItem,
        "com.apple.finder.SRCH"
    );
    "TB Size Mode" = 1;
}'

killall Finder

heading "Enable night shift"
USER_UID="$(dscl . -read ~ GeneratedUID | sed 's/GeneratedUID: //')"
NIGHTSHIFT_FILE="/var/root/Library/Preferences/com.apple.CoreBrightness.plist"
NIGHTSHIFT_CONFIG='{
  CBBlueLightReductionCCTTargetRaw = 3089.0;
  CBBlueReductionStatus = {
    AutoBlueReductionEnabled = 1;
    BlueLightReductionAlgoOverride = 0;
    BlueLightReductionDisableScheduleAlertCounter = 3;
    BlueLightReductionSchedule = {
      DayStartHour = 6;
      DayStartMinute = 0;
      NightStartHour = 19;
      NightStartMinute = 0;
    };
    BlueReductionAvailable = 1;
    BlueReductionEnabled = 0;
    BlueReductionMode = 2;
    BlueReductionSunScheduleAllowed = 0;
    Version = 1;
  };
}'

sudo defaults write $NIGHTSHIFT_FILE "CBUser-0" "$NIGHTSHIFT_CONFIG"
sudo defaults write $NIGHTSHIFT_FILE "CBUser-${USER_UID}" "$NIGHTSHIFT_CONFIG"

heading "Evernote"
# Show note counts in sidebar
defaults write com.evernote.Evernote ENLeftNavShowsNoteCounts -int 1

# Start evernote on the login
defaults write com.evernote.Evernote runAtLogin -int 1

# Do not play sound after clip
defaults write com.evernote.Evernote ENPlaySoundAfterClip -int 0

if ! lpstat -p > /dev/null
then
    heading "No printer. Please add one"
    exit 1
fi

fi
