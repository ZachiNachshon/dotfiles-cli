#!/bin/bash

# Title         Reload shell session
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Source all session files under current shell session
# Limitation    It is not possible to tamper with parent shell process
#               from a nested shell.
# Solution      The reload session command will source the relevant files
#               while under the current shell session without creating
#               a nested shell session.
#==============================================================================
CONFIG_FOLDER_PATH="${HOME}/.config"
DOTFILES_REPO_LOCAL_PATH=${DOTFILES_REPO_LOCAL_PATH:-"${CONFIG_FOLDER_PATH}/dotfiles"}

DOTFILES_REPO_SYNCER_TRANSIENT_HOME_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/transient"
DOTFILES_REPO_SYNCER_SESSION_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/session"
DOTFILES_REPO_SYNCER_CUSTOM_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/custom"

COLOR_GREEN='\033[0;32m'
COLOR_NONE='\033[0m'

ICON_GOOD="${COLOR_GREEN}✔${COLOR_NONE}"

is_debug() {
  [[ -n "${LOGGER_VERBOSE}" ]]
}

is_silent() {
  if [[ -n ${DOTFILES_CLI_SILENT_OPTION} ]]; then
    # Execution from dotfiles CLI controls env var DOTFILES_CLI_SILENT_OPTION
    [[ ${DOTFILES_CLI_SILENT_OPTION} == "True" ]]
  else
    # Execution from shell RC files controls env var LOGGER_SILENT
    [[ -n ${LOGGER_SILENT} ]]
  fi
}

is_dry_run() {
  [[ -n ${LOGGER_DRY_RUN} ]]
}

cmd_run() {
  local cmd_string=$1
  if is_debug; then
    echo """
    ${cmd_string}
  """
  fi
  if ! is_dry_run; then
    eval "${cmd_string}"
  fi
}

_log_indicator_base() {
  prefix=$1
  shift
  echo -e "${prefix}$*" >&2
}

log_indicator_good() {
  local log_txt=""
  if is_dry_run; then
    log_txt+=" (Dry Run)"
  fi
  if ! is_silent; then
    _log_indicator_base "${ICON_GOOD}${log_txt} " "$@"
  fi
}

_source_files_from_path() {
  local files_path=$1
  if [[ -d ${files_path} ]]; then
    for file_path in "${files_path}"/.[^.]*; do
      # filename=$(basename "${file_path}")
      # echo "filename: ${filename}"
      cmd_run "source "${file_path}""
    done
  fi
}

_reload_source_transient_files() {
  _source_files_from_path "${DOTFILES_REPO_SYNCER_TRANSIENT_HOME_PATH}"
  log_indicator_good "Sourced transient files"
}

_reload_source_session_files() {
  _source_files_from_path "${DOTFILES_REPO_SYNCER_SESSION_PATH}"
  log_indicator_good "Sourced session files"
}

_reload_source_custom_files() {
  _source_files_from_path "${DOTFILES_REPO_SYNCER_CUSTOM_PATH}"
  log_indicator_good "Sourced custom files"
}

reload_active_shell_session() {
  _reload_source_transient_files
  _reload_source_session_files
  _reload_source_custom_files
}

main() {
  reload_active_shell_session
}

main "$@"
