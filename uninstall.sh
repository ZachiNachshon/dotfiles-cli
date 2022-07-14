#!/bin/bash

# Installation commands:
#  Basic:
#    curl -sfL https://github.com/ZachiNachshon/dotfiles-cli/uninstall.sh | bash -
#  Options:
#    curl -sfL https://github.com/ZachiNachshon/dotfiles-cli/install.sh | DRY_RUN=true -
#    DRY_RUN=true ./uninstall.sh

# Run the install script in dry-run mode, no file system changes
DRY_RUN=${DRY_RUN=""}

DOTFILES_CLI_INSTALL_PATH="${HOME}/.config/dotfiles-cli"
DOTFILES_CLI_EXECUTABLE_NAME=dotfiles

DARWIN_BIN_DIR="$HOME/.local/bin"
LINUX_BIN_DIR="$HOME/.local/bin"

ZSH_RC_PATH="${HOME}/.zshrc"
BASH_RC_PATH="${HOME}/.bashrc"
BASH_PROFILE_PATH="${HOME}/.bash_profile"

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

is_tool_exist() {
  local name=$1
  [[ $(command -v "${name}") ]]
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

is_file_contain() {
  local filepath=$1
  local text=$2
  grep -q -w "${text}" "${filepath}"
}

is_directory_exist() {
  local path=$1
  [[ -d "${path}" ]]
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

print_dotfiles_cli_rc_file_removal_message() {
  local dotfiles_cli_exec_bin_path=$1
  local rc_file_path="$HOME/.xxxrc"

  if is_file_exist "${ZSH_RC_PATH}"; then
    rc_file_path="${ZSH_RC_PATH}"
  elif is_file_exist "${BASH_RC_PATH}"; then
    rc_file_path="${BASH_RC_PATH}"
  elif is_file_exist "${BASH_PROFILE_PATH}"; then 
    rc_file_path="${BASH_PROFILE_PATH}"
  fi 

  echo -e """${COLOR_YELLOW}
To remove 'dotfiles' from global scope, remove the the following from the RC file (${rc_file_path}):
      
  export PATH=${dotfiles_cli_exec_bin_path}:\${PATH}${COLOR_NONE}"""
}

clear_prevoius_installation() {
  local dotfiles_cli_unpack_path="${DOTFILES_CLI_INSTALL_PATH}"
  log_info "Removing installation folder. path: ${dotfiles_cli_unpack_path}"

  if is_directory_exist "${dotfiles_cli_unpack_path}"; then
    cmd_run "rm -rf ${dotfiles_cli_unpack_path}"
  fi
}

main() {
  log_info "Unsyncing any dotfiles traces"
  if is_tool_exist "dotfiles"; then
    cmd_run "dotfiles unsync all -y"
  else
    log_warning "Cannot unsync files, 'dotfiles' is not globally installed"
  fi

  local dotfiles_cli_exec_bin_path=$(calculate_dotfiles_cli_exec_symlink_path)

  log_info "Unlinking exec bin. path: ${dotfiles_cli_exec_bin_path}"
  if is_file_exist "${dotfiles_cli_exec_bin_path}"; then
    cmd_run "unlink ${dotfiles_cli_exec_bin_path}"
  else
    log_warning "Cannot unlink file, 'dotfiles' is not symlinked. path: ${dotfiles_cli_exec_bin_path}"
  fi

  clear_prevoius_installation
  print_dotfiles_cli_rc_file_removal_message "${dotfiles_cli_exec_bin_path}"
}

main "$@"