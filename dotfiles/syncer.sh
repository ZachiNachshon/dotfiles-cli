#!/bin/bash

# Title         Sync files from the dotfiles repository
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Create symlinks and source files from the dotfiles repository
#               (options: home/session/shell/transient/custom/all)
#==============================================================================
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/logger.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/prompter.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/io.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/strings.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/shell.sh"

DOTFILES_REPO_SYNCER_TRANSIENT_HOME_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/transient"
DOTFILES_REPO_SYNCER_SESSION_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/session"
DOTFILES_REPO_SYNCER_CUSTOM_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/custom"
DOTFILES_REPO_SYNCER_HOME_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/home"
DOTFILES_REPO_SYNCER_SHELL_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/shell"

dotfiles_print_banner() {
  echo -e "
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
"
}

_create_symlinks_from_path_to_destination() {
  local files_path=$1
  local symlinks_destination=$2
  local files_to_symlink=$(find "${files_path}" -name ".*" \
    -name ".*" \
    -not -name ".gitignore" \
    -not -name ".travis.yml" \
    -not -name ".git" \
    -not -name ".*.swp" \
    -not -name ".gnupg" \
    -not -name ".idea")

  for file_path in ${files_to_symlink}; do
    filename=$(basename "${file_path}")
    symlink_path="${symlinks_destination}/${filename}"

    # Install .zsh files only for zsh shell and vice versa for .bash files and bash shell
    if is_file_extension "${filename}" "zsh" && shell_is_zsh; then
      create_symlink "${symlink_path}" "${file_path}"
      log_indicator_good "${symlink_path} --> ${file_path}"
    elif is_file_extension "${filename}" "bash" && shell_is_bash; then
      create_symlink "${symlink_path}" "${file_path}"
      log_indicator_good "${symlink_path} --> ${file_path}"
    else
      create_symlink "${symlink_path}" "${file_path}"
      log_indicator_good "${symlink_path} --> ${file_path}"
    fi
  done
}

_source_files_from_path() {
  local files_path=$1
  local files_to_source=$(find "${files_path}" -name ".*" \
    -name ".*" \
    -not -name ".gitignore" \
    -not -name ".travis.yml" \
    -not -name ".git" \
    -not -name ".*.swp" \
    -not -name ".gnupg" \
    -not -name ".idea")

  for file_path in ${files_to_source}; do
    filename=$(basename "${file_path}")
    # echo ${file_path}
    source "${file_path}"
    log_indicator_good "Sourced ${filename}"
  done
}

syncer_create_shell_dir_symlinks() {
  _create_symlinks_from_path_to_destination "${DOTFILES_REPO_SYNCER_SHELL_PATH}" "${HOME}"
}

syncer_create_home_dir_symlinks() {
  _create_symlinks_from_path_to_destination "${DOTFILES_REPO_SYNCER_HOME_PATH}" "${HOME}"
}

syncer_source_session_files() {
  _source_files_from_path "${DOTFILES_REPO_SYNCER_SESSION_PATH}"
}

syncer_source_transient_files() {
  _source_files_from_path "${DOTFILES_REPO_SYNCER_TRANSIENT_HOME_PATH}"
}

syncer_source_custom_files() {
  _source_files_from_path "${DOTFILES_REPO_SYNCER_CUSTOM_PATH}"
}

run_sync_command() {
  # home/session/shell/transient/custom/all
  local dotfiles_option=$1

  dotfiles_print_banner

  if [[ $(prompt_yes_no "Sync and source dotfiles" "warning") == "y" ]]; then

    if [[ "${dotfiles_option}" == "home" || "${dotfiles_option}" == "all" ]]; then
      new_line
      syncer_create_home_dir_symlinks
    fi

    if [[ "${dotfiles_option}" == "transient" || "${dotfiles_option}" == "all" ]]; then
      syncer_source_transient_files
    fi

    if [[ "${dotfiles_option}" == "session" || "${dotfiles_option}" == "all" ]]; then
      new_line
      syncer_source_session_files
    fi

    if [[ "${dotfiles_option}" == "custom" || "${dotfiles_option}" == "all" ]]; then
      new_line
      syncer_source_custom_files
    fi

    if [[ "${dotfiles_option}" == "shell" || "${dotfiles_option}" == "all" ]]; then
      new_line
      syncer_create_shell_dir_symlinks
    fi

    new_line
    log_info "Dotfiles were synced successfully"
    
  else
    new_line
    log_info "Nothing was synced."
  fi
}
