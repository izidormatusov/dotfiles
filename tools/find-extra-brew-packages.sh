#!/bin/bash
# Detect what packages have not been installed

set -e

set -xv

comm -13 > /tmp/brew.pkg.extra \
  <(sed -n -e 's/^brew "\([^"]*\)".*/\1/p' ~/.Brewfile | sort ) \
  <(brew leaves | sort)

if [ -s /tmp/brew.pkg.extra ]
then
  echo -e "Extra packages\033[31m"
  cat /tmp/brew.pkg.extra
  echo -e "\033[0m"
fi

comm -13 > /tmp/brew.cask.extra \
  <(sed -n -e 's/^cask "\([^"]*\)".*/\1/p' ~/.Brewfile | sort ) \
  <(brew ls --cask | sort)

if [ -s /tmp/brew.cask.extra ]
then
  echo -e "Extra casks\033[31m"
  cat /tmp/brew.cask.extra
  echo -e "\033[0m"
fi

rm /tmp/brew.{pkg,cask}.extra
