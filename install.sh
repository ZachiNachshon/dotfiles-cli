#!/bin/bash

# Installation commands:
#  Basic:
#    curl -sfL https://github.com/ZachiNachshon/dotfiles-cli/install.sh | bash -
#  Options:
#    curl -sfL https://github.com/ZachiNachshon/dotfiles-cli/install.sh | VERSION=1.1.1 bash -
#    DRY_RUN=true LOCAL_ARCHIVE_FILEPATH=/Users/zachin/codebase/github/dotfiles-cli/dotfiles-cli.tar.gz ./install.sh

# When releasing a new version, the install script must be updated as well
VERSION=${VERSION="0.0.0"}

# Run the install script in dry-run mode, no file system changes
DRY_RUN=${DRY_RUN=""}

# Use to install from a local dotfiles-cli archive instead of downloading from remote
LOCAL_ARCHIVE_FILEPATH=${LOCAL_ARCHIVE_FILEPATH=""}

DOTFILES_CLI_REPOSITORY_URL="https://github.com/ZachiNachshon/dotfiles-cli"
DOTFILES_CLI_ARCHIVE_NAME="dotfiles-cli.tar.gz"
DOTFILES_CLI_CONFIG_LOCAL_PATH="${HOME}/.config/dotfiles-cli-test"
DOTFILES_CLI_EXECUTABLE_FILE_NAME=dotfiles

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

is_shell_supported() {
  local shell_in_use="${SHELL}"
  if [[ "${shell_in_use}" == *bash* || "${shell_in_use}" == *zsh* ]]; then
    echo "${shell_in_use}"
  else
    echo ""
  fi
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

get_dotfiles_cli_archive_filepath() {
  echo "${DOTFILES_CLI_CONFIG_LOCAL_PATH}/${DOTFILES_CLI_ARCHIVE_NAME}"
}

calculate_dotfiles_cli_exec_symlink_path() {
  local os_type=$(read_os_type)
  if [[ "${os_type}" == "linux" ]]; then
    # $HOME/.local/bin/dotfiles
    echo "${LINUX_BIN_DIR}/${DOTFILES_CLI_EXECUTABLE_FILE_NAME}"
  elif [[ "${os_type}" == "darwin" ]]; then
    # $HOME/.local/bin/dotfiles
    echo "${DARWIN_BIN_DIR}/${DOTFILES_CLI_EXECUTABLE_FILE_NAME}"
  else
    echo ""
  fi
}

adjust_global_executable_symlink() {
  local dotfiles_cli_exec_bin_path=$1
  local dotfiles_cli_script_path="${DOTFILES_CLI_CONFIG_LOCAL_PATH}/dotfiles.sh"

  log_info "Elevating permission on dotfiles executable. path: ${dotfiles_cli_script_path}"
  if is_dry_run; then
    echo """
    chmod +x ${dotfiles_cli_script_path}
    """
  else
    chmod +x "${dotfiles_cli_script_path}"
  fi
  
  log_info "Linking dotfiles executable to bin directory. path: ${dotfiles_cli_script_path}"
  if is_dry_run; then
    echo """
    ln -sf ${dotfiles_cli_script_path} ${dotfiles_cli_exec_bin_path} 
    """
  else
    # macOS: ~/.local/bin/dotfiles --> ~/.config/dotfiles-cli/dotfiles.sh
    # Linux: ~/.local/bin/dotfiles --> ~/.config/dotfiles-cli/dotfiles.sh
    ln -sf "${dotfiles_cli_script_path}" "${dotfiles_cli_exec_bin_path}" 
  fi
}

add_dotfiles_cli_exec_bin_path_to_rc_file() {
  local dotfiles_cli_exec_bin_path=$1
  local shell_in_use=$(is_shell_supported)

  if [[ -z "${shell_in_use}" ]] ; then
    log_error "Shell '${shell_in_use}' is not supported (supported shells: bash, zsh)"
    echo -e """${COLOR_RED}
To use 'dotfiles' from global scope, add the following to the end of the RC file:
      
  export PATH=${dotfiles_cli_exec_bin_path}:\${PATH}
${COLOR_NONE}
    """
  else
    log_info "Updating the shell PATH. file: ${ZSH_RC_PATH}, path: ${dotfiles_cli_exec_bin_path}"

    if is_file_exist "${ZSH_RC_PATH}" && ! is_file_contain "${ZSH_RC_PATH}" "${dotfiles_cli_exec_bin_path}" ; then
      if is_dry_run; then
        echo """
    echo export PATH=${dotfiles_cli_exec_bin_path}:\${PATH} >> ${ZSH_RC_PATH}
        """
      else
        echo "export PATH=${dotfiles_cli_exec_bin_path}:\${PATH}" >> "${ZSH_RC_PATH}"
      fi
    fi

    if is_file_exist "${BASH_RC_PATH}" && ! is_file_contain "${BASH_RC_PATH}" "${dotfiles_cli_exec_bin_path}" ; then
      if is_dry_run; then
        echo """
    echo export PATH=${dotfiles_cli_exec_bin_path}:\${PATH} >> ${BASH_RC_PATH}
        """
      else
        echo "export PATH=${dotfiles_cli_exec_bin_path}:\${PATH}" >> "${BASH_RC_PATH}"
      fi
    fi

    if is_file_exist "${BASH_PROFILE_PATH}" && ! is_file_contain "${BASH_PROFILE_PATH}" "${dotfiles_cli_exec_bin_path}" ; then
      if is_dry_run; then
        echo """
    echo export PATH=${dotfiles_cli_exec_bin_path}:\${PATH} >> ${BASH_PROFILE_PATH}
        """
      else
        echo "export PATH=${dotfiles_cli_exec_bin_path}:\${PATH}" >> "${BASH_PROFILE_PATH}"
      fi
    fi
  fi
}

copy_local_archive_to_config_path() {
  log_info "Installing dotfiles CLI from local artifact. path: ${LOCAL_ARCHIVE_FILEPATH}"
  local copy_path="${DOTFILES_CLI_CONFIG_LOCAL_PATH}"
  if is_dry_run; then
    echo """
    rsync ${LOCAL_ARCHIVE_FILEPATH} ${copy_path}
    """
  else
    rsync "${LOCAL_ARCHIVE_FILEPATH}" "${copy_path}"
  fi
}

download_latest_archive_to_config_path() {
  log_info "Installing dotfiles CLI from GitHub"
  local filename="${DOTFILES_CLI_ARCHIVE_NAME}"
  local download_path="${DOTFILES_CLI_CONFIG_LOCAL_PATH}"
  local url="${DOTFILES_CLI_REPOSITORY_URL}/releases/download/v${VERSION}/${filename}"

  if is_directory_exist "${download_path}"; then
   log_info "Clearing dotfiles-cli config path"
    if is_dry_run; then
      echo """
      rm -rf ${download_path}
      """
    else
      rm -rf "${download_path}"
    fi
  fi

  log_info "Creating a fresh dotfiles-cli config path"
  if is_dry_run; then
    echo """
    mkdir -p ${download_path}
    """
  else
    mkdir -p "${download_path}"
  fi

  cwd=$(pwd)
  cd "${download_path}" || exit

  log_info "Downloading dotfiles-cli from GitHub. version: ${VERSION}"
  if is_dry_run; then
    echo """
    curl --fail -s ${url} -L -o ${filename}
    """
  else
    curl --fail -s "${url}" -L -o "${filename}"
  fi

  cd "${cwd}" || exit
}

extract_dotfiles_cli_archive() {
  # ${HOME}/.config/dotfiles-cli/dotfiles-cli.tar.gz
  local archive_file_path=$(get_dotfiles_cli_archive_filepath)
  # ${HOME}/.config/dotfiles-cli
  local archive_folder_path="${DOTFILES_CLI_CONFIG_LOCAL_PATH}"

  log_info "Extracting archive to dotfiles-cli config path. path: ${archive_folder_path}"
  if is_dry_run; then
    echo """
    tar -xzvf ${archive_file_path} -C ${archive_folder_path}
    """
  else
    tar -xzvf "${archive_file_path}" -C "${archive_folder_path}"
  fi

  if is_file_exist "${archive_file_path}"; then
    log_info "Cleaning archive file"
    if is_dry_run; then
      echo """
      rm -rf ${archive_file_path}
      """
    else
      rm -rf "${archive_file_path}"
    fi
  fi
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
  add_dotfiles_cli_exec_bin_path_to_rc_file "${dotfiles_cli_exec_bin_path}"
  log_info "Type 'dotfiles' to print the help menu (shell session reload might be required)"
}

main "$@"