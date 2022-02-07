set -e

heading() {
  echo -e "\033[33;1m$@\033[0m"
}

heading "Installing Python packages"

pip3 install \
  ipython \
  ipdb \
  pudb \
  requests
