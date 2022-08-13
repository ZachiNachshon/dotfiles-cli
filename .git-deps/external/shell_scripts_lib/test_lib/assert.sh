#!/bin/bash

# Title         Tests assertions
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Assertion functions used by testing suites
#=================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")

source "${CURRENT_FOLDER_ABS_PATH}/test_logs.sh"
source "${ROOT_FOLDER_ABS_PATH}/io.sh"

assert_expect_log() {
  local pattern=$1
  local default_msg="""Expected regexp pattern not found - 
${pattern}"""
  local message=${2:-${default_msg}}
  grep -sq -- "${pattern}" "${TEST_log}" && return 0

  test_log_fail "\nAssertion error: ${message}"
  return 1
}

assert_expect_folder() {
  local path=$1
  local message=${2:-"Expected folder not found. path: '${path}'"}
  if ! is_directory_exist "${path}"; then
    test_log_fail "\nAssertion error: ${message}"
    return 1
  fi
  return 0
}
