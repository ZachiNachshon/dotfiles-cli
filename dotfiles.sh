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
source "${DOTFILES_CLI_INSTALL_PATH}/dotfiles/unsyncer.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/os/mac/mac.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/os/linux/linux.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/plugins/plugins.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/logger.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/prompter.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/git.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/io.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/shell.sh"
source "${DOTFILES_CLI_INSTALL_PATH}/external/shell_scripts_lib/os.sh"

SCRIPT_MENU_TITLE="Dotfiles"

CLI_ARGUMENT_SYNC_COMMAND=""
CLI_ARGUMENT_UNSYNC_COMMAND=""
CLI_ARGUMENT_SYNC_REPO_DOTFILES=""
CLI_ARGUMENT_BREW_COMMAND=""
CLI_ARGUMENT_OS_COMMAND=""
CLI_ARGUMENT_PLUGINS_COMMAND=""
CLI_ARGUMENT_RELOAD_DOTFILES=""
CLI_ARGUMENT_CONFIG=""
CLI_ARGUMENT_STRUCTURE=""
CLI_ARGUMENT_REPOSITORY=""
CLI_ARGUMENT_VERSION=""

CLI_VALUE_SYNC_OPTION=""
CLI_VALUE_UNSYNC_OPTION=""
CLI_VALUE_BREW_OPTION=""
CLI_VALUE_PLUGINS_OPTION=""
CLI_VALUE_OS_OPTION=""

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

is_plugins_command() {
  [[ -n ${CLI_ARGUMENT_PLUGINS_COMMAND} ]]
}

is_os_command() {
  [[ -n ${CLI_ARGUMENT_OS_COMMAND} ]]
}

is_reload_dotfiles() {
  [[ -n ${CLI_ARGUMENT_RELOAD_DOTFILES} ]]
}

is_print_config() {
  [[ -n ${CLI_ARGUMENT_CONFIG} ]]
}

is_print_structure() {
  [[ -n ${CLI_ARGUMENT_STRUCTURE} ]]
}

is_change_dir_to_dotfiles_repo() {
  [[ -n ${CLI_ARGUMENT_REPOSITORY} ]]
}

is_print_version() {
  [[ -n ${CLI_ARGUMENT_VERSION} ]]
}

print_empty_dotfiles_repo_folder() {
  echo -e """
${COLOR_YELLOW}Oops, seems like you forgot to clone a dotfiles repository.

Please run the following command (change org & repo):${COLOR_NONE}

  mkdir -p ${HOME}/.config; \
  cd ${HOME}/.config && git clone https://github.com/ORGANIZATION/REPOSITORY.git 
"""
}

print_config_and_exit() {
  echo -e """
${COLOR_WHITE}GENERAL INFO${COLOR_NONE}:

  ${COLOR_LIGHT_CYAN}Operating System${COLOR_NONE}....: $(read_os_type)
  ${COLOR_LIGHT_CYAN}Architecture${COLOR_NONE}........: $(read_arch "x86_64:amd64" "armv:arm")
  ${COLOR_LIGHT_CYAN}Shell${COLOR_NONE}...............: $(shell_get_name)

${COLOR_WHITE}LOCATIONS${COLOR_NONE}:

  ${COLOR_LIGHT_CYAN}Dotfiles Clone Path${COLOR_NONE}........: ${DOTFILES_REPO_LOCAL_PATH}
  ${COLOR_LIGHT_CYAN}CLI Global Binary${COLOR_NONE}..........: ${DOTFILES_CLI_INSTALL_PATH}

${COLOR_WHITE}HOMEBREW PATHS${COLOR_NONE}:

  ${COLOR_LIGHT_CYAN}Brew Repository${COLOR_NONE}...: /usr/local/Homebrew
  ${COLOR_LIGHT_CYAN}Brew Symlinks${COLOR_NONE}.....: /usr/local/opt
  ${COLOR_LIGHT_CYAN}Brew Packages${COLOR_NONE}.....: /usr/local/Cellar
  ${COLOR_LIGHT_CYAN}Brew Casks${COLOR_NONE}........: /usr/local/Caskroom

  ${COLOR_LIGHT_CYAN}Dotfiles Brew Packages${COLOR_NONE}...: ${DOTFILES_REPO_LOCAL_PATH}/brew/packages.txt
  ${COLOR_LIGHT_CYAN}Dotfiles Brew Casks${COLOR_NONE}......: ${DOTFILES_REPO_LOCAL_PATH}/brew/casks.txt
  ${COLOR_LIGHT_CYAN}Dotfiles Brew Drivers${COLOR_NONE}....: ${DOTFILES_REPO_LOCAL_PATH}/brew/drivers.txt
  ${COLOR_LIGHT_CYAN}Dotfiles Brew Services${COLOR_NONE}...: ${DOTFILES_REPO_LOCAL_PATH}/brew/services.txt
 
${COLOR_WHITE}ENV VARS${COLOR_NONE}:

  ${COLOR_LIGHT_CYAN}TEST_ENV_VAR${COLOR_NONE}..: test"""

  exit 0
}

print_structure_and_exit() {
  echo -e """
This is the expected dotfiles repository structure to properly integrate with the dotfiles-cli.

.
├── ...${COLOR_LIGHT_CYAN}
├── brew                        # Homebrew components, items on each file should be separated by new line
│   ├── casks.txt
│   ├── drivers.txt
│   ├── packages.txt
│   ├── services.txt
│   └── taps.txt${COLOR_NONE}
${COLOR_GREEN}│
├── dotfiles               
│   ├── custom                  # Custom files to source on every new shell session (workplace/personal)
│   │   ├── .my-company  
│   │   └── ...
│   ├── home                    # Files to symlink into HOME folder
│   │   ├── .gitconfig       
│   │   ├── .vimrc
│   │   └── ...
│   ├── session                 # Files to source on new shell sessions
│   │   ├── .aliases
│   │   └── ...
│   ├── shell                   # Shell run commands files to symlink into HOME folder
│   │   ├── .zshrc
│   │   └── ...
│   └── transient               # Files to source on new shell session (not symlinked, can be git-ignored)
│       └── .secrets${COLOR_NONE}
${COLOR_YELLOW}│
├── os
│   ├── linux                   # Scripts to configure Linux settings and preferences
│   │   ├── key_bindings.sh
│   │   └── ...
│   └── mac
│       ├── finder_settings.sh  # Scripts to configure macOS settings and preferences
│       └── ...${COLOR_NONE}
${COLOR_PURPLE}│
├── plugins
│   ├── zsh                     # Scripts to install ZSH plugins
│   │   ├── oh_my_zsh.sh  
│   │   └── ...
│   └── bash                    # Scripts to install Bash plugins
│       ├── dummy.sh
│       └── ...${COLOR_NONE}
└── ...

For a dotfiles example repository please visit:

  https://github.com/ZachiNachshon/dotfiles-example.git
"""
  exit 0
}

print_local_versions_and_exit() {
  local version=$(cat ${DOTFILES_CLI_INSTALL_PATH}/resources/version.txt)
  echo -e "dotfiles ${version}"
  exit 0
}

reload_active_shell_session_and_exit() {
  # Session files are being sources directly from the shell RC file (zshrc, bashrc etc..)
  # For more information please refer to reload_session.sh
  local shell_in_use=$(shell_get_name)
  local reload_session_silent_option="False"
  if is_silent; then 
    reload_session_silent_option="True"
  fi
  (export DOTFILES_CLI_SILENT_OPTION=${reload_session_silent_option} && exec ${shell_in_use})
  exit 0
}

run_brew_command_and_exit() {
  run_homebrew_command "${CLI_VALUE_BREW_OPTION}"
  exit 0
}

run_plugins_command_and_exit() {
  run_plugins_command "${CLI_VALUE_PLUGINS_OPTION}"
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
    print_empty_dotfiles_repo_folder
  else
    log_info "Changing directory to ${DOTFILES_REPO_LOCAL_PATH}"  
    cd "${DOTFILES_REPO_LOCAL_PATH}" || exit
    # Read the following link to understand why we should use SHELL in here
    # https://unix.stackexchange.com/a/278080
    (export DOTFILES_CLI_SILENT_OPTION="True" && $SHELL)
  fi
  exit 0
}

print_help_menu_and_exit() {
  local exec_filename=$1
  local base_exec_filename=$(basename "${exec_filename}")
  echo -e "${SCRIPT_MENU_TITLE} - Manage a local development environment"
  echo -e " "
  echo -e "${COLOR_WHITE}USAGE${COLOR_NONE}"
  echo -e "  "${base_exec_filename}" [command] [option] [flag]"
  echo -e " "
  echo -e "${COLOR_WHITE}AVAILABLE COMMANDS${COLOR_NONE}"
  echo -e "  ${COLOR_LIGHT_CYAN}sync${COLOR_NONE} <option>             Sync dotfiles symlinks by catagory [${COLOR_GREEN}options: home/shell/all${COLOR_NONE}]"
  echo -e "  ${COLOR_LIGHT_CYAN}unsync${COLOR_NONE} <option>           Unsync dotfiles symlinks by catagory [${COLOR_GREEN}options: home/shell/all${COLOR_NONE}]"
  echo -e "  ${COLOR_LIGHT_CYAN}brew${COLOR_NONE} <option>             Update local brew components [${COLOR_GREEN}options: packages/casks/drivers/services/all${COLOR_NONE}]"
  echo -e "  ${COLOR_LIGHT_CYAN}os${COLOR_NONE} <option>               Update OS settings and preferences [${COLOR_GREEN}options: mac/linux${COLOR_NONE}]"
  echo -e "  ${COLOR_LIGHT_CYAN}plugins${COLOR_NONE} <option>          Install plugins for specific shell [${COLOR_GREEN}options: bash/zsh${COLOR_NONE}]"
  echo -e "  ${COLOR_LIGHT_CYAN}reload${COLOR_NONE}                    Reload active shell session in order transient-session-custom"
  echo -e "  ${COLOR_LIGHT_CYAN}config${COLOR_NONE}                    Print config/paths/symlinks/clone-path"
  echo -e "  ${COLOR_LIGHT_CYAN}structure${COLOR_NONE}                 Print the dotfiles repository expected structure"
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
    plugins)
      CLI_ARGUMENT_PLUGINS_COMMAND="plugins"
      shift
      CLI_VALUE_PLUGINS_OPTION=$1
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
    config)
      CLI_ARGUMENT_CONFIG="config"
      shift
      ;;
    structure)
      CLI_ARGUMENT_STRUCTURE="structure"
      shift
      ;;
    version)
      CLI_ARGUMENT_VERSION="version"
      shift
      ;;
    --dry-run)
      # Used by logger.sh / reload_session.sh
      export LOGGER_DRY_RUN="true"
      shift
      ;;
    -y)
      # Used by prompter.sh
      export PROMPTER_SKIP_PROMPT="y"
      shift
      ;;
    -v | --verbose)
      # Used by logger.sh
      export LOGGER_DEBUG="true"
      shift
      ;;
    -s | --silent)
      # Used by logger.sh / reload_session.sh
      export LOGGER_SILENT="true"
      shift
      ;;
    *)
      print_help_menu_and_exit "$0"
      shift
      ;;
    esac
  done
}

verify_program_arguments() {
  if check_invalid_sync_command_value; then
    # Verify proper command args ordering: dotfiles sync all --dry-run -v
    log_fatal "Command 'sync' is missing a mandatory option. options: home/shell/all"
  elif check_invalid_unsync_command_value; then
    # Verify proper command args ordering: dotfiles unsync shell --dry-run -v
    log_fatal "Command 'unsync' is missing a mandatory option. options: home/shell/all"
  elif check_invalid_brew_command_value; then
    # Verify proper command args ordering: dotfiles brew casks --dry-run -v
    log_fatal "Command 'brew' is missing a mandatory option. options: packages/casks/drivers/services/all"
  elif check_invalid_plugins_command_value; then
    # Verify proper command args ordering: dotfiles plugins zsh --dry-run -v
    log_fatal "Command 'plugins' is missing a mandatory option. options: bash/zsh"
  elif check_invalid_os_command_value; then
    # Verify proper command args ordering: dotfiles os mac --dry-run -v
    log_fatal "Command 'os' is missing a mandatory option. options: mac/linux"
  fi
}

check_invalid_sync_command_value() {
  # If sync command is not empty and its value is empty or a flag - not valid
  [[ -n "${CLI_ARGUMENT_SYNC_COMMAND}" && (-z "${CLI_VALUE_SYNC_OPTION}" || "${CLI_VALUE_SYNC_OPTION}" == -*) ]] \
  || \
  # If sync options are not part of the valid values
  [[ -n "${CLI_ARGUMENT_SYNC_COMMAND}" && ( \
    "${CLI_VALUE_SYNC_OPTION}" != "home" && \
    "${CLI_VALUE_SYNC_OPTION}" != "shell" && \
    "${CLI_VALUE_SYNC_OPTION}" != "all") ]]
}

check_invalid_unsync_command_value() {
  # If unsync command is not empty and its value is empty or a flag - not valid
  [[ -n "${CLI_ARGUMENT_UNSYNC_COMMAND}" && (-z "${CLI_VALUE_UNSYNC_OPTION}" || "${CLI_VALUE_UNSYNC_OPTION}" == -*) ]] \
  || \
  # If unsync options are not part of the valid values
  [[ -n "${CLI_ARGUMENT_UNSYNC_COMMAND}" && ( \
    "${CLI_VALUE_UNSYNC_OPTION}" != "home" && \
    "${CLI_VALUE_UNSYNC_OPTION}" != "shell" && \
    "${CLI_VALUE_UNSYNC_OPTION}" != "all") ]]
}

check_invalid_brew_command_value() {
  # If brew command is not empty and its value is empty or a flag - not valid
  [[ -n "${CLI_ARGUMENT_BREW_COMMAND}" && (-z "${CLI_VALUE_BREW_OPTION}" || "${CLI_VALUE_BREW_OPTION}" == -*) ]] \
  || \
  # If brew options are not part of the valid values
  [[ -n "${CLI_ARGUMENT_BREW_COMMAND}" && ( \
    "${CLI_VALUE_BREW_OPTION}" != "package" && \
    "${CLI_VALUE_BREW_OPTION}" != "casks" && \
    "${CLI_VALUE_BREW_OPTION}" != "drivers" && \
    "${CLI_VALUE_BREW_OPTION}" != "services" && \
    "${CLI_VALUE_BREW_OPTION}" != "all") ]]
}

check_invalid_plugins_command_value() {
  # If plugins command is not empty and its value is empty or a flag - not valid
  [[ -n "${CLI_ARGUMENT_PLUGINS_COMMAND}" && (-z "${CLI_VALUE_PLUGINS_OPTION}" || "${CLI_VALUE_PLUGINS_OPTION}" == -*) ]] \
  || \
  # If plugins options are not part of the valid values
  [[ -n "${CLI_ARGUMENT_PLUGINS_COMMAND}" && ( \
    "${CLI_VALUE_PLUGINS_OPTION}" != "bash" && \
    "${CLI_VALUE_PLUGINS_OPTION}" != "zsh") ]]
}

check_invalid_os_command_value() {
  # If brew command is not empty and its value is empty or a flag - not valid
  [[ -n "${CLI_ARGUMENT_OS_COMMAND}" && (-z "${CLI_VALUE_OS_OPTION}" || "${CLI_VALUE_OS_OPTION}" == -*) ]] \
  || \
  # If os options are not part of the valid values
  [[ -n "${CLI_ARGUMENT_OS_COMMAND}" && ( \
    "${CLI_VALUE_OS_OPTION}" != "mac" && \
    "${CLI_VALUE_OS_OPTION}" != "linux") ]]
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

  if is_print_config; then
    print_config_and_exit
  fi

  if is_print_structure; then
    print_structure_and_exit
  fi

  if is_sync_dotfiles; then
    if run_sync_command "${CLI_VALUE_SYNC_OPTION}"; then
      # Reload shell session only on successful sync
      log_info "Reloading active shell"
      new_line
      reload_active_shell_session_and_exit
    fi
  fi

  if is_unsync_dotfiles; then
    run_unsync_command_and_exit
  fi

  if is_brew_command; then
    run_brew_command_and_exit
  fi

  if is_plugins_command; then
    run_plugins_command_and_exit
  fi

  if is_os_command; then
    run_os_settings_command_and_exit
  fi

  if is_reload_dotfiles; then
    reload_active_shell_session_and_exit
  fi
}

main "$@"
