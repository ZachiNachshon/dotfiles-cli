#!/bin/bash

# Title         Run an installed / dockerized CLI utility
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Run a CLI utility either from locally installed or within
#               a Docker container
#==============================================================================
CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
RUNNER_FOLDER_ABS_PATH=$(dirname "${CURRENT_FOLDER_ABS_PATH}")
ROOT_FOLDER_ABS_PATH=$(dirname "${RUNNER_FOLDER_ABS_PATH}")

# shellcheck source=../../logger.sh
source "${ROOT_FOLDER_ABS_PATH}/logger.sh"

# shellcheck source=../../io.sh
source "${ROOT_FOLDER_ABS_PATH}/io.sh"

# shellcheck source=../../checks.sh
source "${ROOT_FOLDER_ABS_PATH}/checks.sh"

RUNNER_CONTAINER_WORKSPACE_ROOT="/usr/runner/workspace"
RUNNER_CONTAINER_WORKSPACE_EXTERNALS=${RUNNER_CONTAINER_WORKSPACE_ROOT}/external
RUNNER_CONTAINER_DOCKER_ENTRYPOINT_FILENAME="runner_dockerized_entrypoint.sh"

run_locally() {
  cd "${working_dir}" || exit

  if is_debug; then
    log_info "Working directory set. path: ${working_dir}"
    echo -e "\n--- ${runner_cli} Exec Command (locally) ---\n${runner_cli} ${runner_args}\n---\n"
  fi

  ${runner_cli} ${runner_args}
}

# There are two methods of running with Docker - inline arguments or via RUNNER_ARGS env var
# inline:
#  docker run -it --entrypoint /bin/bash \
#     -v "<repository-abs-path>"":/usr/runner/workspace \
#     <binary-name> --help
#
# SHFMT_ARGS:
#  docker run -it --entrypoint /bin/bash \
#     -v "<repository-abs-path>"":/usr/runner/workspace \
#     -e RUNNER_ARGS="--help" \
#     <binary-name>
#
run_with_docker() {
  if ! is_image_exists "${docker_image}"; then
    log_warning "Missing ${docker_image} Docker image, building..."
    build_docker_image
  fi

  if is_debug; then
    log_info "Working directory set. path: ${working_dir}"
  fi

  # Docker cannot handle symlinks, need to mount them explicitly
  local maybe_mounted_symlinks=""
  if is_directory_exist "${working_dir}/external"; then
    for symlink in $(find "${working_dir}/external" -type l); do
      local symlink_name=$(basename "${symlink}")
      local symlink_docker_path=$(get_external_symlink_container_path "${symlink_name}")
      local real_link=$(readlink "${symlink}")
      maybe_mounted_symlinks+="-v ${real_link}:${symlink_docker_path} "
    done
  fi

  local maybe_runner_args=""
  if [[ -n ${runner_args} ]]; then
    local args_one_liner=$(echo "${runner_args}" | tr "\n" ' ')
    maybe_runner_args="-e RUNNER_ARGS='${args_one_liner}'"
  fi

  local docker_run_cmd=$(
    cat <<EOF
docker run -it ${maybe_mounted_symlinks} ${maybe_runner_args} ${docker_env_vars} ${docker_volumes} \\
  -v "${working_dir}":${RUNNER_CONTAINER_WORKSPACE_ROOT} \\
  -v /var/run/docker.sock:/var/run/docker.sock \\
  -e DEBUG="${debug}" \\
  ${docker_image}
EOF
  )

  if is_debug; then
    log_info "Docker run command:\n"
    echo "${docker_run_cmd}"
  fi

  eval "${docker_run_cmd}"
}

build_docker_image() {
  local dockerfile_path="${docker_build_context}/Dockerfile"

  if is_file_exist "${dockerfile_path}"; then
    log_info "Locate ${runner_cli} Dockerfile. path: ${dockerfile_path}"
  else
    log_fatal "Failed to locate ${runner_cli} Dockerfile. path: ${dockerfile_path}"
  fi

  local maybe_runner_name=""
  if [[ -n "${runner_cli}" ]]; then
    maybe_runner_name="--build-arg RUNNER_CLI_NAME=${runner_cli} "
  fi

  local maybe_runner_os_arch=""
  if [[ -n "${runner_os_arch}" ]]; then
    maybe_runner_os_arch="--build-arg RUNNER_OS_ARCH=${runner_os_arch} "
  fi

  local maybe_runner_version=""
  if [[ -n "${runner_version}" ]]; then
    maybe_runner_version="--build-arg RUNNER_VERSION=${runner_version} "
  fi

  copy_docker_entrypoint_file_to_build_context

  local docker_build_cmd=$(
    cat <<EOF
  # Use DOCKER_BUILDKIT=0 to show real errors, if any occur
  DOCKER_BUILDKIT=0 docker build \\
    -f "${dockerfile_path}" ${maybe_runner_name} ${maybe_runner_os_arch} ${maybe_runner_version} \\
    --tag "${docker_image}":latest \\
    "${docker_build_context}"
EOF
  )

  if is_debug; then
    log_info "Docker build command:\n"
    echo "${docker_build_cmd}"
  fi

  eval "${docker_build_cmd}"

  if [ "$?" -ne 0 ]; then
    new_line
    clear_docker_entrypoint_file
    log_fatal "Failed to build ${runner_cli} Docker image"
  fi

  clear_docker_entrypoint_file
}

get_external_symlink_container_path() {
  local symlink_name=$1
  echo "${RUNNER_CONTAINER_WORKSPACE_EXTERNALS}/${symlink_name}"
}

copy_docker_entrypoint_file_to_build_context() {
  log_info "Copying docker entrypoint file to build context. context_path: ${docker_build_context}"
  cp "${ROOT_FOLDER_ABS_PATH}/runner/base/${RUNNER_CONTAINER_DOCKER_ENTRYPOINT_FILENAME}" "${docker_build_context}"
}

clear_docker_entrypoint_file() {
  local entrypoint_file_path="${docker_build_context}/${RUNNER_CONTAINER_DOCKER_ENTRYPOINT_FILENAME}"
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
        working_dir=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      runner_cli*)
        runner_cli=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      runner_args*)
        runner_args=$(cut -d : -f 2- <<<"${1}")
        shift
        ;;
      runner_version*)
        runner_version=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      runner_os_arch*)
        runner_os_arch=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      docker_image*)
        docker_image=$(cut -d : -f 2- <<<"${1}" | xargs)
        shift
        ;;
      docker_env_var*)
        docker_env_var=$(cut -d : -f 2- <<<"${1}" | xargs)
        docker_env_vars+="-e ${docker_env_var} "
        shift
        ;;
      docker_volume*)
        docker_volume=$(cut -d : -f 2- <<<"${1}" | xargs)
        docker_volumes+="-v ${docker_volume} "
        shift
        ;;
      docker_build_context*)
        docker_build_context=$(cut -d : -f 2- <<<"${1}" | xargs)
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
  docker_env_vars=${docker_env_vars=''}
  docker_volumes=${docker_volumes=''}
  debug=${debug=''}
}

verify_runner_arguments() {
  if [[ -z "${working_dir}" ]]; then
    log_fatal "Missing mandatory param. name: selected_hosts"
  elif ! is_directory_exist "${working_dir}"; then
    log_fatal "Invalid working directory. path: ${working_dir}"
  fi

  if [[ -z "${runner_cli}" ]]; then
    log_fatal "Missing mandatory param. name: runner_cli"
  fi

  if [[ -z "${docker_image}" ]]; then
    log_fatal "Missing mandatory param. name: docker_image"
  fi

  if [[ -z "${docker_build_context}" ]]; then
    log_fatal "Missing mandatory param. name: docker_build_context"
  fi
}

is_debug() {
  [[ -n "${debug}" ]]
}

# run_maybe_docker \
#   "working_dir: /path/to/working/dir" \
#   "runner_cli: kubectl" \
#   "runner_args: get pods" \
#   "runner_version: 1.0.0" \
#   "runner_os_arch: linux_amd64" \
#   "docker_image: kubectl-example" \
#   "docker_build_context: /path/to/build/context" \
#   "docker_env_var: KEY=VALUE" \
#   "docker_volume: /host/path:/container/path" \
#   "debug"
run_maybe_docker() {
  parse_runner_arguments "$@"
  verify_runner_arguments

  if is_tool_exist "${runner_cli}"; then
    if is_debug; then
      log_info "Running from local installation. name: ${runner_cli}"
    fi
    run_locally
  else
    if is_debug; then
      log_info "Running within a Docker container. name: ${runner_cli}"
    fi
    check_tool docker
    run_with_docker
  fi
}
