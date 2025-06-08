#!/bin/bash
#
# Configure GNOME environment
#
# Difference between gsettings and dconf:
# https://www.reddit.com/r/gnome/comments/waqpvc/gsettings_vs_dconf/
#
# It is easy to find the changed keys by running:
# $ dconf dump
#
# To convert it into gsettings, replace the key in the following format
# dconf:     /org/gnome/desktop/background/picture-uri
# gsettings:  org.gnome.desktop.background picture-uri

set -eu

heading() {
  echo -e "\n\033[33;1m$@\033[0m"
}

if [ $(uname -s) = "Linux" ]; then
  heading "GNOME"

  # Convert caps lock into escape
  # http://gist.github.com/lboulard/335822a9355f3d122191c2a99e516855
  # https://askubuntu.com/questions/363346/how-to-permanently-switch-caps-lock-and-esc
  gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"

  gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Control><Alt><Super>l']"

  # Hide the accessibility button
  gsettings set org.gnome.desktop.a11y always-show-universal-access-status false

  gsettings set org.gnome.desktop.interface clock-show-seconds false
  gsettings set org.gnome.shell.world-clocks locations "[
  <(uint32 2, <('San Francisco', 'KOAK', true, [(0.65832848982162007, -2.133408063190589)], [(0.659296885757089, -2.1366218601153339)])>)>,
  <(uint32 2, <('New York', 'KNYC', true, [(0.71180344078725644, -1.2909618758762367)], [(0.71059804659265924, -1.2916478949920254)])>)>,
  <(uint32 2, <('Bangalore', 'VOBG', true, [(0.22601989378717041, 1.3555659188172149)], [(0.22631101470640302, 1.3537937114947398)])>)>]"

  # Panels
  gsettings set org.gnome.shell.extensions.dash-to-panel panel-positions '{"0":"TOP","1":"TOP"}'
  gsettings set org.gnome.shell.extensions.dash-to-panel panel-sizes '{"0":24,"1":24}'
  gsettings set org.gnome.shell.extensions.dash-to-panel dot-position 'TOP'
  gsettings set org.gnome.shell.extensions.dash-to-panel scroll-panel-action 'NOTHING'
  gsettings set org.gnome.shell.extensions.dash-to-panel panel-element-positions '{"0":[
    {"element":"showAppsButton","visible":false,"position":"centered"},
    {"element":"activitiesButton","visible":false,"position":"stackedTL"},
    {"element":"leftBox","visible":true,"position":"stackedTL"},
    {"element":"taskbar","visible":true,"position":"stackedTL"},
    {"element":"dateMenu","visible":true,"position":"centered"},
    {"element":"centerBox","visible":false,"position":"stackedBR"},
    {"element":"rightBox","visible":true,"position":"stackedBR"},
    {"element":"systemMenu","visible":true,"position":"stackedBR"},
    {"element":"desktopButton","visible":false,"position":"stackedBR"}]}'

  # Workspaces
  # Have fixed amount of workspaces
  gsettings set org.gnome.mutter dynamic-workspaces false
  # All monitors share the workspace
  gsettings set org.gnome.mutter workspaces-only-on-primary false
  # When switching, show only windows from the current workspace
  gsettings set org.gnome.shell.app-switcher current-workspace-only true
  # 2 workspaces of them
  gsettings set org.gnome.desktop.wm.preferences num-workspaces 2

  # Pinned apps (the chrome app is a chat)
  gsettings set org.gnome.shell favorite-apps \
    "['google-chrome.desktop', 'org.gnome.Terminal.desktop', 'chrome-mdpkiolbdkhdjpekfbkbmhigcaggjagi-Profile_1.desktop', 'intellij-ce-stable.desktop', 'org.gnome.Nautilus.desktop']"

  wallpaper="$HOME/files/wallpapers/shoebill.jpg"
  if [ -f "$wallpaper" ]; then
    wallpaper="file://$wallpaper"
    heading "Wallpaper"
    gsettings set org.gnome.desktop.background picture-uri "$wallpaper"
    gsettings set org.gnome.desktop.background picture-uri-dark "$wallpaper"
    gsettings set org.gnome.desktop.background primary-color '#000000000000'
    gsettings set org.gnome.desktop.background secondary-color '#000000000000'
    gsettings set org.gnome.desktop.screensaver picture-uri "$wallpaper"
    gsettings set org.gnome.desktop.screensaver primary-color '#000000000000'
    gsettings set org.gnome.desktop.screensaver secondary-color '#000000000000'
  fi
fi
