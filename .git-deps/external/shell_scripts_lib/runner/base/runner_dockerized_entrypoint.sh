#!/usr/bin/env bash

DOCKER_INIT_FILES_PATH=/docker-entrypoint-init.d

# Every scripts located (or mounted) in the /docker-entrypoint-init.d folder and ending with sh
# will be executed at startup before the command
run_docker_init_files() {
  echo -e "Running init files. dir-path: ${DOCKER_INIT_FILES_PATH}\n"
  local f
  for f; do
    case "$f" in
      *.sh)
        # https://github.com/docker-library/postgres/issues/450#issuecomment-393167936
        # https://github.com/docker-library/postgres/pull/452
        if [ -x "$f" ]; then
          echo "$0: running $f"
          "$f"
        else
          echo "$0: sourcing $f"
          . "$f"
        fi
        ;;
      *)
        echo "$0: ignoring $f"
        ;;
    esac
    echo
  done
}

start_runner() {
  if [[ -z "$*" && -z ${RUNNER_ARGS} ]]; then

    # When no arguments, print help menu
    echo
    "${RUNNER_CLI_NAME}" --help

  elif [[ -n "$*" ]]; then

    if is_verbose; then
      # Resume to command execution using command arguments
      echo -e "\n--- ${RUNNER_CLI_NAME} Exec Command (inline) ---\n${RUNNER_CLI_NAME} $*\n---"
    fi
    echo
    "${RUNNER_CLI_NAME}" "$@"

  elif [[ -n "${RUNNER_ARGS}" ]]; then

    if is_verbose; then
      # Resume to command execution using arguments from env var RUNNER_ARGS
      echo -e "\n--- ${RUNNER_CLI_NAME} Exec Command (RUNNER_ARGS) ---\n${RUNNER_CLI_NAME} ${RUNNER_ARGS}\n---"
    fi
    echo
    "${RUNNER_CLI_NAME}" ${RUNNER_ARGS}
  fi
}

is_verbose() {
  [[ -n "${VERBOSE}" ]]
}

main() {
  if [[ -d "${DOCKER_INIT_FILES_PATH}" ]]; then
    run_docker_init_files "${DOCKER_INIT_FILES_PATH}/*"
  fi

  cd "${RUNNER_WORKSPACE}" || exit

  start_runner "$@"
}

main "$@"
