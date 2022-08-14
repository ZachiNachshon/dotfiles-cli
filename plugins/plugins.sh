#!/bin/bash

# Title        Install shell plugins (bash/zsh)
# Description  Install shell plugins (bash/zsh)
# Author       Zachi Nachshon <zachi.nachshon@gmail.com>
#==============================================================================
PLUGINS_CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
PLUGINS_ROOT_FOLDER_ABS_PATH=$(dirname "${PLUGINS_CURRENT_FOLDER_ABS_PATH}")

source "${PLUGINS_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/logger.sh"
source "${PLUGINS_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/io.sh"
source "${PLUGINS_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/cmd.sh"

PLUGINS_SCRIPTS_ROOT_FOLDER_PATH="${DOTFILES_REPO_LOCAL_PATH}/plugins"

plugins_print_banner() {
  echo -e "
██████╗ ██╗     ██╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
██╔══██╗██║     ██║   ██║██╔════╝ ██║████╗  ██║██╔════╝
██████╔╝██║     ██║   ██║██║  ███╗██║██╔██╗ ██║███████╗
██╔═══╝ ██║     ██║   ██║██║   ██║██║██║╚██╗██║╚════██║
██║     ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║███████║
╚═╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝
"
}

eval_plugins_scripts() {
  local plugins_option=$1
  local plugins_folder_path="${PLUGINS_SCRIPTS_ROOT_FOLDER_PATH}/${plugins_option}"

  if is_directory_empty "${plugins_folder_path}"; then
    log_warning "No plugins were found for shell. name: ${plugins_option}"
  else
    log_info "Running plugins scripts. path: ${plugins_folder_path}"
    new_line

    for file in ${plugins_folder_path}/*; do
      if is_file_exist "${file}"; then
        f=$(basename ${file})
        cmd_run "eval '${file}'"
        log_indicator_good "${f}"
      fi
    done

    new_line
    log_info "Plugins for '${plugins_option}' were installed."
  fi
}

run_plugins_command() {
  # bash/zsh
  local plugins_option=$1

  plugins_print_banner

  if [[ $(prompt_yes_no "Install '${plugins_option}' plugins" "warning") == "y" ]]; then

    new_line
    eval_plugins_scripts "${plugins_option}"

  else
    log_info "Nothing was changed."
  fi
}
