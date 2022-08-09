#!/bin/bash

# Title         Dotfiles tests
# Author        Zachi Nachshon <zachi.nachshon@gmail.com>
# Supported OS  Linux & macOS
# Description   Run dotfiles tests suite
#==============================================================================

# TODO: Need to run in a container with bash installed  

TEST_DATA_DOTFILES_REPO_PATH="${PWD}/test_data/dotfiles_repo"  
TEST_DATA_DOTFILES_CLI_REPO_PATH="${PWD}"  

source "external/shell_scripts_lib/logger.sh"
source "external/shell_scripts_lib/shell.sh"
source "external/shell_scripts_lib/test_lib/init.sh"
source "external/shell_scripts_lib/test_lib/assert.sh"
source "external/shell_scripts_lib/test_lib/assert.sh"
source "external/shell_scripts_lib/test_lib/test_logs.sh"

set_test_repository_paths() {
  export DOTFILES_REPO_LOCAL_PATH="${TEST_DATA_DOTFILES_REPO_PATH}"
  export DOTFILES_CLI_INSTALL_PATH="${TEST_DATA_DOTFILES_CLI_REPO_PATH}"
}

before_test() {
  test_set_up
  TEST_name=$1
  TEST_passed="True"
  set_test_repository_paths
  test_log_print_test_name "${TEST_name}"
}

after_test() {
  test_tear_down
}

test_dotfiles_version() {
  before_test "test_dotfiles_version"

  # Given I read the version from version.txt file
  local expected_version=$(cat ./resources/version.txt)

  # And I check the dotfiles CLI version
  ./dotfiles.sh version >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect the version to be equal
  assert_expect_log "${expected_version}"
  after_test
}

test_dotfiles_sync_all() {
  before_test "test_dotfiles_sync_all"

  # Given I prepare the expected HOME folder symlinks
  local home_link_gitigonre="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/home/.gitignore_global ${HOME}/.gitignore_global"
  local home_link_vimrc="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/home/.vimrc ${HOME}/.vimrc"
  local home_link_gitconfig="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/home/.gitconfig ${HOME}/.gitconfig"

  local home_link_dummy=""
  local shell_link_zshrc=""

  if shell_is_zsh; then
    home_link_dummy="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/home/.dummy.zsh ${HOME}/.dummy.zsh"
    shell_link_zshrc="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/shell/.zshrc ${HOME}/.zshrc"
  elif shell_is_bash; then
    home_link_dummy="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/home/.dummy.bash ${HOME}/.dummy.bash"
    shell_link_zshrc="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/shell/.bashrc ${HOME}/.bashrc"
  fi

  # And I sync all home and shell files
  ./dotfiles.sh sync all --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect all symlinks to exists
  assert_expect_log "${home_link_gitigonre}"
  assert_expect_log "${home_link_dummy}"
  assert_expect_log "${home_link_vimrc}"
  assert_expect_log "${home_link_gitconfig}"
  assert_expect_log "${shell_link_zshrc}"

  after_test
}

test_dotfiles_sync_home() {
  before_test "test_dotfiles_sync_home"

  # Given I prepare the expected HOME folder symlinks
  local home_link_gitigonre="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/home/.gitignore_global ${HOME}/.gitignore_global"
  local home_link_dummy="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/home/.dummy.zsh ${HOME}/.dummy.zsh"
  local home_link_vimrc="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/home/.vimrc ${HOME}/.vimrc"
  local home_link_gitconfig="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/home/.gitconfig ${HOME}/.gitconfig"

  # And I sync home files
  ./dotfiles.sh sync home --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect home symlinks to exists
  assert_expect_log "${home_link_gitigonre}"
  assert_expect_log "${home_link_dummy}"
  assert_expect_log "${home_link_vimrc}"
  assert_expect_log "${home_link_gitconfig}"

  after_test
}

test_dotfiles_sync_shell() {
  before_test "test_dotfiles_sync_shell"

  # Given I prepare the expected HOME folder symlinks
  local shell_link_zshrc="${TEST_DATA_DOTFILES_REPO_PATH}/dotfiles/shell/.zshrc ${HOME}/.zshrc"

  # And I sync shell files
  ./dotfiles.sh sync shell --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect shell symlinks to exists
  assert_expect_log "${shell_link_zshrc}"

  after_test
}

test_dotfiles_unsync_all() {
  before_test "test_dotfiles_unsync_all"

  # Given I prepare the expected files to unlink
  local home_unlink_gitigonre="unlink ${HOME}/.gitignore_global"
  local home_unlink_dummy="unlink ${HOME}/.dummy.zsh"
  local home_unlink_vimrc="unlink ${HOME}/.vimrc"
  local home_unlink_gitconfig="unlink ${HOME}/.gitconfig"
  local shell_unlink_zshrc="unlink ${HOME}/.zshrc"

  # And I unsync all home and shell files
  ./dotfiles.sh unsync all --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect all symlinks to get unlinked
  assert_expect_log "${home_unlink_gitigonre}"
  assert_expect_log "${home_unlink_dummy}"
  assert_expect_log "${home_unlink_vimrc}"
  assert_expect_log "${home_unlink_gitconfig}"
  assert_expect_log "${shell_unlink_zshrc}"

  after_test
}

test_dotfiles_unsync_home() {
  before_test "test_dotfiles_unsync_home"

  # Given I prepare the expected files to unlink
  local home_unlink_gitigonre="unlink ${HOME}/.gitignore_global"
  local home_unlink_dummy="unlink ${HOME}/.dummy.zsh"
  local home_unlink_vimrc="unlink ${HOME}/.vimrc"
  local home_unlink_gitconfig="unlink ${HOME}/.gitconfig"

  # And I unsync home files
  ./dotfiles.sh unsync home --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect home symlinks to get unlinked
  assert_expect_log "${home_unlink_gitigonre}"
  assert_expect_log "${home_unlink_dummy}"
  assert_expect_log "${home_unlink_vimrc}"
  assert_expect_log "${home_unlink_gitconfig}"

  after_test
}

test_dotfiles_unsync_shell() {
  before_test "test_dotfiles_unsync_shell"

  # Given I prepare the expected files to unlink
  local shell_unlink_zshrc="unlink ${HOME}/.zshrc"

  # And I unsync shell files
  ./dotfiles.sh unsync shell --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect shell symlinks to get unlinked
  assert_expect_log "${shell_unlink_zshrc}"

  after_test
}

test_brew_prerequisites() {
  before_test "test_brew_prerequisites"

  # Given I prepare the expected brew prerequisites
  local brew_tap_casks_versions="brew tap homebrew/cask-versions"
  local brew_tap_cask_fonts="brew tap homebrew/cask-fonts"
  local brew_tap_cask_drivers="brew tap homebrew/cask-drivers"
  local brew_install_tap_1="brew tap dummy-tap-1"
  local brew_install_tap_2="brew tap dummy-tap-2"
  local brew_outdated="brew outdated"
  local brew_update="brew update"
  local brew_upgrade="brew upgrade"

  # And I run a brew command
  ./dotfiles.sh brew packages --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect all prerequisites to run
  assert_expect_log "${brew_tap_casks_versions}"
  assert_expect_log "${brew_tap_cask_fonts}"
  assert_expect_log "${brew_tap_cask_drivers}"
  assert_expect_log "${brew_install_tap_1}"
  assert_expect_log "${brew_install_tap_2}"
  assert_expect_log "${brew_outdated}"
  assert_expect_log "${brew_update}"
  assert_expect_log "${brew_upgrade}"

  after_test
}

test_brew_pacakges() {
  before_test "test_brew_pacakges"

  # Given I prepare the expected brew packages to install
  local brew_install_pacakge_1="brew install dummy-package-1"
  local brew_install_pacakge_2="brew install dummy-package-2"

  # And I run a brew packages install command
  ./dotfiles.sh brew packages --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect all brew packages to get installed
  assert_expect_log "${brew_install_pacakge_1}"
  assert_expect_log "${brew_install_pacakge_2}"

  after_test
}

test_brew_casks() {
  before_test "test_brew_casks"

  # Given I prepare the expected brew casks to install
  local brew_install_cask_1="brew install --cask dummy-cask-1"
  local brew_install_cask_2="brew install --cask dummy-cask-2"

  # And I run a brew casks install command
  ./dotfiles.sh brew casks --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect all brew casks to get installed
  assert_expect_log "${brew_install_cask_1}"
  assert_expect_log "${brew_install_cask_2}"

  after_test
}

test_brew_drivers() {
  before_test "test_brew_drivers"

  # Given I prepare the expected brew drivers to install
  local brew_install_driver_1="brew install --cask dummy-driver-1"
  local brew_install_driver_2="brew install --cask dummy-driver-2"

  # And I run a brew drivers install command
  ./dotfiles.sh brew drivers --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect all brew drivers to get installed
  assert_expect_log "${brew_install_driver_1}"
  assert_expect_log "${brew_install_driver_2}"

  after_test
}

test_brew_services() {
  before_test "test_brew_services"

  # Given I prepare the expected brew services to install and start
  local brew_install_service_1="brew install dummy-service-1"
  local brew_start_service_1="brew services start dummy-service-1"

  local brew_install_service_2="brew install dummy-service-2"
  local brew_start_service_2="brew services start dummy-service-2"

  # And I run a brew services install command
  ./dotfiles.sh brew services --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect all brew services to get installed and started
  assert_expect_log "${brew_install_service_1}"
  assert_expect_log "${brew_start_service_1}"
  assert_expect_log "${brew_install_service_2}"
  assert_expect_log "${brew_start_service_2}"

  after_test
}

test_brew_all() {
  before_test "test_brew_all"

  # Given I prepare the expected brew packages to install
  local brew_install_pacakge_1="brew install dummy-package-1"
  local brew_install_pacakge_2="brew install dummy-package-2"

  # And I prepare the expected brew casks to install
  local brew_install_cask_1="brew install --cask dummy-cask-1"
  local brew_install_cask_2="brew install --cask dummy-cask-2"

  # And I prepare the expected brew drivers to install
  local brew_install_driver_1="brew install --cask dummy-driver-1"
  local brew_install_driver_2="brew install --cask dummy-driver-2"

  # And I prepare the expected brew services to install and start
  local brew_install_service_1="brew install dummy-service-1"
  local brew_start_service_1="brew services start dummy-service-1"
  local brew_install_service_2="brew install dummy-service-2"
  local brew_start_service_2="brew services start dummy-service-2"

  # And I run a brew services install command
  ./dotfiles.sh brew all --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect all brew packages to get installed
  assert_expect_log "${brew_install_pacakge_1}"
  assert_expect_log "${brew_install_pacakge_2}"

  # Then I expect all brew casks to get installed
  assert_expect_log "${brew_install_cask_1}"
  assert_expect_log "${brew_install_cask_2}"

  # Then I expect all brew drivers to get installed
  assert_expect_log "${brew_install_driver_1}"
  assert_expect_log "${brew_install_driver_2}"

  # Then I expect all brew services to get installed and started
  assert_expect_log "${brew_install_service_1}"
  assert_expect_log "${brew_start_service_1}"
  assert_expect_log "${brew_install_service_2}"
  assert_expect_log "${brew_start_service_2}"

  after_test
}

test_os_mac() {
  before_test "test_os_mac"

  # Given I prepare the expected mac OS scripts to install
  local os_install_script_1="eval '${TEST_DATA_DOTFILES_REPO_PATH}/os/mac/dummy_1.sh'"
  local os_install_script_2="eval '${TEST_DATA_DOTFILES_REPO_PATH}/os/mac/dummy_2.sh'"

  # And I run a mac os scripts install command
  ./dotfiles.sh os mac --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect mac os scripts to get evaluated
  assert_expect_log "${os_install_script_1}"
  assert_expect_log "${os_install_script_2}"

  after_test
}

test_os_linux() {
  before_test "test_os_linux"

  # Given I prepare the expected linux OS scripts to install
  local os_install_script_1="eval '${TEST_DATA_DOTFILES_REPO_PATH}/os/linux/dummy_1.sh'"
  local os_install_script_2="eval '${TEST_DATA_DOTFILES_REPO_PATH}/os/linux/dummy_2.sh'"

  # And I run a linux os scripts install command
  ./dotfiles.sh os linux --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect linux os scripts to get evaluated
  assert_expect_log "${os_install_script_1}"
  assert_expect_log "${os_install_script_2}"

  after_test
}

test_plugins_zsh() {
  before_test "test_plugins_zsh"

  # Given I prepare the expected zsh plugins scripts to install
  local plugins_zsh_script_1="eval '${TEST_DATA_DOTFILES_REPO_PATH}/plugins/zsh/dummy_1.sh'"
  local plugins_zsh_script_2="eval '${TEST_DATA_DOTFILES_REPO_PATH}/plugins/zsh/dummy_2.sh'"

  # And I run a zsh plugins install command
  ./dotfiles.sh plugins zsh --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect zsh plugins scripts to get evaluated
  assert_expect_log "${plugins_zsh_script_1}"
  assert_expect_log "${plugins_zsh_script_2}"

  after_test
}

test_plugins_bash() {
  before_test "test_plugins_bash"

  # Given I prepare the expected zsh plugins scripts to install
  local plugins_bash_script_1="eval '${TEST_DATA_DOTFILES_REPO_PATH}/plugins/bash/dummy_1.sh'"
  local plugins_bash_script_2="eval '${TEST_DATA_DOTFILES_REPO_PATH}/plugins/bash/dummy_2.sh'"

  # And I run a bash plugins install command
  ./dotfiles.sh plugins bash --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect bash plugins scripts to get evaluated
  assert_expect_log "${plugins_bash_script_1}"
  assert_expect_log "${plugins_bash_script_2}"

  after_test
}

test_plugins_bash() {
  before_test "test_plugins_bash"

  # Given I prepare the expected zsh plugins scripts to install
  local plugins_bash_script_1="eval '${TEST_DATA_DOTFILES_REPO_PATH}/plugins/bash/dummy_1.sh'"
  local plugins_bash_script_2="eval '${TEST_DATA_DOTFILES_REPO_PATH}/plugins/bash/dummy_2.sh'"

  # And I run a bash plugins install command
  ./dotfiles.sh plugins bash --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect bash plugins scripts to get evaluated
  assert_expect_log "${plugins_bash_script_1}"
  assert_expect_log "${plugins_bash_script_2}"

  after_test
}

test_reload_shell_session() {
  before_test "test_reload_shell_session"

  # Given I prepare the expected reload output
  local reload_output="(export DOTFILES_CLI_SILENT_OPTION=False && exec $SHELL)"

  # And I run a reload command 
  ./dotfiles.sh reload --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect the reload output to exist
  assert_expect_log "${reload_output}"

  after_test
}

test_change_dir_to_dotfiles_repo() {
  before_test "test_change_dir_to_dotfiles_repo"

  # Given I prepare the expected chagne dir output
  local change_dir_output="(export DOTFILES_CLI_SILENT_OPTION=True && $SHELL)"

  # And I run a repo command 
  ./dotfiles.sh repo --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect the repo change dir output to exist
  assert_expect_log "${change_dir_output}"

  after_test
}

test_link_dotfiles_repository_default_branch() {
  before_test "test_link_dotfiles_repository_default_branch"

  local repo_url="https://test.repo.com"
  local repo_branch="master"

  # Given I prepare the link dotfiles repo outputs
  local prev_dotfile_removal="rm -rf ${DOTFILES_REPO_LOCAL_PATH}"
  local git_clone_command_custom_branch="git -C ${HOME}/.config clone --branch ${repo_branch} --single-branch ${repo_url} --quiet"

  # And I run a link dotfiles repository command 
  ./dotfiles.sh link "${repo_url}" --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect the repo change dir output to exist
  assert_expect_log "${prev_dotfile_removal}"
  assert_expect_log "${git_clone_command_custom_branch}"

  after_test
}

test_link_dotfiles_repository_custom_branch() {
  before_test "test_link_dotfiles_repository_custom_branch"

  local repo_url="https://test.repo.com"
  local repo_branch="test-branch"

  # Given I prepare the link dotfiles repo outputs
  local prev_dotfile_removal="rm -rf ${DOTFILES_REPO_LOCAL_PATH}"
  local git_clone_command_custom_branch="git -C ${HOME}/.config clone --branch ${repo_branch} --single-branch ${repo_url} --quiet"

  # And I run a link dotfiles repository command 
  ./dotfiles.sh link "${repo_url}" "${repo_branch}" --dry-run -y -v >& "${TEST_log}" ||
    echo "Failed to run dotfiles command"

  # Then I expect the repo change dir output to exist
  assert_expect_log "${prev_dotfile_removal}"
  assert_expect_log "${git_clone_command_custom_branch}"

  after_test
}

main() {
  test_env_setup

  test_dotfiles_version
  test_dotfiles_sync_all
  test_dotfiles_sync_home
  test_dotfiles_sync_shell
  test_dotfiles_unsync_all
  test_dotfiles_unsync_home
  test_dotfiles_unsync_shell
  test_brew_prerequisites
  test_brew_pacakges
  test_brew_casks
  test_brew_drivers
  test_brew_services
  test_brew_all
  test_os_mac
  test_os_linux
  test_plugins_zsh
  test_plugins_bash
  test_reload_shell_session
  test_change_dir_to_dotfiles_repo
  test_link_dotfiles_repository_default_branch
  test_link_dotfiles_repository_custom_branch
}

main "$@"