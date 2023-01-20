#!/bin/bash

# Title         shfmt runner for linting shell files
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Runs a shfmt command using a local shfmt binary or dockerized
#=============================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
RUNNER_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")
ROOT_FOLDER_ABS_PATH=$(dirname "${RUNNER_FOLDER_ABS_PATH}")

source "${RUNNER_FOLDER_ABS_PATH}/base/runner_dockerized.sh"
source "${ROOT_FOLDER_ABS_PATH}/props.sh"
source "${ROOT_FOLDER_ABS_PATH}/cmd.sh"

PROPERTIES_FOLDER_PATH=${ROOT_FOLDER_ABS_PATH}/runner/shfmt

PARAM_SHFMT_WORKING_DIR=""
PARAM_SHFMT_ARGS=""

PROP_SHFMT_CLI_NAME=""
PROP_SHFMT_OS_ARCH=""
PROP_SHFMT_VERSION=""
PROP_SHFMT_IMAGE_NAME=""

parse_shfmt_arguments() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      working_dir*)
        PARAM_SHFMT_WORKING_DIR=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      shfmt_args*)
        PARAM_SHFMT_ARGS=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      --force-dockerized)
        # Used by runner_dockerized.sh
        export PARAM_FORCE_DOCKERIZED="true"
        shift
        ;;
      --dry-run)
        # Used by logger.sh
        export LOGGER_DRY_RUN="true"
        shift
        ;;
      -y)
        # Used by prompter.sh
        export PROMPTER_SKIP_PROMPT="y"
        shift
        ;;
      -v | --verbose)
        # Used by logger.sh
        export LOGGER_VERBOSE="true"
        shift
        ;;
      -s | --silent)
        # Used by logger.sh
        export LOGGER_SILENT="true"
        shift
        ;;
      *)
        break
        ;;
    esac
  done
}

verify_shfmt_arguments() {
  if [[ -z "${PARAM_SHFMT_WORKING_DIR}" ]]; then
    log_fatal "Missing mandatory param. name: working_dir"
  elif ! is_directory_exist "${PARAM_SHFMT_WORKING_DIR}"; then
    log_fatal "Invalid working directory. path: ${PARAM_SHFMT_WORKING_DIR}"
  fi
}

resolve_required_properties() {
  PROP_SHFMT_CLI_NAME=$(property "${PROPERTIES_FOLDER_PATH}" "runner.shfmt.cli.name")
  PROP_SHFMT_OS_ARCH=$(property "${PROPERTIES_FOLDER_PATH}" "runner.shfmt.cli.os_arch")
  PROP_SHFMT_VERSION=$(property "${PROPERTIES_FOLDER_PATH}" "runner.shfmt.version")
  PROP_SHFMT_IMAGE_NAME=$(property "${PROPERTIES_FOLDER_PATH}" "runner.shfmt.container.image.name")
}

####################################################################
# Runs shell formatter and linter using local shfmt if exists or run via Docker container
#
# Globals:
#   None
#
# Arguments:
#   working_dir         - Host root working directory
#   shfmt_args          - shfmt command arguments
#   --force-dockerized  - Force to run the CLI runner in a dockerized container
#   --dry-run           - Run all commands in dry-run mode without file system changes
#   --verbose           - Output debug logs for commands executions
#
# Usage:
# ./runner/shfmt/shfmt.sh \
#   "working_dir: /path/to/working/dir" \
#   "shfmt_args: --help" \
#   "--force-dockerized" \
#   "--dry-run" \
#   "--verbose"
####################################################################
main() {
  parse_shfmt_arguments "$@"
  verify_shfmt_arguments

  resolve_required_properties

  run_maybe_docker \
    "working_dir: ${PARAM_SHFMT_WORKING_DIR}" \
    "runner_name: ${PROP_SHFMT_CLI_NAME}" \
    "runner_args: ${PARAM_SHFMT_ARGS}" \
    "runner_version: ${PROP_SHFMT_VERSION}" \
    "runner_os_arch: ${PROP_SHFMT_OS_ARCH}" \
    "docker_image: ${PROP_SHFMT_IMAGE_NAME}" \
    "docker_build_context: ${ROOT_FOLDER_ABS_PATH}/runner/shfmt"
}

main "$@"
