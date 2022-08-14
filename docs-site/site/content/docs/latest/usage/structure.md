---
layout: docs
title: Structure
description: Learn how to structure a dotfiles repository to be supported by <code>dotfiles-cli</code>
group: repository
toc: true
aliases: "/docs/latest/repository/"
---

## Overview

This is the expected dotfiles repository structure to properly integrate with `dotfiles-cli`:

```text
.
├── ...
├── brew                        # Homebrew components, items on each file should be separated by a new line
│   ├── casks.txt
│   ├── drivers.txt
│   ├── packages.txt
│   ├── services.txt
│   └── taps.txt
│
├── dotfiles               
│   ├── custom                  # Custom files to source on every new shell session (work/personal)
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
│       └── .secrets
│
├── os
│   ├── linux                   # Scripts to configure Linux settings and preferences
│   │   ├── key_bindings.sh
│   │   └── ...
│   └── mac                     # Scripts to configure macOS settings and preferences
│       ├── finder_settings.sh  
│       └── ...
│
├── plugins
│   ├── zsh                     # Scripts to install ZSH plugins
│   │   ├── oh_my_zsh.sh  
│   │   └── ...
│   └── bash                    # Scripts to install Bash plugins
│       ├── dummy.sh
│       └── ...
└── ...
```

{{< callout info >}}
Get a reminder on the expected dotfiles repository structure from the CLI by running:<br> `dotfiles structure`.
{{< /callout >}}

## `brew`

Declare which Homebrew components to install by type, the `brew` folder holds the Homebrew components declarations, items on each file should be separated by a new line.

**Usage:**

```bash
dotfiles brew <packages/casks/drivers/services/all>
```

## `dotfiles`

Sync or unsync symlinks from the dotfiles repository and control what to source on an active shell session.

<br>

#####  Symlinks to `$HOME`

The `dotfiles` folder contains files to symlink from the repository to the `$HOME` folder, an unsync command is available to remove them when necessary.

**Usage:**

```bash
dotfiles sync <home/shell/all>
```

<br>

##### Reload shell session

The `dotfiles` folder contains files to source on every new shell session and in case of changes a reload command is available as well.

**Usage:**

```bash
dotfiles reload
```

<br>

##### Transient files

If files in `transient` directory exists, they will be sourced along but won't get symlinked anywhere.
You can use this to export ENV vars with sensitive information such as secrets to become available on any newly opened shells. Files under transient folder are git ignored by default to prevent from committing to a public repository.

## `os`

Update OS settings and preferences, the `os` folder contains scripts that configure the presonal settings and preferences for mac / linux operating systems.

**Usage:**

```bash
dotfiles os <linux/mac>
```

## `plugins`

Install plugins by shell type, the `plugins` folder contains scripts to run on a specific shell type.

**Usage:**

```bash
dotfiles plugins <bash/zsh>
```
