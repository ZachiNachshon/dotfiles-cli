---
layout: docs
title: Overview
description: Learn about <code>dotfiles-cli</code>, why it was created and the pain it comes to solve.
group: getting-started
toc: true
---

## Why creating `dotfiles-cli`?

Those are some of the requirements that lead me to implement a custom solution instead of using git submodule / subtree:

1. Merge any git repository into a working directory source code, treat it as external source dependency
1. Keep the external source dependencies immutable for changes
1. Having the external git repositories version controlled
1. Use external git repositories as they were standard libraries imports
1. Having the ability to hot-swap git external dependencies easily with local paths for development

## In a nutshell

`dotfiles-cli` is a lightweight CLI utility used for syncing git repositories as external 3rd party source dependencies into any working directory.

It offers a simple alternative to git submodule / subtree by allowing a drop-in-replacement of any git repository as an immutable source dependency that is part of the actual working repository source code, files are located and managed within a dedicated `external` folder.

Using the git dependencies is through symlinks located on the `external` folder thus making them easily available for hot-swap if nessesary for development purposes.
