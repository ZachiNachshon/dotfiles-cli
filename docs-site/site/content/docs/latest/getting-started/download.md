---
layout: docs
title: Download
description: Download `dotfiles-cli` executable.
group: getting-started
toc: true
---

## Package Managers

Pull in `dotfiles-cli`'s executable using popular package managers.

### Homebrew

The fastest way (for `macOS` and `Linux`) to install `dotfiles-cli` is using [Homebrew](https://brew.sh/):

```bash
brew install ZachiNachshon/tap/dotfiles-cli
```

Alternatively, tap into the formula to have brew search capabilities on that tap formulas:

1. Tap into `ZachiNachshon` formula

    ```bash
    brew tap ZachiNachshon/tap
    ```

1. Install the latest `dotfiles-cli` binary

    ```bash
    brew install dotfiles-cli
    ```

## Released Version

1. Download and install `dotfiles-cli` executable (copy & paste into a terminal):

```bash
bash <<'EOF'

# Change Version accordingly
VERSION=0.1.0

# Create a temporary folder
download_temp_path=$(mktemp -d ${TMPDIR:-/tmp}/dotfiles-cli-temp.XXXXXX)
cwd=$(pwd)
cd ${download_temp_path}

# Download & extract
echo -e "\nDownloading dotfiles-cli to a temp directory...\n"
curl -SL "https://github.com/ZachiNachshon/dotfiles-cli/releases/download/v${VERSION}/dotfiles-cli.tar.gz"

# Create a dest directory and move the binary
echo -e "\nUnpacking the artifact to ~/.local/bin"
mkdir -p ${HOME}/.local/bin
mv dotfiles-cli.tar.gz ${HOME}/.local/bin
tar -xvf ${HOME}/.local/bin/dotfiles-cli.tar.gz -C ${HOME}/.local/bin/dotfiles-cli

echo "Elevating exec permissions (might prompt for password)"
chmod +x ${HOME}/.local/bin/dotfiles-cli/install.sh

# Install the dotfiles CLI
./${HOME}/.local/bin/dotfiles-cli/install.sh

# Add this line to your *rc file (zshrc, bashrc etc..) to make dotfiles-cli available on new sessions
echo "Exporting ~/.local/bin (make sure to have it available on PATH)"
export PATH="${PATH}:${HOME}/.local/bin"

cd ${cwd}

# Cleanup
if [[ ! -z ${download_temp_path} && -d ${download_temp_path} && ${download_temp_path} == *"dotfiles-cli-temp"* ]]; then
  echo "Deleting temp directory"
  rm -rf ${download_temp_path}
fi

echo -e "\nDone (type 'dotfiles-cli' for help)\n"

EOF
```

Alternatively, you can download a release directy from GitHub

<a href="{{< param "download.dist" >}}" class="btn btn-bd-primary" onclick="ga('send', 'event', 'Getting started', 'Download', 'Download Git Deps Syncer');" target="_blank">Download Specific Release</a>

{{< callout warning >}}
## `PATH` awareness

Make sure `${HOME}/.local/bin` exists on the `PATH` or sourced on every new shell session.
{{< /callout >}}

## Pre-Built Release

Clone `dotfiles-cli` repository into a directory of your choice and install:

```bash
git clone https://github.com/ZachiNachshon/dotfiles-cli.git; cd dotfiles-cli; ./install.sh

```
