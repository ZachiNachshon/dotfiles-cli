#!/bin/bash

# Title         GitHub versioned releases actions
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Create or delete a GitHub versioned release
#==============================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")

# shellcheck source=../../logger.sh
source "${ROOT_FOLDER_ABS_PATH}/logger.sh"
# shellcheck source=../../checks.sh
source "${ROOT_FOLDER_ABS_PATH}/checks.sh"
# shellcheck source=../../prompter.sh
source "${ROOT_FOLDER_ABS_PATH}/prompter.sh"

read_version_from_file() {
  cat "${version_file_path}"
}

upload_version() {
  local tag=$1
  local filepath=$2
  log_info "Uploading script file. tag: ${tag}, path: ${filepath}"
  if is_debug; then
    echo """
    gh release upload ${tag} ${filepath}
    """
  fi
  if ! is_dry_run; then
    gh release upload "${tag}" "${filepath}"
  fi
}

create_release() {
  local tag=$1
  log_info "Creating a new GitHub release. tag: ${tag}"
  if is_debug; then
    echo """
    gh release create ${tag}
    """
  fi
  if ! is_dry_run; then
    gh release create "${tag}"
  fi
}

create_release_version() {
  local tag="v$(read_version_from_file)"

  log_warning "Make sure to update all version releated files/variables before you continue !"
  new_line
  prompt_for_enter
  new_line

  if [[ $(prompt_yes_no "Release tag ${tag}") == "y" ]]; then
    create_release "${tag}"
    upload_version "${tag}" "${artifact_file_path}"
  else
    log_info "Nothing was released."
  fi
}

delete_released_version() {
  local tag=$(prompt_user_input "Enter tag to delete")
  if [[ -z ${tag} ]]; then
    exit 0
  fi

  if [[ $(prompt_yes_no "Delete local and remote tag ${tag}" "critical") == "y" ]]; then
    log_info "Deleting local. tag: ${tag}"
    if is_debug; then
      echo """
      git tag -d ${tag}
      """
    fi
    if ! is_dry_run; then
      git tag -d "${tag}"
    fi

    new_line
    log_info "Deleting remote. tag: ${tag}"
    if is_debug; then
      echo """
      git push origin :refs/tags/${tag}
      """
    fi
    if ! is_dry_run; then
      git push origin ":refs/tags/${tag}"
    fi

  else
    log_info "Nothing was deleted."
  fi
}

parse_program_arguments() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      action*)
        action=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      version_file_path*)
        version_file_path=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      artifact_file_path*)
        artifact_file_path=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      dry_run*)
        dry_run="true"
        # Used by logger.sh
        export CLI_OPTION_DRY_RUN="true"
        shift
        ;;
      silent*)
        silent="true"
        # Used by logger.sh
        export LOGGER_SILENT="true"
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
  dry_run=${dry_run=''}
  silent=${silent=''}
}

is_debug() {
  [[ -n "${debug}" ]]
}

is_dry_run() {
  [[ -n "${dry_run}" ]]
}

verify_program_arguments() {
  if [[ -z "${action}" ]]; then
    log_fatal "Missing mandatory param. name: action"
  fi

  # Release version creation requires additional params
  if [[ "${action}" == "create" && -z "${version_file_path}" ]]; then
    log_fatal "Missing mandatory param. name: version_file_path"
  elif [[ "${action}" == "create" && -z "${artifact_file_path}" ]]; then
    log_fatal "Missing mandatory param. name: artifact_file_path"
  fi

  evaluate_dry_run_mode
}

prerequisites() {
  check_tool git
  check_tool gh
}

#######################################
# Create or delete a GitHub release version
# Globals:
#   None
# Arguments:
#   action              - create / delete
#   version_file_path   - (create only) path to the version file, numeric value only
#   artifact_file_path  - (create only) path to the artifact to upload
# Usage:
#   /shell-scripts-lib/github/release.sh \
#     action: create \
#     version_file_path: ./resources/version.txt \
#     artifact_file_path: git-deps-syncer.sh
#######################################
main() {
  parse_program_arguments "$@"
  verify_program_arguments

  prerequisites

  if [[ "${action}" == "create" ]]; then
    create_release_version
  elif [[ "${action}" == "delete" ]]; then
    delete_released_version
  else
    log_fatal "Invalid action, supported values: create, delete."
  fi
}

main "$@"
