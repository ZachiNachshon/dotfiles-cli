#!/bin/bash

# Title         Tests assertions
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Assertion functions used by testing suites
#=================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")

source "${CURRENT_FOLDER_ABS_PATH}/test_logs.sh"
source "${ROOT_FOLDER_ABS_PATH}/strings.sh"
source "${ROOT_FOLDER_ABS_PATH}/logger.sh"
source "${ROOT_FOLDER_ABS_PATH}/io.sh"

assert_expect_log() {
  local pattern=$1
  local default_msg="""Expected regexp pattern not found - 
${COLOR_RED}${pattern}${COLOR_NONE}"""
  local message=${2:-${default_msg}}

  grep -sq -- "${pattern}" "${TEST_log}" && return 0

  test_log_fail "\nAssertion error: ${message}"
  return 1
}

assert_expect_log_exact_text() {
  local text=$1
  local default_msg="""Expected exact text not found - 
${COLOR_RED}${text}${COLOR_NONE}"""
  local message=${2:-${default_msg}}

  is_text_equal "${text}" "$(cat ${TEST_log})" && return 0

  test_log_fail "\nAssertion error: ${message}"
  return 1
}

assert_not_expect_log() {
  local pattern=$1
  local default_msg="""Found a regexp pattern that should not exist - 
${COLOR_RED}${pattern}${COLOR_NONE}"""
  local message=${2:-${default_msg}}
  grep -sqv -- "${pattern}" "${TEST_log}" && return 0

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
