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

Download and install `dotfiles-cli` executable (copy & paste into a terminal):

```bash
curl -sfLS https://raw.githubusercontent.com/ZachiNachshon/dotfiles-cli/master/install.sh | bash -
```

Available installation flags:
{{< bs-table >}}
| Flag | Description |
| --- | --- |
| `VERSION` | Specify the released version to install |
| `DRY_RUN` | Run all commands in dry-run mode without file system changes |
{{< /bs-table >}}

Example:

```bash
curl -sfLS \
  https://raw.githubusercontent.com/ZachiNachshon/dotfiles-cli/master/install.sh | \
  DRY_RUN=True \
  VERSION=0.5.0 \
  bash -
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
git clone https://github.com/ZachiNachshon/dotfiles-cli.git; cd dotfiles-cli; make install_from_respository
```

## Uninstall

Instruction to uninstall `dotfiles-cli` based on installation method.

**Homebrew**

```bash
brew remove dotfiles-cli
```

**Released Version**

```bash
curl -sfLS https://raw.githubusercontent.com/ZachiNachshon/dotfiles-cli/master/uninstall.sh | bash -
```

Available flags:
{{< bs-table >}}
| Flag | Description |
| --- | --- |
| `DRY_RUN` | Run all commands in dry-run mode without file system changes |
{{< /bs-table >}}

Example:

```bash
curl -sfLS \
  https://raw.githubusercontent.com/ZachiNachshon/dotfiles-cli/master/uninstall.sh | \
  DRY_RUN=True \
  bash -
```