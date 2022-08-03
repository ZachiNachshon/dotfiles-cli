---
layout: docs
title: Commands
description: Available `dotfiles-cli` commands and flags
toc: true
group: repository
---

## Available Commands

Some commands prompts for user approval before execution, to auto-approve use the `-y` flag.

{{< bs-table >}}
| Task | Description |
| --- | --- |
| `sync` | Sync dotfiles symlinks by catagory [options: home/shell/all] |
| `unsync` | Unsync dotfiles symlinks by catagory [options: home/shell/all] |
| `brew` | Update local brew components [options: packages/casks/drivers/services/all] |
| `os` | Update OS settings and preferences [options: mac/linux] |
| `plugins` | Install plugins for specific shell [options: bash/zsh] |
| `reload` | Reload active shell session by order: transient-session-custom |
| `config` | Print config/paths/symlinks/clone-path |
| `structure` | Print the dotfiles repository expected structure |
| `repo` | Change directory to the dotfiles local git repository |
| `version` | Print dotfiles client commit-hash |
{{< /bs-table >}}

## Flags

Available flags to control commands execution.

{{< bs-table >}}
| Task | Description |
| --- | --- |
| `--dry-run` | Run all commands in dry-run mode without file system changes |
| `-y` | Do not prompt for approval and accept everything |
| `-h (--help)` | Show available actions and their description |
| `-v (--verbose)` | Output debug logs for commands executions |
| `-s (--silent)` | Do not output logs for commands executions |
{{< /bs-table >}}

<br>

Example of a user prompt message upon `sync-all`:

<div class="col-lg-6">
   <img style="vertical-align: top;" src="/docs/latest/assets/img/sync-home-prompt-message.svg" width="800" >
</div>