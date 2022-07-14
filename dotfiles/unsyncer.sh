#!/bin/bash

# Title         Remove symlinks linked to the dotfiles repository
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Clean environment and remove any dotfiles symlinks
#               (options: home/shell/all)
#==============================================================================
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/logger.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/prompter.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/io.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/strings.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/shell.sh"

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

_remove_symlinks_from_path() {
  local files_path=$1
  local symlinks_destination=$2
  local files_to_unlink=$(find "${files_path}" -name ".*" \
    -name ".*" \
    -not -name ".gitignore" \
    -not -name ".travis.yml" \
    -not -name ".git" \
    -not -name ".*.swp" \
    -not -name ".gnupg" \
    -not -name ".idea")

  for file_path in ${files_to_unlink}; do
    filename=$(basename "${file_path}")
    symlink_path="${symlinks_destination}/${filename}"

    # Uninstall .zsh files only for zsh shell and vice versa for .bash files and bash shell
    if is_file_has_name "${filename}" "zsh" && shell_is_zsh; then
      remove_symlink "${symlink_path}"
      log_indicator_good "Unlinked ${symlink_path}"
    elif is_file_has_name "${filename}" "bash" && shell_is_bash; then
      remove_symlink "${symlink_path}"
      log_indicator_good "Unlinked ${symlink_path}"
    elif ! is_file_extension "${filename}" "zsh" && ! is_file_extension "${filename}" "bash"; then
      remove_symlink "${symlink_path}"
      log_indicator_good "Unlinked ${symlink_path}"
    fi
  done
}

syncer_remove_home_dir_symlinks() {
  _remove_symlinks_from_path "${DOTFILES_REPO_SYNCER_HOME_PATH}" "${HOME}"
}

syncer_remove_shell_dir_symlinks() {
  _remove_symlinks_from_path "${DOTFILES_REPO_SYNCER_SHELL_PATH}" "${HOME}"
}

run_unsync_command() {
  # home/shell/all
  local dotfiles_option=$1

  dotfiles_print_banner

  if [[ $(prompt_yes_no "Unsync dotfiles" "warning") == "y" ]]; then

    if [[ "${dotfiles_option}" == "home" || "${dotfiles_option}" == "all" ]]; then
      new_line
      syncer_remove_home_dir_symlinks
    fi

    if [[ "${dotfiles_option}" == "shell" || "${dotfiles_option}" == "all" ]]; then
      new_line
      syncer_remove_shell_dir_symlinks
    fi

    new_line
    log_info "Dotfiles were unsynced successfully"
    
  else
    new_line
    log_info "Nothing was unsynced."
  fi
}
