---
layout: docs
title: Getting started</code>
description: Simplify the complex dotfiles repository wiring by separating the files from the management layer, use a dedicatd CLI utility to control all aspects of the dotfiles repository with ease.
toc: true
aliases:
- "/docs/latest/getting-started/"
- "/docs/getting-started/"
- "/getting-started/"
---

## Requirements

- A Unix-like operating system: macOS, Linux
- `git` (recommended `v2.30.0` or higher)

## QuickStart

The fastest way (for `macOS` and `Linux`) to install `dotfiles-cli` is using [Homebrew](https://brew.sh/):

```bash
brew install ZachiNachshon/tap/dotfiles-cli
```

### First Timers

Recommended commands order for initial setup:

1. Clone and link a remote dotfiles repository:

   ```bash
   dotfiles link https://github.com/ZachiNachshon/dotfiles-example.git
   ```

1. Install Homebrew components (might take time):

   ```bash
   dotfiles brew all
   ```

1. Update OS settings and preferences:

   ```bash
   dotfiles os <mac/linux>
   ```

1. Install shell plugins:

   ```bash
   dotfiles plugins <bash/zsh>
   ```

1. Create home/shell symlinks to `$HOME` folder:

   ```bash
   dotfiles sync all
   ```
