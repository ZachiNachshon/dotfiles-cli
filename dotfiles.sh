#!/bin/bash

# Title         Dotfiles CLI (https://github.com/ZachiNachshon/dotfiles-cli)
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Load plugins and scripts in a centralized place instead of
#               having scattered load commands on shell-rc file(s).
#==============================================================================

# DOTFILES_CLI_INSTALL_PATH="$HOME/.config/dotfiles-cli"
DOTFILES_CLI_INSTALL_PATH="${HOME}/codebase/github/dotfiles-cli"
DOTFILES_REPO_LOCAL_PATH="${HOME}/.config/dotfiles"

source "${DOTFILES_CLI_INSTALL_PATH}/brew/brew.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/dotfiles/syncer.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/os/mac/mac.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/os/linux/linux.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/logger.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/prompter.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/git.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/io.sh"

SCRIPT_MENU_TITLE="Dotfiles"

CLI_ARGUMENT_SYNC_COMMAND=""
CLI_ARGUMENT_UNSYNC_COMMAND=""
CLI_ARGUMENT_SYNC_REPO_DOTFILES=""
CLI_ARGUMENT_BREW_COMMAND=""
CLI_ARGUMENT_OS_COMMAND=""
CLI_ARGUMENT_RELOAD_DOTFILES=""
CLI_ARGUMENT_LOCATIONS=""
CLI_ARGUMENT_REPOSITORY=""
CLI_ARGUMENT_VERSION=""

CLI_VALUE_SYNC_OPTION=""
CLI_VALUE_UNSYNC_OPTION=""
CLI_VALUE_BREW_OPTION=""
CLI_VALUE_OS_OPTION=""

CLI_OPTION_DRY_RUN=""
CLI_OPTION_VERBOSE=""
CLI_OPTION_SILENT=""

is_sync_dotfiles() {
  [[ -n ${CLI_ARGUMENT_SYNC_COMMAND} ]]
}

is_unsync_dotfiles() {
  [[ -n ${CLI_ARGUMENT_UNSYNC_COMMAND} ]]
}

is_sync_repo_dotfiles() {
  [[ -n ${CLI_ARGUMENT_SYNC_REPO_DOTFILES} ]]
}

is_brew_command() {
  [[ -n ${CLI_ARGUMENT_BREW_COMMAND} ]]
}

is_os_command() {
  [[ -n ${CLI_ARGUMENT_OS_COMMAND} ]]
}

is_reload_dotfiles() {
  [[ -n ${CLI_ARGUMENT_RELOAD_DOTFILES} ]]
}

is_print_locations() {
  [[ -n ${CLI_ARGUMENT_LOCATIONS} ]]
}

is_change_dir_to_dotfiles_repo() {
  [[ -n ${CLI_ARGUMENT_REPOSITORY} ]]
}

is_print_version() {
  [[ -n ${CLI_ARGUMENT_VERSION} ]]
}

print_cli_used_locations_and_exit() {
  echo -e """${COLOR_WHITE}LOCATIONS${COLOR_NONE}:

  ${COLOR_LIGHT_CYAN}Clone Path${COLOR_NONE}.......: $HOME/.config/dotfiles

${COLOR_WHITE}HOMEBREW PATHS${COLOR_NONE}:

  ${COLOR_LIGHT_CYAN}Brew Repository${COLOR_NONE}...: /usr/local/Homebrew
  ${COLOR_LIGHT_CYAN}Brew Symlinks${COLOR_NONE}.....: /usr/local/opt
  ${COLOR_LIGHT_CYAN}Brew Packages${COLOR_NONE}.....: /usr/local/Cellar
  ${COLOR_LIGHT_CYAN}Brew Casks${COLOR_NONE}........: /usr/local/Caskroom

  ${COLOR_LIGHT_CYAN}Dotfiles Brew Packages${COLOR_NONE}...: $(pwd)/brew/packages.txt
  ${COLOR_LIGHT_CYAN}Dotfiles Brew Casks${COLOR_NONE}......: $(pwd)/brew/casks.txt
  ${COLOR_LIGHT_CYAN}Dotfiles Brew Drivers${COLOR_NONE}....: $(pwd)/brew/drivers.txt
  ${COLOR_LIGHT_CYAN}Dotfiles Brew Services${COLOR_NONE}...: $(pwd)/brew/services.txt
 
${COLOR_WHITE}ENV VARS${COLOR_NONE}:

  ${COLOR_LIGHT_CYAN}TEST_ENV_VAR${COLOR_NONE}..: test
"""
  exit 0
}

print_local_versions_and_exit() {
  local version=$(cat ${DOTFILES_CLI_INSTALL_PATH}/resources/version.txt)
  echo -e "dotfiles ${version}"
  exit 0
}

reload_session_files_inner() {
  if ! is_dry_run; then
    for file in $(find ${DOTFILES_REPO_LOCAL_PATH}/dotfiles/session -name ".*"); do
    #  echo "${file}"
      source ${file}
    done
  fi  
  log_indicator_good "Sourced session dotfiles"
}

reload_transient_files() {
  if ! is_dry_run; then
    for file in $(find ${DOTFILES_REPO_LOCAL_PATH}/dotfiles/transient -name ".*"); do
    #  echo "${file}"
      source ${file}
    done
  fi  
  log_indicator_good "Sourced transient dotfiles"
}

reload_custom_files_inner() {
  if ! is_dry_run; then
    for file in $(find ${DOTFILES_REPO_LOCAL_PATH}/dotfiles/custom -name ".*"); do
    #  echo "${file}"
      source ${file}
    done
  fi  
  log_indicator_good "Sourced custom dotfiles"
}

reload_active_shell_session_and_exit() {
  reload_transient_files
  reload_session_files_inner
  reload_custom_files_inner
  # source ~/.zshrc
  # exec zsh
  exit 0
}

run_brew_command_and_exit() {
  run_homebrew_command "${CLI_VALUE_BREW_OPTION}"
  exit 0
}

run_unsync_command_and_exit() {
  run_unsync_command "${CLI_VALUE_UNSYNC_OPTION}"
  exit 0
}

run_os_settings_command_and_exit() {
  if [[ "${CLI_VALUE_OS_OPTION}" == "mac" ]]; then
    run_os_mac_settings_command
  elif [[ "${CLI_VALUE_OS_OPTION}" == "linux" ]]; then
    run_os_linux_settings_command
  else
    log_fatal "Option not supoprted. value: ${CLI_VALUE_OS_OPTION}"
  fi
  exit 0
}

change_dir_to_dotfiles_local_repo_and_exit() {
  if ! is_directory_exist "${DOTFILES_REPO_LOCAL_PATH}"; then
    log_fatal "Invalid dotfiles directory, forgot to install/clone? path: ${DOTFILES_REPO_LOCAL_PATH}"
  fi

  log_info "Changing directory to ${DOTFILES_REPO_LOCAL_PATH}"  
  cd "${DOTFILES_REPO_LOCAL_PATH}" || exit
  # Read the following link to understand why we should use SHELL in here
  # https://unix.stackexchange.com/a/278080
  $SHELL
  exit 0
}

print_help_menu_and_exit() {
  local exec_filename=$1
  local base_exec_filename=$(basename "${exec_filename}")
  echo -e "${SCRIPT_MENU_TITLE} - Manage a local development environment"
  echo -e " "
  echo -e "${COLOR_WHITE}USAGE${COLOR_NONE}"
  echo -e "  "${base_exec_filename}" [command] [flag]"
  echo -e " "
  echo -e "${COLOR_WHITE}AVAILABLE COMMANDS${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}sync${COLOR_NONE} [option]             Sync and source dotfiles by catagory (options: home/session/shell/transient/custom/all)"
  echo -e "  ${COLOR_LIGHT_CYAN}unsync${COLOR_NONE} [option]           Unsync dotfiles symlinks by catagory (options: home/shell/all)"
  echo -e "  ${COLOR_LIGHT_CYAN}brew${COLOR_NONE} [option]             Update local brew components (options: packages/casks/drivers/services/all)"
  echo -e "  ${COLOR_LIGHT_CYAN}os${COLOR_NONE} [option]               Update OS settings and preferences (options: mac/linux)"
  echo -e "  ${COLOR_LIGHT_CYAN}reload${COLOR_NONE}                    Reload active shell session"
  echo -e "  ${COLOR_LIGHT_CYAN}locations${COLOR_NONE}                 Print locations used for config/repositories/symlinks/clone-path"
  echo -e "  ${COLOR_LIGHT_CYAN}init${COLOR_NONE}                      Prompt for dotfiles git repo and perform a fresh clone"
  echo -e "  ${COLOR_LIGHT_CYAN}update${COLOR_NONE}                    Update or fresh clone the dotfiles repo and link afterwards"
  echo -e "  ${COLOR_LIGHT_CYAN}repo${COLOR_NONE}                      Change directory to the dotfiles local git repository"
  echo -e "  ${COLOR_LIGHT_CYAN}version${COLOR_NONE}                   Print dotfiles client commit-hash"
  echo -e " "
  echo -e "${COLOR_WHITE}FLAGS${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}--dry-run${COLOR_NONE}                 Run all commands in dry-run mode without file system changes"
  echo -e "  ${COLOR_LIGHT_CYAN}-y${COLOR_NONE}                        Do not prompt for approval and accept everything"
  echo -e "  ${COLOR_LIGHT_CYAN}-h${COLOR_NONE} (--help)               Show available actions and their description"
  echo -e "  ${COLOR_LIGHT_CYAN}-v${COLOR_NONE} (--verbose)            Output debug logs for deps-syncer client commands executions"
  echo -e "  ${COLOR_LIGHT_CYAN}-s${COLOR_NONE} (--silent)             Do not output logs for deps-syncer client commands executions"
  echo -e " "
  exit 0
}

parse_program_arguments() {
  if [ $# = 0 ]; then
    print_help_menu_and_exit "$0"
  fi

  while test $# -gt 0; do
    case "$1" in
    -h | --help)
      print_help_menu_and_exit "$0"
      shift
      ;;
    sync)
      CLI_ARGUMENT_SYNC_COMMAND="sync"
      shift
      CLI_VALUE_SYNC_OPTION=$1
      shift
      ;;
    unsync)
      CLI_ARGUMENT_UNSYNC_COMMAND="unsync"
      shift
      CLI_VALUE_UNSYNC_OPTION=$1
      shift
      ;;
    reload)
      CLI_ARGUMENT_RELOAD_DOTFILES="reload"
      shift
      ;;
    brew)
      CLI_ARGUMENT_BREW_COMMAND="brew"
      shift
      CLI_VALUE_BREW_OPTION=$1
      shift
      ;;
    os)
      CLI_ARGUMENT_OS_COMMAND="brew"
      shift
      CLI_VALUE_OS_OPTION=$1
      shift
      ;;
    repo)
      CLI_ARGUMENT_REPOSITORY="repo"
      shift
      ;;
    locations)
      CLI_ARGUMENT_LOCATIONS="locations"
      shift
      ;;
    version)
      CLI_ARGUMENT_VERSION="version"
      shift
      ;;
    --dry-run)
      # Used by logger.sh
      export LOGGER_DRY_RUN="true"
      # Used by brew.sh
      export CLI_OPTION_DRY_RUN="true"
      shift
      ;;
    -y)
      # Used by prompter.sh
      export PROMPTER_SKIP_PROMPT="y"
      shift
      ;;
    -v | --verbose)
      # Used by brew.sh
      export CLI_OPTION_VERBOSE="verbose"
      shift
      ;;
    -s | --silent)
      # Used by logger.sh
      export LOGGER_SILENT="true"
      # Used by brew.sh
      export CLI_OPTION_SILENT="true"
      shift
      ;;
    *)
      print_help_menu_and_exit "$0"
      shift
      ;;
    esac
  done

  # Set defaults
  CLI_OPTION_VERBOSE=${CLI_OPTION_VERBOSE=''}
  CLI_OPTION_DRY_RUN=${CLI_OPTION_DRY_RUN=''}
  CLI_OPTION_SILENT=${CLI_OPTION_SILENT=''}
}

verify_program_arguments() {
  if check_invalid_sync_command_value; then
    # Verify proper command args ordering: dotfiles sync all --dry-run -v
    log_fatal "Command 'sync' is missing a mandatory option. options: home/session/shell/transient/custom/all"
  elif check_invalid_unsync_command_value; then
    # Verify proper command args ordering: dotfiles unsync shell --dry-run -v
    log_fatal "Command 'unsync' is missing a mandatory option. options: home/shell/all"
  elif check_invalid_brew_command_value; then
    # Verify proper command args ordering: dotfiles brew casks --dry-run -v
    log_fatal "Command 'brew' is missing a mandatory option. options: packages/casks/drivers/services/all"
  elif check_invalid_os_command_value; then
    # Verify proper command args ordering: dotfiles os mac --dry-run -v
    log_fatal "Command 'os' is missing a mandatory option. options: mac/linux"
  fi
}

check_invalid_sync_command_value() {
  # If sync command is not empty and its value is a flag - not valid
  [[ -n "${CLI_ARGUMENT_SYNC_COMMAND}" && (-z "${CLI_VALUE_SYNC_OPTION}" || "${CLI_VALUE_SYNC_OPTION}" == -*) ]]
}

check_invalid_unsync_command_value() {
  # If unsync command is not empty and its value is a flag - not valid
  [[ -n "${CLI_ARGUMENT_UNSYNC_COMMAND}" && (-z "${CLI_VALUE_UNSYNC_OPTION}" || "${CLI_VALUE_UNSYNC_OPTION}" == -*) ]]
}

check_invalid_brew_command_value() {
  # If brew command is not empty and its value is a flag - not valid
  [[ -n "${CLI_ARGUMENT_BREW_COMMAND}" && (-z "${CLI_VALUE_BREW_OPTION}" || "${CLI_VALUE_BREW_OPTION}" == -*) ]]
}

check_invalid_os_command_value() {
  # If brew command is not empty and its value is a flag - not valid
  [[ -n "${CLI_ARGUMENT_OS_COMMAND}" && (-z "${CLI_VALUE_OS_OPTION}" || "${CLI_VALUE_OS_OPTION}" == -*) ]]
}

is_dry_run() {
  [[ -n "${CLI_OPTION_DRY_RUN}" ]]
}

is_debug() {
  [[ -n "${CLI_OPTION_VERBOSE}" ]]
}

is_silent() {
  [[ -n "${CLI_OPTION_SILENT}" ]]
}

main() {
  parse_program_arguments "$@"
  verify_program_arguments

  if is_print_version; then
    print_local_versions_and_exit
  fi

  if is_change_dir_to_dotfiles_repo; then
    change_dir_to_dotfiles_local_repo_and_exit
  fi

  if is_print_locations; then
    print_cli_used_locations_and_exit
  fi

  if is_sync_dotfiles; then
    run_sync_command "${CLI_VALUE_SYNC_OPTION}"
    reload_active_shell_session_and_exit
  fi

  if is_unsync_dotfiles; then
    run_unsync_command_and_exit
  fi

  if is_brew_command; then
    run_brew_command_and_exit
  fi

  if is_os_command; then
    run_os_settings_command_and_exit
  fi

  if is_reload_dotfiles; then
    reload_active_shell_session_and_exit
  fi
}

main "$@"
