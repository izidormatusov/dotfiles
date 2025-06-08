#!/bin/bash

set -eu

heading() {
  echo -e "\n\033[33;1m$@\033[0m"
}

heading "Installing go"

go install golang.org/x/tools/cmd/godoc@latest
go install github.com/codegangsta/gin@latest
