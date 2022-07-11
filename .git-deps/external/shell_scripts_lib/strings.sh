#!/bin/bash

# Title         String utilities for common string manipulation actions
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Use this file instead of searching how to perform string
#               manipulation all over again
#==============================================================================

CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")

#######################################
# Split a string by a delimiter
# Globals:
#   None
# Arguments:
#   str        - string to manipulate
#   delimiter  - (optional) delimiter to use
# Usage:
#   split_newlines_by_delimiter "one two three"
#   split_newlines_by_delimiter "one;two;three" ";"
#######################################
split_newlines_by_delimiter() {
  local str=$1
  local delimiter=$2

  # By default use space as delimiter
  if [[ -z "${delimiter}" ]]; then
    delimiter=" "
  fi

  echo ${str} | tr "${delimiter}" '\n'
}
