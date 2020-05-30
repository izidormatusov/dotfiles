#!/bin/bash

CONFIG_SET="${1:-all}"

# By default exit by error
set -e

# Check if this is a MacOS machine
[ `uname -s` = "Darwin" ] && IS_MAC="true" || IS_MAC="false"
