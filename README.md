<h3 align="center" id="git-deps-syncer-logo"><img src="docs-site/site/static/docs/latest/assets/brand/dotfiles-cli.svg" height="300"></h3>

<p align="center">
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </a>
  <a href="https://www.paypal.me/ZachiNachshon">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
</p>

<p align="center">
  <a href="#requirements">Requirements</a> •
  <a href="#quickstart">QuickStart</a> •
  <a href="#overview">Overview</a> •
  <a href="#support">Support</a> •
  <a href="#license">License</a>
</p>
<br>

**dotfiles-cli** is a lightweight CLI utility used for automating your local development environment management i.e. installations / updates with just a few terminal commands.

It simplifies the complex dotfiles repository wiring by separating the files from the management layer using a dedicatd CLI utility to control all aspects of the dotfiles repository with ease.

<br>

<h2 id="requirements">🏁 Requirements</h2>

- A Unix-like operating system: macOS, Linux
- `git` (recommended `v2.30.0` or higher)

<br>

<h2 id="quickstart">⚡️ Quick Start</h2>

The fastest way (for `macOS` and `Linux`) to install `dotfiles-cli` is using [Homebrew](https://brew.sh/):

```bash
brew install ZachiNachshon/tap/dotfiles-cli
```

Alternatively, tap into the formula to have brew search capabilities on that tap formulas:

```bash
# Tap
brew tap ZachiNachshon/tap

# Install
brew install dotfiles-cli
```

For additional installation methods [read here](https://zachinachshon.com/dotfiles-cli/docs/latest/getting-started/download/).

<br>

<h2 id="overview">🔍 Overview</h2>

- [Why creating `dotfiles-cli`?](#why-creating)
- [How does it work?](#how-does-it-work)
  - [Initial setup](#initial-setup)
- [Documentation](#documentation)

**Maintainers / Contributors:**

- [Contribute guides](https://zachinachshon.com/dotfiles-cli/docs/latest/getting-started/contribute/)

<br>

<h3 id="why-creating">💡 Why Creating <code>dotfiles-cli</code>?</h3>

Those are some of the key points that lead me to create this project:

1. Simplify the complex dotfiles repository wiring by separating the files from the management layer
1. Use a dedicatd CLI utility to control all aspects of the dotfiles repository with ease
1. Having a coherent dotfiles structure that is easy to get familiar with
1. Allow a generic CLI to control multiple dotfiles repositories (private and public)
1. Avoid from running arbitrary scripts

<br>

<h3 id="how-does-it-work">🔬 How Does It Work?</h3>

`dotfiles-cli` is a CLI utility that can be used globally on any directory, it relies on a simple and opinionated dotfiles repository structure which allows it to control and manage domains by category i.e. Homebrew installs, `$HOME` symlinks, OS settings, shell plugins etc..



<br>

<h4 id="initial-setup">Initial Setup</h4>

Recommended commands order for initial setup:

1. Clone and link a remote dotfiles repository:

   ```bash
   dotfiles link https://github.com/ZachiNachshon/dotfiles-example.git
   ```

1. Create home/shell symlinks to `$HOME` folder:

   ```bash
   dotfiles sync all
   ```

1. Install shell plugins:

   ```bash
   dotfiles plugins <bash/zsh>
   ```

1. Update OS settings and preferences:

   ```bash
   dotfiles os <mac/linux>
   ```

1. Install Homebrew components (might take time):

   ```bash
   dotfiles brew all
   ```

   | :bulb: Note |
   | :--------------------------------------- |
   | Run `dotfiles -h` for additional options. |
   

<br>

<h3 id="documentation">📖 Documentation</h3>

Please refer to the [documentation](https://zachinachshon.com/dotfiles-cli/docs/latest/getting-started/introduction/) for detailed explanation on how to configure and use `dotfiles-cli`.

<br>

<h2 id="support">Support</h2>

`dotfiles-cli` is an open source project that is currently self maintained in addition to my day job, you are welcome to show your appreciation by sending me cups of coffee using the the following link as it is a known fact that it is the fuel that drives software engineering ☕

<a href="https://github.com/sponsors/ZachiNachshon" target="_blank"><img src="docs-site/site/static/docs/latest/assets/img/bmc-orig.svg" height="57" width="200" alt="Buy Me A Coffee"></a>

<br>

<h2 id="license">License</h2>

MIT

<br>
