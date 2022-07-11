#!/bin/bash

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW="\033[0;33m"
COLOR_WHITE='\033[1;37m'
COLOR_LIGHT_CYAN='\033[0;36m'
COLOR_NONE='\033[0m'

CLI_OPTION_SILENT=""
CLI_OPTION_DRY_RUN=""

exit_on_error() {
  exit_code=$1
  message=$2
  if [ $exit_code -ne 0 ]; then
    #        >&2 echo "\"${message}\" command failed with exit code ${exit_code}."
    # >&2 echo "\"${message}\""
    exit $exit_code
  fi
}

is_silent() {
  [[ -n ${CLI_OPTION_SILENT} ]]
}

is_dry_run() {
  [[ -n ${CLI_OPTION_DRY_RUN} ]]
}

evaluate_dry_run_mode() {
  if is_dry_run; then
    echo -e "${COLOR_YELLOW}Running in DRY RUN mode${COLOR_NONE}" >&2
    new_line
  fi 
}

_log_base() {
  prefix=$1
  shift
  echo -e "${prefix}$*" >&2
}

log_info() {
  local info_level_txt="INFO"
  if is_dry_run; then
    info_level_txt+=" (Dry Run)"
  fi

  if ! is_silent; then
    _log_base "${COLOR_GREEN}${info_level_txt}${COLOR_NONE}: " "$@"
  fi
}

log_warning() {
  local warn_level_txt="WARNING"
  if is_dry_run; then
    warn_level_txt+=" (Dry Run)"
  fi

  if ! is_silent; then
    _log_base "${COLOR_YELLOW}${warn_level_txt}${COLOR_NONE}: " "$@"
  fi
}

log_error() {
  local error_level_txt="ERROR"
  if is_dry_run; then
    error_level_txt+=" (Dry Run)"
  fi
  _log_base "${COLOR_RED}${error_level_txt}${COLOR_NONE}: " "$@"
}

log_fatal() {
  local fatal_level_txt="ERROR"
  if is_dry_run; then
    fatal_level_txt+=" (Dry Run)"
  fi
  _log_base "${COLOR_RED}${fatal_level_txt}${COLOR_NONE}: " "$@"
  message="$@"
  exit_on_error 1 "${message}"
}

new_line() {
  echo -e "" >&2
}
