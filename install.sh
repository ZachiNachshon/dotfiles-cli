#!/bin/bash

# Installation commands:
#  Basic:
#    curl -sfL https://github.com/ZachiNachshon/dotfiles-cli/install.sh | bash -
#  Options:
#    curl -sfL https://github.com/ZachiNachshon/dotfiles-cli/install.sh | VERSION=1.1.1 bash -
#    DRY_RUN=True LOCAL_ARCHIVE_FILEPATH=/Users/zachin/codebase/github/dotfiles-cli/dotfiles-cli.tar.gz ./install.sh

# When releasing a new version, the install script must be updated as well to latest
VERSION=${VERSION="0.2.0"}

# Run the install script in dry-run mode, no file system changes
DRY_RUN=${DRY_RUN=""}

# Use to install from a local dotfiles-cli archive instead of downloading from remote
LOCAL_ARCHIVE_FILEPATH=${LOCAL_ARCHIVE_FILEPATH=""}

DOTFILES_CLI_REPOSITORY_URL="https://github.com/ZachiNachshon/dotfiles-cli"
DOTFILES_CLI_ARCHIVE_NAME="dotfiles-cli.tar.gz"
DOTFILES_CLI_INSTALL_PATH="${HOME}/.config/dotfiles-cli"
DOTFILES_CLI_EXECUTABLE_NAME=dotfiles

DARWIN_BIN_DIR="$HOME/.local/bin"
LINUX_BIN_DIR="$HOME/.local/bin"

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW="\033[0;33m"
COLOR_NONE='\033[0m'

is_dry_run() {
  [[ -n ${DRY_RUN} ]]
}

exit_on_error() {
  exit_code=$1
  message=$2
  if [ $exit_code -ne 0 ]; then
    #        >&2 echo "\"${message}\" command failed with exit code ${exit_code}."
    # >&2 echo "\"${message}\""
    exit $exit_code
  fi
}

new_line() {
  echo -e "" >&2
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

  _log_base "${COLOR_GREEN}${info_level_txt}${COLOR_NONE}: " "$@"
}

log_warning() {
  local warn_level_txt="WARNING"
  if is_dry_run; then
    warn_level_txt+=" (Dry Run)"
  fi

  _log_base "${COLOR_YELLOW}${warn_level_txt}${COLOR_NONE}: " "$@"
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

cmd_run() {
  local cmd_string=$1
  if ! is_dry_run; then
    eval "${cmd_string}"
  else
    echo """
      ${cmd_string}
  """
  fi
}

is_install_from_local_archive() {
  [[ -n "${LOCAL_ARCHIVE_FILEPATH}" ]]
}

is_symlink() {
  local abs_path=$1
  [[ -L "${abs_path}" ]]
}

is_file_exist() {
  local path=$1
  [[ -f "${path}" || $(is_symlink "${path}") ]]
}

is_directory_exist() {
  local path=$1
  [[ -d "${path}" ]]
}

get_dotfiles_cli_archive_filepath() {
  echo "${DOTFILES_CLI_INSTALL_PATH}/${DOTFILES_CLI_ARCHIVE_NAME}"
}

read_os_type() {
  if [[ "${OSTYPE}" == "linux"* ]]; then
    echo "linux"
  elif [[ "${OSTYPE}" == "darwin"* ]]; then
    echo "darwin"
  else
    log_fatal "OS type is not supported. os: ${OSTYPE}"
  fi
}

calculate_dotfiles_cli_exec_symlink_path() {
  local os_type=$(read_os_type)
  if [[ "${os_type}" == "linux" ]]; then
    # $HOME/.local/bin/dotfiles
    echo "${LINUX_BIN_DIR}/${DOTFILES_CLI_EXECUTABLE_NAME}"
  elif [[ "${os_type}" == "darwin" ]]; then
    # $HOME/.local/bin/dotfiles
    echo "${DARWIN_BIN_DIR}/${DOTFILES_CLI_EXECUTABLE_NAME}"
  else
    echo ""
  fi
}

adjust_global_executable_symlink() {
  local dotfiles_cli_exec_bin_path=$1
  local dotfiles_cli_script_path="${DOTFILES_CLI_INSTALL_PATH}/dotfiles.sh"

  log_info "Elevating executable permission. path: ${dotfiles_cli_script_path}"
  cmd_run "chmod +x ${dotfiles_cli_script_path}"
  
  # macOS: ~/.local/bin/dotfiles --> ~/.config/dotfiles-cli/dotfiles.sh
  # Linux: ~/.local/bin/dotfiles --> ~/.config/dotfiles-cli/dotfiles.sh
  log_info "Linking executable to bin directory. symlink: ${dotfiles_cli_exec_bin_path}"
  cmd_run "ln -sf ${dotfiles_cli_script_path} ${dotfiles_cli_exec_bin_path}"
}

copy_local_archive_to_config_path() {
  if ! is_file_exist "${LOCAL_ARCHIVE_FILEPATH}"; then 
    log_fatal "Local archive file does not exist. path: ${LOCAL_ARCHIVE_FILEPATH}"
  fi 

  clear_previous_installation
  log_info "Installing dotfiles CLI from local artifact. path: ${LOCAL_ARCHIVE_FILEPATH}"
  log_info "Copying archive to config path"
  local copy_path="${DOTFILES_CLI_INSTALL_PATH}"
  cmd_run "rsync ${LOCAL_ARCHIVE_FILEPATH} ${copy_path}"
}

download_latest_archive_to_config_path() {
  log_info "Installing dotfiles CLI from GitHub"
  local filename="${DOTFILES_CLI_ARCHIVE_NAME}"
  local download_path="${DOTFILES_CLI_INSTALL_PATH}"
  local url="${DOTFILES_CLI_REPOSITORY_URL}/releases/download/v${VERSION}/${filename}"

  clear_previous_installation

  cwd=$(pwd)
  if is_directory_exist "${download_path}"; then
    cd "${download_path}" || exit
  fi
  log_info "Downloading dotfiles-cli from GitHub. version: ${VERSION}"
  cmd_run "curl --fail -s ${url} -L -o ${filename}"
  cd "${cwd}" || exit

  if ! is_dry_run && ! is_file_exist "${download_path}/${filename}"; then
    log_fatal "Failed to download dotfiles-cli from GitHub. version: ${VERSION}"
  fi
}

extract_dotfiles_cli_archive() {
  # ${HOME}/.config/dotfiles-cli/dotfiles-cli.tar.gz
  local archive_file_path=$(get_dotfiles_cli_archive_filepath)
  # ${HOME}/.config/dotfiles-cli
  local archive_folder_path="${DOTFILES_CLI_INSTALL_PATH}"

  log_info "Extracting archive. destination: ${archive_folder_path}"
  cmd_run "tar -xzf ${archive_file_path} -C ${archive_folder_path}"

  if is_file_exist "${archive_file_path}"; then
    log_info "Removing archive file"
    cmd_run "rm -rf ${archive_file_path}"
  fi
}

clear_previous_installation() {
  log_info "Creating a fresh installation folder"
  local dotfiles_cli_install_path="${DOTFILES_CLI_INSTALL_PATH}"

  if is_directory_exist "${dotfiles_cli_install_path}"; then
    cmd_run "rm -rf ${dotfiles_cli_install_path}"
  fi
  cmd_run "mkdir -p ${dotfiles_cli_install_path}"
}

main() {
  local dotfiles_cli_exec_bin_path=$(calculate_dotfiles_cli_exec_symlink_path)

  if is_install_from_local_archive; then
    copy_local_archive_to_config_path
  else
    download_latest_archive_to_config_path
  fi

  extract_dotfiles_cli_archive
  adjust_global_executable_symlink "${dotfiles_cli_exec_bin_path}"

  new_line
  log_info "Type 'dotfiles' to print the help menu (shell session reload might be required)"
  new_line
}

main "$@"