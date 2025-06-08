#!/bin/bash

set -eu

heading() {
  echo -e "\n\033[33;1m$@\033[0m"
}

if ! command -v rustc > /dev/null; then
  heading "Installing Rust compiler"
  rustup toolchain install stable
fi

cargo install \
  bkt \
  cargo-edit

cargo install --locked yazi-fm yazi-cli
