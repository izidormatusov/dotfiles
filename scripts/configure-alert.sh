#!/bin/bash
#
# Set keyring credentials for telegram to power alert manager

set -euo pipefail

heading() {
  echo -e "\033[33;1m$@\033[0m"
}

if [ -d "$PASSWORD_STORE_DIR" ]; then

if [ `uname -s` = "Darwin" ]; then
  heading "Setting telegram credentials for alert on MacOS"
  security add-generic-password -U -s alert -a telegram_bot_id -w $(pass home/devbot-telegram | sed -n 1p)
  security add-generic-password -U -s alert -a telegram_chat_id -w $(pass home/devbot-telegram | sed -n 2p)
elif [ `uname -s` = "Linux" ]; then
  heading "Setting telegram credentials for alert on Linux"
  pass home/devbot-telegram | sed -n 1p | keyring set alert telegram_bot_id
  pass home/devbot-telegram | sed -n 2p | keyring set alert telegram_chat_id
fi

fi
