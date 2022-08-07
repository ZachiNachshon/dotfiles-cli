#!/bin/bash

# Title         Calculate SHA256 for a GitHub resource
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Run shasum on a downloaded file to a temporary local path
#==============================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")

# shellcheck source=../../logger.sh
source "${ROOT_FOLDER_ABS_PATH}/logger.sh"
# shellcheck source=../../checks.sh
source "${ROOT_FOLDER_ABS_PATH}/checks.sh"
# shellcheck source=../../prompter.sh
source "${ROOT_FOLDER_ABS_PATH}/prompter.sh"
# shellcheck source=../../sha.sh
source "${ROOT_FOLDER_ABS_PATH}/sha.sh"
# shellcheck source=../../strings.sh
source "${ROOT_FOLDER_ABS_PATH}/strings.sh"

print_sha_for_prompted_tag() {
  local tag=$(prompt_user_input "Enter release tag")
  local url="${repository_url}/releases/download/v${tag}/${asset_name}"
  local shasum=$(shasum_calculate "${url}")
  if [[ -n "${shasum}" ]]; then
    local result=$(split_newlines_by_delimiter "${shasum}")
    new_line
    echo -e "SHA256:\n${result}"
  fi
}

print_sha_for_prompted_commit_hash() {
  local commit_hash=$(prompt_user_input "Enter commit-hash")
  local url="${repository_url}/archive/${commit_hash}.zip"
  local shasum=$(shasum_calculate "${url}")
  if [[ -n "${shasum}" ]]; then
    local result=$(split_newlines_by_delimiter "${shasum}")
    new_line
    echo -e "SHA256:\n${result}"
  fi
}

parse_program_arguments() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      repository_url*)
        repository_url=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      sha_source*)
        sha_source=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      asset_name*)
        asset_name=$(cut -d : -f 2- <<<"${1}" | xargs)
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

verify_program_arguments() {
  if [[ -z "${repository_url}" ]]; then
    log_fatal "Missing mandatory param. name: repository_url"
  elif [[ -z "${sha_source}" ]]; then
    log_fatal "Missing mandatory param. name: sha_source"
  fi

  # Tag based SHA calculation requires an asset name
  if [[ "${sha_source}" == "tag" && -z "${asset_name}" ]]; then
    log_fatal "Missing mandatory param. name: asset_name"
  fi
}

prerequisites() {
  check_tool gh
}

#######################################
# Calculate SHA256 for a GitHub resource
# Globals:
#   None
# Arguments:
#   repository_name - name of the GitHub repository
#                     https://github.com/<organization>/<repo-name>
#   sha_source      - tag / commit-hash
#   asset_name      - (Optional) name of the remote file,
#                     Relevant only to tag based SHA calculation.
# Usage:
#   /shell-scripts-lib/github/sha_calculator.sh \
#     sha_source: tag \
#     repository_url: https://github.com/ZachiNachshon/git-deps-syncer \
#     asset_name: git-deps-syncer.sh
#######################################
main() {
  parse_program_arguments "$@"
  verify_program_arguments

  prerequisites

  if [[ "${sha_source}" == "tag" ]]; then
    print_sha_for_prompted_tag

  elif [[ "${sha_source}" == "commit-hash" ]]; then
    print_sha_for_prompted_commit_hash

  else
    log_fatal "Invalid sha source, supported values: tag, commit-hash."
  fi
}

main "$@"
