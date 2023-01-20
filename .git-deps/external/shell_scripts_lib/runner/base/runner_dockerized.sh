#!/bin/bash

# Title         Run a utility binary if installed locally or dockerized
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Run a CLI utility either from local binary or within
#               a Docker container
#==============================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
RUNNER_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")
ROOT_FOLDER_ABS_PATH=$(dirname "${RUNNER_FOLDER_ABS_PATH}")

source "${ROOT_FOLDER_ABS_PATH}/logger.sh"
source "${ROOT_FOLDER_ABS_PATH}/io.sh"
source "${ROOT_FOLDER_ABS_PATH}/checks.sh"
source "${ROOT_FOLDER_ABS_PATH}/cmd.sh"

RUNNER_CONTAINER_WORKSPACE_ROOT="/usr/runner/workspace"
RUNNER_CONTAINER_WORKSPACE_EXTERNALS=${RUNNER_CONTAINER_WORKSPACE_ROOT}/external
RUNNER_CONTAINER_DOCKER_ENTRYPOINT_FILENAME="runner_dockerized_entrypoint.sh"

PARAM_RUNNER_WORKING_DIR=""
PARAM_RUNNER_NAME=""
PARAM_RUNNER_ARGS=""
PARAM_RUNNER_VERSION=""
PARAM_RUNNER_OS_ARCH=""
PARAM_RUNNER_DOCKER_IMAGE=""
PARAM_RUNNER_DOCKER_ENV_VARS=""
PARAM_RUNNER_DOCKER_VOLUMES=""
PARAM_RUNNER_DOCKER_BUILD_CONTEXT=""
PARAM_FORCE_DOCKERIZED=""

is_force_dockerized() {
  [[ -n "${PARAM_FORCE_DOCKERIZED}" ]]
}

run_locally() {
  cd "${PARAM_RUNNER_WORKING_DIR}" || exit

  log_debug "Working directory set. path: ${PARAM_RUNNER_WORKING_DIR}"
  log_debug "Exec Command (locally): ${PARAM_RUNNER_NAME} ${PARAM_RUNNER_ARGS}"

  cmd_run "${PARAM_RUNNER_NAME} ${PARAM_RUNNER_ARGS}"
}

# There are two methods of running with Docker - inline arguments or via RUNNER_ARGS env var
#
# inline:
#  docker run -it --entrypoint /bin/bash \
#     -v "<repository-abs-path>":/usr/runner/workspace \
#     <binary-name> --help
#
# RUNNER_ARGS:
#  docker run -it --entrypoint /bin/bash \
#     -v "<repository-abs-path>":/usr/runner/workspace \
#     -e RUNNER_ARGS="--help" \
#     <binary-name>
#
run_with_docker() {
  if ! is_dry_run; then
    check_tool docker
  fi

  if ! is_image_exists "${PARAM_RUNNER_DOCKER_IMAGE}" || is_dry_run; then
    log_warning "Missing ${PARAM_RUNNER_DOCKER_IMAGE} Docker image, building..."
    build_docker_image
  fi
  log_debug "Working directory set. path: ${PARAM_RUNNER_WORKING_DIR}"

  # Docker cannot handle symlinks, need to mount them explicitly
  local maybe_mounted_symlinks=$(expand_volume_symlinks_from_external_folder)

  local maybe_runner_args=""
  if [[ -n ${PARAM_RUNNER_ARGS} ]]; then
    maybe_runner_args=$(echo "${PARAM_RUNNER_ARGS}" | tr "\n" ' ')
  fi

  local docker_run_cmd=$(
    cat <<EOF
docker run ${maybe_mounted_symlinks} ${PARAM_RUNNER_DOCKER_ENV_VARS} ${PARAM_RUNNER_DOCKER_VOLUMES} \\
      -v "${PARAM_RUNNER_WORKING_DIR}":"${RUNNER_CONTAINER_WORKSPACE_ROOT}" \\
      -v "/var/run/docker.sock":"/var/run/docker.sock" \\
      -e VERBOSE="${LOGGER_VERBOSE}" \\
      ${PARAM_RUNNER_DOCKER_IMAGE} ${maybe_runner_args}
EOF
  )

  cmd_run "${docker_run_cmd}"
}

# Docker cannot handle symlinks, need to mount them explicitly
expand_volume_symlinks_from_external_folder() {
  local maybe_mounted_symlinks=""
  if is_directory_exist "${PARAM_RUNNER_WORKING_DIR}/external"; then
    for symlink in $(find "${PARAM_RUNNER_WORKING_DIR}/external" -type l); do
      local symlink_name=$(basename "${symlink}")
      local symlink_docker_path=$(get_external_symlink_container_path "${symlink_name}")
      local real_link=$(readlink "${symlink}")
      maybe_mounted_symlinks+="-v \"${real_link}\":\"${symlink_docker_path}\" "
    done
  fi
  echo "${maybe_mounted_symlinks}"
}

build_docker_image() {
  local dockerfile_path="${PARAM_RUNNER_DOCKER_BUILD_CONTEXT}/Dockerfile"

  if is_file_exist "${dockerfile_path}"; then
    log_info "Locate ${PARAM_RUNNER_NAME} Dockerfile. path: ${dockerfile_path}"
  else
    log_fatal "Failed to locate ${PARAM_RUNNER_NAME} Dockerfile. path: ${dockerfile_path}"
  fi

  local maybe_runner_name=""
  if [[ -n "${PARAM_RUNNER_NAME}" ]]; then
    maybe_runner_name="--build-arg RUNNER_CLI_NAME=${PARAM_RUNNER_NAME} "
  fi

  local maybe_runner_os_arch=""
  if [[ -n "${PARAM_RUNNER_OS_ARCH}" ]]; then
    maybe_runner_os_arch="--build-arg RUNNER_OS_ARCH=${PARAM_RUNNER_OS_ARCH} "
  fi

  local maybe_runner_version=""
  if [[ -n "${PARAM_RUNNER_VERSION}" ]]; then
    maybe_runner_version="--build-arg RUNNER_VERSION=${PARAM_RUNNER_VERSION} "
  fi

  copy_docker_entrypoint_file_to_build_context

  local docker_build_cmd=$(
    cat <<EOF
  # Use DOCKER_BUILDKIT=0 to show real errors, if any occur
  DOCKER_BUILDKIT=0 docker build \\
    -f "${dockerfile_path}" ${maybe_runner_name} ${maybe_runner_os_arch} ${maybe_runner_version} \\
    --tag ${PARAM_RUNNER_DOCKER_IMAGE}:latest \\
    ${PARAM_RUNNER_DOCKER_BUILD_CONTEXT}
EOF
  )

  cmd_run "${docker_build_cmd}"

  if [ "$?" -ne 0 ]; then
    new_line
    clear_docker_entrypoint_file
    log_fatal "Failed to build ${PARAM_RUNNER_NAME} Docker image"
  fi

  clear_docker_entrypoint_file
}

get_external_symlink_container_path() {
  local symlink_name=$1
  echo "${RUNNER_CONTAINER_WORKSPACE_EXTERNALS}/${symlink_name}"
}

copy_docker_entrypoint_file_to_build_context() {
  log_info "Copying docker entrypoint file to build context. context_path: ${PARAM_RUNNER_DOCKER_BUILD_CONTEXT}"
  cp "${ROOT_FOLDER_ABS_PATH}/runner/base/${RUNNER_CONTAINER_DOCKER_ENTRYPOINT_FILENAME}" "${PARAM_RUNNER_DOCKER_BUILD_CONTEXT}"
}

clear_docker_entrypoint_file() {
  local entrypoint_file_path="${PARAM_RUNNER_DOCKER_BUILD_CONTEXT}/${RUNNER_CONTAINER_DOCKER_ENTRYPOINT_FILENAME}"
  if is_file_exist "${entrypoint_file_path}" && is_file_has_name "${entrypoint_file_path}" "${RUNNER_CONTAINER_DOCKER_ENTRYPOINT_FILENAME}"; then
    log_info "Clearing docker entrypoint file from build context. file_path: ${entrypoint_file_path}"
    rm -rf "${entrypoint_file_path}"
  else
    log_warning "Could not remove docker entry point file. file_path: ${entrypoint_file_path}"
  fi
}

parse_runner_arguments() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      working_dir*)
        PARAM_RUNNER_WORKING_DIR=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      runner_name*)
        PARAM_RUNNER_NAME=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      runner_args*)
        PARAM_RUNNER_ARGS=$(cut -d : -f 2- <<<"${1}")
        shift
        ;;
      runner_version*)
        PARAM_RUNNER_VERSION=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      runner_os_arch*)
        PARAM_RUNNER_OS_ARCH=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      docker_image*)
        PARAM_RUNNER_DOCKER_IMAGE=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      docker_env_var*)
        docker_env_var=$(cut -d : -f 2- <<<"${1}" | xargs)
        docker_env_var_host=$(cut -d : -f 1 <<<"${docker_env_var}" | xargs)
        docker_env_var_container=$(cut -d : -f 2 <<<"${docker_env_var}" | xargs)
        PARAM_RUNNER_DOCKER_ENV_VARS+="""-e \"${docker_env_var_host}\":\"${docker_env_var_container}\" """
        shift
        ;;
      docker_volume*)
        docker_volume=$(cut -d : -f 2- <<<"${1}" | xargs)
        docker_volume_host=$(cut -d : -f 1 <<<"${docker_volume}" | xargs)
        docker_volume_container=$(cut -d : -f 2 <<<"${docker_volume}" | xargs)
        PARAM_RUNNER_DOCKER_VOLUMES+="""-v \"${docker_volume_host}\":\"${docker_volume_container}\" """
        shift
        ;;
      docker_build_context*)
        PARAM_RUNNER_DOCKER_BUILD_CONTEXT=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      --force-dockerized)
        PARAM_FORCE_DOCKERIZED="true"
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

verify_runner_arguments() {
  if [[ -z "${PARAM_RUNNER_WORKING_DIR}" ]]; then
    log_fatal "Missing mandatory param. name: working_dir"
  elif ! is_directory_exist "${PARAM_RUNNER_WORKING_DIR}"; then
    log_fatal "Invalid working directory. path: ${PARAM_RUNNER_WORKING_DIR}"
  fi

  if [[ -z "${PARAM_RUNNER_NAME}" ]]; then
    log_fatal "Missing mandatory param. name: runner_name"
  fi

  if [[ -z "${PARAM_RUNNER_DOCKER_IMAGE}" ]]; then
    log_fatal "Missing mandatory param. name: docker_image"
  fi

  if [[ -z "${PARAM_RUNNER_DOCKER_BUILD_CONTEXT}" ]]; then
    log_fatal "Missing mandatory param. name: docker_build_context"
  fi
}

####################################################################
# Runs shell formatter and linter using local shfmt if exists or run via Docker container
#
# Globals:
#   None
#
# Arguments:
#   working_dir           - shfmt root working directory
#   runner_name           - Utility binary name
#   runner_args           - Utility command arguments
#   runner_version        - Utility version to download
#   runner_os_arch        - Optional if the Dockerfile support multiple OS/Architecture
#   docker_image_name     - Name of the built docker image
#   docker_build_context  - Docker build context
#   docker_env_var        - Optional env vars
#   docker_volume         - Optional volume mapping
#   --force-dockerized    - Force to run the CLI runner in a dockerized container
#   --dry-run             - Run all commands in dry-run mode without file system changes
#   --verbose             - Output debug logs for commands executions
#
# Usage:
# run_maybe_docker \
#   "working_dir: /path/to/working/dir" \
#   "runner_name: kubectl" \
#   "runner_args: get pods" \
#   "runner_version: 1.0.0" \
#   "runner_os_arch: linux_amd64" \
#   "docker_image: kubectl-example" \
#   "docker_build_context: /path/to/build/context" \
#   "docker_env_var: KEY=VALUE" \
#   "docker_volume: /host/path:/container/path" \
#   "--force-dockerized"
#   "--dry-run"
#   "--verbose"
####################################################################
run_maybe_docker() {
  parse_runner_arguments "$@"
  verify_runner_arguments

  # Warn on supported runner version, locally installed utility might
  # be of a differnet version, potentially with breaking changes
  log_warning "Supported ${PARAM_RUNNER_NAME} version is ${PARAM_RUNNER_VERSION}"

  if ! is_force_dockerized && is_tool_exist "${PARAM_RUNNER_NAME}"; then
    log_info "Running from local installation. name: ${PARAM_RUNNER_NAME}"
    run_locally
  else
    log_info "Running within a Docker container. name: ${PARAM_RUNNER_NAME}"
    run_with_docker
  fi
}
