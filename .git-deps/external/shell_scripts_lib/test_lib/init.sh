#!/bin/bash

# Title         Tests setups
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Initialize a test setup before running tests suite
#=================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")

source "${CURRENT_FOLDER_ABS_PATH}/test_logs.sh"
source "${ROOT_FOLDER_ABS_PATH}/logger.sh"
source "${ROOT_FOLDER_ABS_PATH}/io.sh"

_clean_test_environment() {
  new_line
  # Clean TEST_TMPDIR and verify path contains an identifier before deletion
  if is_directory_exist "${TEST_TMPDIR}" && [[ "${TEST_TMPDIR}" == *"shell-scripts-lib-tests"* ]]; then
    rm -rf "${TEST_TMPDIR}"
    unset TEST_TMPDIR
    log_info "Cleaned local test environment"
  else
    log_warning "Test environment was cleaned already"
  fi
}

test_set_up() {
  get_timestamp >"${TEST_TMPDIR}/__test_start"
}

test_tear_down() {
  get_timestamp >"${TEST_TMPDIR}/__test_end"
  test_log_print_test_result
}

test_env_setup() {
  if [[ -z "${TEST_TMPDIR:-}" ]]; then
    export TEST_TMPDIR="$(mktemp -d ${TMPDIR:-/tmp}/shell-scripts-lib-tests.XXXXXXXX)"
    log_info "Test environment created. path: ${TEST_TMPDIR}"
  fi

  if ! is_directory_exist "${TEST_TMPDIR}"; then
    # Create a test directory if does not exists
    mkdir -p -m 0700 "${TEST_TMPDIR}"
  fi

  # Name of current test
  TEST_name=""

  # All tests log file
  TEST_log="${TEST_TMPDIR}/log"

  # Cleanup test environment upon exit
  trap '_clean_test_environment' EXIT
}
