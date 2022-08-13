#!/bin/bash

# Title         Clone and link a dotfiles repository
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Clone and link a dotfiles repository
#               Path: ${HOME}/.config/dotfiles
#==============================================================================
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/logger.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/prompter.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/cmd.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/io.sh"

linker_print_banner() {
  echo -e "
██╗     ██╗███╗   ██╗██╗  ██╗███████╗██████╗ 
██║     ██║████╗  ██║██║ ██╔╝██╔════╝██╔══██╗
██║     ██║██╔██╗ ██║█████╔╝ █████╗  ██████╔╝
██║     ██║██║╚██╗██║██╔═██╗ ██╔══╝  ██╔══██╗
███████╗██║██║ ╚████║██║  ██╗███████╗██║  ██║
╚══════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
"
}

clear_existing_dotfiles() {
  if is_directory_exist "${DOTFILES_REPO_LOCAL_PATH}" && [[ "${DOTFILES_REPO_LOCAL_PATH}" == *dotfiles* ]]; then
    log_info "Clearing existing dotfiles repository"
    cmd_run "rm -rf ${DOTFILES_REPO_LOCAL_PATH}"
  fi
}

clone_repository() {
  local clone_path=$1
  local clone_url=$2
  local clone_branch=$3

  if [[ -z ${clone_branch} ]]; then
    clone_branch="master"
  fi

  if ! is_directory_exist "${clone_path}"; then
    log_info "Creating a new repository clone path. path: ${clone_path}"
    cmd_run "mkdir -p ${clone_path}"
  fi

  log_info "Cloning repository. url: ${clone_url}, branch: ${clone_branch}"
  cmd_run "git -C ${clone_path} clone --branch ${clone_branch} --single-branch ${clone_url} --quiet"
}

run_link_command() {
  local clone_url=$1
  local clone_branch=$2

  linker_print_banner

  local prompt_msg="Clone and link a dotfiles repository"
  local prompt_severity="warning"
  if is_directory_exist "${DOTFILES_REPO_LOCAL_PATH}" && [[ "${DOTFILES_REPO_LOCAL_PATH}" == *dotfiles* ]]; then
    prompt_msg="Overwrite the local dotfiles repository with a new one"
    prompt_severity="critical"
  fi

  if [[ $(prompt_yes_no "${prompt_msg}" "${prompt_severity}") == "y" ]]; then

    new_line
    clear_existing_dotfiles
    clone_repository \
      "${CONFIG_FOLDER_PATH}" \
      "${clone_url}" \
      "${clone_branch}"

    new_line
    log_info "Dotfiles repository linked successfully"
    return 0

  else
    new_line
    log_info "Nothing was linked."
  fi

  return 1
}
