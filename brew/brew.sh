#!/bin/bash

# Title         Manage Homebrew components
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Install/upgrade Homebrew packages/casks/services/drivers
#==============================================================================
BREW_CURRENT_FOLDER_ABS_PATH=$(dirname "${BASH_SOURCE[0]}")
BREW_ROOT_FOLDER_ABS_PATH=$(dirname "${BREW_CURRENT_FOLDER_ABS_PATH}")

source "${BREW_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/logger.sh"
source "${BREW_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/cmd.sh"
source "${BREW_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/prompter.sh"
source "${BREW_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/io.sh"
source "${BREW_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/strings.sh"
source "${BREW_ROOT_FOLDER_ABS_PATH}/external/shell_scripts_lib/checks.sh"

DOTFILES_REPO_BREW_PACKAGE_PATH="${DOTFILES_REPO_LOCAL_PATH}/brew/packages.txt"
DOTFILES_REPO_BREW_CASKS_PATH="${DOTFILES_REPO_LOCAL_PATH}/brew/casks.txt"
DOTFILES_REPO_BREW_DRIVERS_PATH="${DOTFILES_REPO_LOCAL_PATH}/brew/drivers.txt"
DOTFILES_REPO_BREW_SERVICES_PATH="${DOTFILES_REPO_LOCAL_PATH}/brew/services.txt"
DOTFILES_REPO_BREW_CUSTOM_TAPS_PATH="${DOTFILES_REPO_LOCAL_PATH}/brew/taps.txt"

brew_print_banner() {
  echo -e "
██╗  ██╗ ██████╗ ███╗   ███╗███████╗██████╗ ██████╗ ███████╗██╗    ██╗
██║  ██║██╔═══██╗████╗ ████║██╔════╝██╔══██╗██╔══██╗██╔════╝██║    ██║
███████║██║   ██║██╔████╔██║█████╗  ██████╔╝██████╔╝█████╗  ██║ █╗ ██║
██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗██╔══██╗██╔══╝  ██║███╗██║
██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗██████╔╝██║  ██║███████╗╚███╔███╔╝
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝  
"
}

brew_verify_and_install_homebrew() {
  log_info "Verifying Homebrew installation..."

  if ! is_dry_run; then
    if check_tool "brew"; then
      log_info "Homebrew is installed."
    else
      log_warning "Homebrew is not installed, installing..."
      cmd_run "/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)""
    fi
  fi
}

brew_install_homebrew_taps() {
  log_info "Tapping to homebrew official taps..."
  # cask-versions enable us to search supported versions by providing a cask name:
  #   - brew search <cask name>
  cmd_run "brew tap homebrew/cask-versions"
  cmd_run "brew tap homebrew/cask-fonts"
  cmd_run "brew tap homebrew/cask-drivers"
}

brew_install_custom_taps() {
  log_info "Tapping to Homebrew custom taps..."
  while read tap_line; do
    if is_comment "${tap_line}"; then
      continue
    fi
    cmd_run "brew tap ${tap_line}"
  done <"${DOTFILES_REPO_BREW_CUSTOM_TAPS_PATH}"
}

brew_update_outdated_plugins() {
  log_info "Updating Hombebrew outdated plugins..."
  cmd_run "brew outdated"
  cmd_run "brew update"
  cmd_run "brew upgrade"
}

brew_install_packages() {
  log_info "Installing/Updating Homebrew packages..."
  local pkgs_to_install=""
  while read pkg_line; do
    if is_comment "${pkg_line}"; then
      continue
    fi
    pkgs_to_install+="${pkg_line} "
  done <"${DOTFILES_REPO_BREW_PACKAGE_PATH}"
  cmd_run "brew install ${pkgs_to_install}"
}

# Retrieve casks information:
#   - brew search <cask name>
#   - brew cask info <cask name>
# -----------------------------------
brew_install_casks() {
  log_info "Installing/Updating Homebrew casks..."
  while read cask_line; do
    if is_comment "${cask_line}"; then
      continue
    fi

    echo -e "
================
Installing Cask: ${cask_line}
================
"
    cmd_run "brew install --cask ${cask_line}"
  done <"${DOTFILES_REPO_BREW_CASKS_PATH}"
}

brew_install_drivers() {
  log_info "Installing/Updating Homebrew drivers..."
  while read driver_line; do
    if is_comment "${driver_line}"; then
      continue
    fi

    echo -e "
==================
Installing Driver: ${driver_line}
==================
"
    cmd_run "brew install --cask ${driver_line}"
  done <"${DOTFILES_REPO_BREW_DRIVERS_PATH}"
}

brew_install_services() {
  log_info "Installing/Updating Homebrew services..."
  while read service_line; do
    if is_comment "${service_line}"; then
      continue
    fi

    echo -e "
===================
Installing Service: ${service_line}
===================
"
    cmd_run "brew install ${service_line}"
    cmd_run "brew services start ${service_line}"
  done <"${DOTFILES_REPO_BREW_SERVICES_PATH}"
}

run_homebrew_command() {
  # packages/casks/drivers/services/all
  local brew_option=$1

  brew_print_banner

  if [[ $(prompt_yes_no "Install/Upgrade '${brew_option}' Homebrew components" "warning") == "y" ]]; then
    new_line
    brew_verify_and_install_homebrew
    brew_install_homebrew_taps
    brew_install_custom_taps
    brew_update_outdated_plugins

    if [[ "${brew_option}" == "packages" || "${brew_option}" == "all" ]]; then
      brew_install_packages
    fi

    if [[ "${brew_option}" == "casks" || "${brew_option}" == "all" ]]; then
      brew_install_casks
    fi

    if [[ "${brew_option}" == "drivers" || "${brew_option}" == "all" ]]; then
      brew_install_drivers
    fi

    if [[ "${brew_option}" == "services" || "${brew_option}" == "all" ]]; then
      brew_install_services
    fi

    log_info "Dotfiles Homebrew command completed successfully"

  else
    new_line
    log_info "Nothing was installed."
  fi
}

# Homebrew cheatsheet
# -----------------------------------
# brew install git          Install a package
# brew install git@2.0.0    Install a package with specific version
# brew uninstall git        Uninstall a package
# brew upgrade git          Upgrade a package
# brew unlink git           Unlink
# brew link git             Link
# brew switch git 2.5.0     Change versions
# brew list --versions git  See what versions you have
# --
# brew info git             List versions, caveats, etc
# brew cleanup git          Remove old versions
# brew edit git             Edit this formula
# brew cat git              Print this formula
# brew home git             Open homepage
# --
# brew update               Update brew and cask
# brew list                 List installed
# brew outdated             What’s due for upgrades?
# -----------------------------------
