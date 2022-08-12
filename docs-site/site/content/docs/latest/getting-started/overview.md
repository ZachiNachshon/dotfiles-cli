---
layout: docs
title: Overview
description: Learn about <code>dotfiles-cli</code>, why it was created and the pain it comes to solve.
group: getting-started
toc: true
---

## Why creating `dotfiles-cli`?

Those are some of the kep points that lead me to create this project:

1. Simplify the complex dotfiles repository wiring by separating the files from the management layer
1. Use a dedicatd CLI utility to control all aspects of the dotfiles repository with ease
1. Having a coherent dotfiles structure that is easy to get familiar with
1. Allow a generic CLI to control multiple dotfiles repositories (private and public)
1. Avoid from running arbitrary scripts

## In a nutshell

`dotfiles-cli` is a lightweight CLI utility used for automating your local development environment management i.e. installations / updates with just a few terminal commands.

It helps you to manage your local environment settings and preferences under a remote git backed repository so you’ll keep them in a centralized location, detached from any machine and enjoy all the benefits a version control has to offer.