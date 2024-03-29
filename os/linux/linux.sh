#!/bin/bash

# Title        Linux settings perferences
# Description  Customize Linux settings preferences
# Author       Zachi Nachshon <zachi.nachshon@gmail.com>
#==============================================================================
LINUX_CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
LINUX_OS_FOLDER_ABS_PATH=$(dirname "${LINUX_CURRENT_FOLDER_ABS_PATH}")
LINUX_ROOT_FOLDER_ABS_PATH=$(dirname "${LINUX_OS_FOLDER_ABS_PATH}")

source "${LINUX_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/logger.sh"
source "${LINUX_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/io.sh"
source "${LINUX_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/cmd.sh"

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
  if is_directory_empty "${LINUX_SCRIPTS_FOLDER_PATH}"; then
    log_warning "No Linux scripts were found."
  else
    log_info "Running Linux scripts. path: ${LINUX_SCRIPTS_FOLDER_PATH}"
    new_line

    for file in ${LINUX_SCRIPTS_FOLDER_PATH}/*; do
      if is_file_exist "${file}"; then
        f=$(basename ${file})
        cmd_run "eval '${file}'"
        log_indicator_good "${f}"
      fi
    done

    new_line
    log_info "Settings for Linux were applied successfully, ${COLOR_YELLOW}RESTART IS REQUIRED${COLOR_NONE}."
  fi
}

run_os_linux_settings_command() {
  os_linux_print_banner

  if [[ $(prompt_yes_no "Override Linux setting with personal preferences" "warning") == "y" ]]; then

    new_line
    eval_linux_scripts

  else
    log_info "Nothing was changed."
  fi
}
