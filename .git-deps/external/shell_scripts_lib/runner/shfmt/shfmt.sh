#!/bin/bash

CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
RUNNER_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")
ROOT_FOLDER_ABS_PATH=$(dirname "${RUNNER_FOLDER_ABS_PATH}")

source "${RUNNER_FOLDER_ABS_PATH}/base/runner_dockerized.sh"
source "${ROOT_FOLDER_ABS_PATH}/props.sh"

PROPERTIES_FOLDER_PATH=${ROOT_FOLDER_ABS_PATH}/runner/shfmt

parse_shfmt_arguments() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      working_dir*)
        working_dir=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      shfmt_args*)
        shfmt_args=$(cut -d : -f 2- <<<"${1}")
        shift
        ;;
      debug*)
        debug="verbose"
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  # Set defaults
  debug=${debug=''}
}

verify_shfmt_arguments() {
  if [[ -z "${working_dir}" ]]; then
    log_fatal "Missing mandatory param. name: working_dir"
  elif ! is_directory_exist "${working_dir}"; then
    log_fatal "Invalid working directory. path: ${working_dir}"
  fi
}

# Runs shell formatter and linter using local shfmt if exists or run via Docker container
# Example:
# ./runner/shfmt/shfmt.sh \
#   "working_dir: /path/to/working/dir" \
#   "shfmt_args: --help" \
#   "debug"
main() {
  parse_shfmt_arguments "$@"
  verify_shfmt_arguments

  local cli_name=$(property "${PROPERTIES_FOLDER_PATH}" "runner.shfmt.cli.name")
  local os_arch=$(property "${PROPERTIES_FOLDER_PATH}" "runner.shfmt.cli.os_arch")
  local version=$(property "${PROPERTIES_FOLDER_PATH}" "runner.shfmt.version")
  local image_name=$(property "${PROPERTIES_FOLDER_PATH}" "runner.shfmt.image.name")

  run_maybe_docker \
    "working_dir: ${working_dir}" \
    "runner_cli: ${cli_name}" \
    "runner_args: ${shfmt_args}" \
    "runner_version: ${version}" \
    "runner_os_arch: ${os_arch}" \
    "docker_image: ${image_name}" \
    "docker_build_context: ${ROOT_FOLDER_ABS_PATH}/runner/shfmt" \
    "${debug}"
}

main "$@"
