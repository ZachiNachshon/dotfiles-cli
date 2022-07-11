#!/bin/bash

# Title        dotfiles.sh
# Description  Create or remove symlinks for this repository
# Author       Zachi Nachshon <zachi.nachshon@gmail.com>
#==============================================================================

source "${DOTFILES_CLI_REPO_LOCAL_PATH}/external/shell_scripts_lib/logger.sh"
source "${DOTFILES_CLI_REPO_LOCAL_PATH}/external/shell_scripts_lib/prompter.sh"
source "${DOTFILES_CLI_REPO_LOCAL_PATH}/external/shell_scripts_lib/io.sh"
source "${DOTFILES_CLI_REPO_LOCAL_PATH}/external/shell_scripts_lib/strings.sh"
source "${DOTFILES_CLI_REPO_LOCAL_PATH}/external/shell_scripts_lib/shell.sh"

DOTFILES_REPO_LINKER_HOME_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/home"
DOTFILES_REPO_LINKER_SHELL_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/shell"
DOTFILES_REPO_LINKER_MANAGED_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/managed"
DOTFILES_REPO_LINKER_CUSTOM_PATH="${DOTFILES_REPO_LOCAL_PATH}/dotfiles/custom"

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

install_dotfiles() {
  mkdir -p ${DOTFILES_HOME_DIR}
  linker_create_home_dir_symlinks
  linker_symlink_home_files_in_dotfiles_dir
  linker_symlink_managed_files_in_dotfiles_dir
  linker_symlink_custom_files_in_dotfiles_dir
}

linker_create_shell_dir_symlinks() {
  local shell_files=$(find "${DOTFILES_REPO_LINKER_SHELL_PATH}" -name ".*")

  log_info "Symlinking folder: name: $(basename "${DOTFILES_REPO_LINKER_SHELL_PATH}")"
  for file_path in ${shell_files}; do
    filename=$(basename "${file_path}")
    # Install .zsh files only for zsh shell and vice versa for .bash files and bash shell
    if is_file_extension "${filename}" "zsh" && shell_is_zsh; then
      # create_symlink "${HOME}/${filename}" "${file_path}"
      # log_info "Symlinked ${HOME}/${filename} --> ${file_path}"
      log_indicator_good "${HOME}/${filename} --> ${file_path}"
    elif is_file_extension "${filename}" "bash" && shell_is_bash; then
      create_symlink "${HOME}/${filename}" "${file_path}"
      # log_info "Symlinked ${HOME}/${filename} --> ${file_path}"
      log_indicator_good "${HOME}/${filename} --> ${file_path}"
    fi
  done
}

linker_create_home_dir_symlinks() {
  local home_files=$(find "${DOTFILES_REPO_LINKER_HOME_PATH}" -name ".*")

  log_info "Symlinking folder: name: $(basename "${DOTFILES_REPO_LINKER_HOME_PATH}")"
  for file_path in ${home_files}; do
    filename=$(basename "${file_path}")
    # create_symlink "${HOME}/${filename}" "${file_path}"
    log_indicator_good "${HOME}/${filename} --> ${file_path}"
  done
}

linker_source_managed_files() {
  local managed_files=$(find "${DOTFILES_REPO_LINKER_MANAGED_PATH}" -name ".*")

  for file_path in ${managed_files}; do
    filename=$(basename ${file_path})
    echo ${file_path}
    source "${file_path}"
    log_indicator_good "Sourced ${filename}"
  done
}

linker_source_custom_files() {
  local custom_files=$(find  "${DOTFILES_REPO_LINKER_CUSTOM_PATH}" \
    -name ".*" \
    -not -name ".gitignore" \
    -not -name ".travis.yml" \
    -not -name ".git" \
    -not -name ".*.swp" \
    -not -name ".gnupg" \
    -not -name ".idea")

  log_info "Sourcing folder: name: $(basename "${DOTFILES_REPO_LINKER_CUSTOM_PATH}")"
  for file_path in ${custom_files}; do
    filename=$(basename "${file_path}")
    source "${file_path}"
    log_indicator_good "Sourced ${filename}"
  done
}

uninstall_dotfiles() {
  linker_unlink_config_in_dotfiles_dir
  linker_unlink_shells_in_home_dir
  linker_unlink_managed_files_in_dotfiles_dir
  linker_unlink_custom_files_in_dotfiles_dir

  if [[ ${DOTFILES_HOME_DIR} != ${HOME} && -d ${DOTFILES_HOME_DIR} && ${DOTFILES_HOME_DIR} == *"dotfiles"* ]]; then
    rm -r ${DOTFILES_HOME_DIR}
    output+="\nCleanup:\n  ${DOTFILES_HOME_DIR} --> removed."
  fi
}

linker_unlink_config_in_dotfiles_dir() {
  unlink ${DOTFILES_HOME_DIR}/.config 2>/dev/null
  echo -e "\nConfig:\n  ${DOTFILES_HOME_DIR}/.config --> removed."
}

linker_unlink_shells_in_home_dir() {
  local output=""

  local DOT_FILES_TO_UNINSTALL=$(find $(PWD)/dotfiles/shell -name ".*" \
    -not -name ".gitignore" \
    -not -name ".travis.yml" \
    -not -name ".git" \
    -not -name ".*.swp" \
    -not -name ".gnupg" \
    -not -name ".idea")

  for file in ${DOT_FILES_TO_UNINSTALL}; do
    f=$(basename ${file})
    # Uninstall .zsh files only for zsh shell and vice versa for .bash files and bash shell
    if [[ ${f} == *".zsh"* && $(echo ${SHELL}) == *"zsh"* ]]; then
      unlink ${HOME}/${f} 2>/dev/null
      output+="\n  ${HOME}/${f} --> removed."
    elif [[ ${f} == *".bash"* && $(echo ${SHELL}) == *"bash"* ]]; then
      unlink ${HOME}/${f} 2>/dev/null
      output+="\n  ${HOME}/${f} --> removed."
    fi
  done

  echo -e "\nShell:${output}"
}

linker_unlink_managed_files_in_dotfiles_dir() {
  local output=""

  local DOT_FILES_TO_UNINSTALL=$(find $(PWD)/dotfiles/managed -name ".*" \
    -not -name ".gitignore" \
    -not -name ".travis.yml" \
    -not -name ".git" \
    -not -name ".*.swp" \
    -not -name ".gnupg" \
    -not -name ".idea")

  for file in ${DOT_FILES_TO_UNINSTALL}; do
    f=$(basename ${file})
    unlink ${DOTFILES_HOME_DIR}/managed/${f} 2>/dev/null
    output+="\n  ${DOTFILES_HOME_DIR}/managed/${f} --> removed."
  done

  echo -e "\nManaged:${output}"
}

linker_unlink_custom_files_in_dotfiles_dir() {
  local output=""

  local DOT_FILES_TO_UNINSTALL=$(find $(PWD)/dotfiles/custom -name ".*" \
    -not -name ".gitignore" \
    -not -name ".travis.yml" \
    -not -name ".git" \
    -not -name ".*.swp" \
    -not -name ".gnupg" \
    -not -name ".idea")

  for file in ${DOT_FILES_TO_UNINSTALL}; do
    f=$(basename ${file})
    unlink ${DOTFILES_HOME_DIR}/custom/${f} 2>/dev/null
    output+="\n  ${DOTFILES_HOME_DIR}/custom/${f} --> removed."
  done

  echo -e "\nCustom:${output}\n"
}

run_link_command() {
  # home/managed/shell/transient/custom/all
  local dotfiles_option=$1

  dotfiles_print_banner

  if [[ $(prompt_yes_no "Link and source dotfiles" "warning") == "y" ]]; then

    if [[ "${dotfiles_option}" == "home" || "${dotfiles_option}" == "all" ]]; then
      new_line
      linker_create_home_dir_symlinks
    fi

    if [[ "${dotfiles_option}" == "managed" || "${dotfiles_option}" == "all" ]]; then
      new_line
      linker_source_managed_files
    fi
    
    if [[ "${dotfiles_option}" == "shell" || "${dotfiles_option}" == "all" ]]; then
      new_line
      linker_create_shell_dir_symlinks
    fi

    # if [[ "${dotfiles_option}" == "transient" || "${dotfiles_option}" == "all" ]]; then
    #   brew_install_services
    # fi

    if [[ "${dotfiles_option}" == "custom" || "${dotfiles_option}" == "all" ]]; then
      new_line
      linker_source_custom_files
    fi

    new_line
    log_info "Dotfiles were symlinked successfully"
    
  else
    new_line
    log_info "Nothing was symlinked."
  fi
}
