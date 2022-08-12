---
layout: docs
title: Locations
description: Locations used by `dotfiles-cli` for dotfiles clone path and configurations.
group: content
toc: true
aliases: "/docs/latest/configuration/"
---

## Locations

`dotfiles-cli` is using different paths on local disk for storing content. 

{{< bs-table >}}
| Name | Path |
| --- | --- |
| Dotfiles Clone Path | `$HOME/.config/dotfiles` |
| CLI Global Binary | `$HOME/.config/dotfiles-cli` |
{{< /bs-table >}}

### Overrides

Available env vars are available to override 

{{< bs-table >}}
| Task | Description |
| --- | --- |
| `DOTFILES_REPO_LOCAL_PATH` | Override the dotfiles repository local path |
| `DOTFILES_CLI_INSTALL_PATH` | Override the `dotfiles-cli` repository local path |
{{< /bs-table >}}

{{< callout info >}}
To get a list of commonly used paths run `dotfiles config`
{{< /callout >}}
