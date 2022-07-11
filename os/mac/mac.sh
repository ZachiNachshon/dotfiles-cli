#!/bin/bash

# Title        macOS settings preferences
# Description  Customize macOS settings preferences
# Author       Zachi Nachshon <zachi.nachshon@gmail.com>
#==============================================================================

source "${DOTFILES_CLI_REPO_LOCAL_PATH}/external/shell_scripts_lib/logger.sh"
source "${DOTFILES_CLI_REPO_LOCAL_PATH}/external/shell_scripts_lib/io.sh"

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
  log_info "Running macOS scripts. path: ${MAC_OS_SCRIPTS_FOLDER_PATH}"
  for file in ${MAC_OS_SCRIPTS_FOLDER_PATH}/*; do
    if is_file_exist "${file}"; then
      f=$(basename ${file})
      new_line
      log_info "Running script. name: ${f}"
      eval "${file}"
      log_indicator_good "${f}"
    fi
  done
}

run_os_mac_settings_command() {
  os_mac_print_banner

  if [[ $(prompt_yes_no "Override macOS setting with personal preferences" "warning") == "y" ]]; then

    new_line
    eval_mac_scripts

    new_line
    log_info "Settings for macOS were applied successfully, ${COLOR_YELLOW}RESTART IS REQUIRED${COLOR_NONE}."

  else
    log_info "Nothing was changed."
  fi
}
