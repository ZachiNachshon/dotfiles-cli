#!/bin/bash

# Title        macOS settings preferences
# Description  Customize macOS settings preferences
# Author       Zachi Nachshon <zachi.nachshon@gmail.com>
#==============================================================================
MAC_CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
MAC_OS_FOLDER_ABS_PATH=$(dirname "${MAC_CURRENT_FOLDER_ABS_PATH}")
MAC_ROOT_FOLDER_ABS_PATH=$(dirname "${MAC_OS_FOLDER_ABS_PATH}")

source "${MAC_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/logger.sh"
source "${MAC_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/io.sh"
source "${MAC_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/cmd.sh"

MAC_OS_SCRIPTS_FOLDER_PATH="${DOTFILES_REPO_LOCAL_PATH}/os/mac"

os_mac_print_banner() {
  echo -e "
███╗   ███╗ █████╗  ██████╗               ██████╗ ███████╗
████╗ ████║██╔══██╗██╔════╝              ██╔═══██╗██╔════╝
██╔████╔██║███████║██║         █████╗    ██║   ██║███████╗
██║╚██╔╝██║██╔══██║██║         ╚════╝    ██║   ██║╚════██║
██║ ╚═╝ ██║██║  ██║╚██████╗              ╚██████╔╝███████║
╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝               ╚═════╝ ╚══════╝
"
}

eval_mac_scripts() {
  if is_directory_empty "${MAC_OS_SCRIPTS_FOLDER_PATH}"; then
    log_warning "No macOS scripts were found."
  else
    log_info "Running macOS scripts. path: ${MAC_OS_SCRIPTS_FOLDER_PATH}"
    new_line

    for file in ${MAC_OS_SCRIPTS_FOLDER_PATH}/*; do
      if is_file_exist "${file}"; then
        f=$(basename ${file})
        cmd_run "eval '${file}'"
        log_indicator_good "${f}"
      fi
    done

    new_line
    log_info "Settings for macOS were applied successfully, ${COLOR_YELLOW}RESTART IS REQUIRED${COLOR_NONE}."
  fi
}

run_os_mac_settings_command() {
  os_mac_print_banner

  if [[ $(prompt_yes_no "Override macOS setting with personal preferences" "warning") == "y" ]]; then

    new_line
    eval_mac_scripts

  else
    log_info "Nothing was changed."
  fi
}
