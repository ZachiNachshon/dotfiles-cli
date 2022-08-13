#!/bin/bash

# Title         Tests logs
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Logging for tests scenarios
#=================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")

source "${ROOT_FOLDER_ABS_PATH}/logger.sh"
source "${ROOT_FOLDER_ABS_PATH}/math.sh"

_get_test_run_time() {
  local ts_start=$1
  local ts_end=$2
  local run_time_sec=$(subtract "${ts_end}" "${ts_start}")
  echo "${run_time_sec}"
}

_test_log_print_test_invocation() {
  echo "-- Tests invocation log: -----------------------------------------------"
  is_file_size_bigger_than_zero "${TEST_log}" && cat "${TEST_log}" || echo "(Could not find log file.)"
  echo "------------------------------------------------------------------------"
}

get_timestamp() {
  echo $(date +%s)
}

test_log_print_tests_suite_header() {
  local msg=$1
  log_info "${COLOR_WHITE}RUNNING${COLOR_NONE}: ${msg}"
}

test_log_print_test_name() {
  local name=$1
  new_line
  log_info "${COLOR_GREEN}${name}...${COLOR_NONE}"
}

test_log_fail() {
  get_timestamp >"${TEST_TMPDIR}/__test_end"
  TEST_passed="False"
  test_log_print_test_result
  echo -e "$@" >"${TEST_TMPDIR}/__fail"
  echo -e "$@" >>"${TEST_log}"
  _test_log_print_test_invocation >&2
  exit 1
}

test_log_print_test_result() {
  local ts_start=$(cat "${TEST_TMPDIR}/__test_start")
  local ts_end=$(cat "${TEST_TMPDIR}/__test_end")
  local run_time=$(_get_test_run_time "${ts_start}" "${ts_end}")

  if [[ "${TEST_passed}" == "True" ]]; then
    echo -e "${COLOR_GREEN}PASSED${COLOR_NONE}: ${TEST_name} (${run_time} sec)" >&2
  else
    echo -e "${COLOR_RED}FAILED${COLOR_NONE}: ${TEST_name} (${run_time} sec)" >&2
  fi
}
