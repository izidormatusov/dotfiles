#!/bin/bash
#
# Automatically calculate the diff in defaults. Useful when trying to find
# setting changed after touching it in UI

print_settings() {
  defaults read -g
  defaults read
  defaults -currentHost read
}

FOLDER=$(mktemp -d -t diff_defaults)
NEW="$FOLDER/new"
OLD="$FOLDER/old"
cd $FOLDER

echo
echo -e "\033[33mFetching the current defaults\033[0m"
print_settings > $OLD

while true; do
  echo
  echo -en "Press enter for the new read "
  read
  [ -f new ] && mv $NEW $OLD
  print_settings > $NEW

  vimdiff $OLD $NEW || break
done

rm -r $FOLDER
