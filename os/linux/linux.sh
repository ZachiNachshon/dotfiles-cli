#!/bin/bash

# Title        Linux settings perferences
# Description  Customize Linux settings preferences
# Author       Zachi Nachshon <zachi.nachshon@gmail.com>
#==============================================================================

source "${DOTFILES_CLI_REPO_LOCAL_PATH}/external/shell_scripts_lib/logger.sh"
source "${DOTFILES_CLI_REPO_LOCAL_PATH}/external/shell_scripts_lib/io.sh"

LINUX_SCRIPTS_FOLDER_PATH="${DOTFILES_REPO_LOCAL_PATH}/os/linux"

os_linux_print_banner() {
  echo -e "
██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗
██║     ██║████╗  ██║██║   ██║╚██╗██╔╝
██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ 
██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ 
███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗
╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝
"
}

eval_linux_scripts() {
  log_info "Running Linux scripts. path: ${LINUX_SCRIPTS_FOLDER_PATH}"
  for file in ${LINUX_SCRIPTS_FOLDER_PATH}/*; do
    if is_file_exist "${file}"; then
      f=$(basename ${file})
      new_line
      log_info "Running script. name: ${f}"
      eval "${file}"
      log_indicator_good "${f}"
    fi
  done
}

run_os_linux_settings_command() {
  os_linux_print_banner

  if [[ $(prompt_yes_no "Override Linux setting with personal preferences" "warning") == "y" ]]; then

    new_line
    eval_linux_scripts

    new_line
    log_info "Settings for Linux were applied successfully, ${COLOR_YELLOW}RESTART IS REQUIRED${COLOR_NONE}."

  else
    log_info "Nothing was changed."
  fi
}