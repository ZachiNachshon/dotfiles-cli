---
layout: docs
title: Contribute
description: Contribute to the development of `dotfiles-cli` using the documentation, build scripts and tests.
group: getting-started
toc: true
aliases: "/docs/latest/getting-started/contribute/"
---

## Tooling setup

- [bash](https://www.gnu.org/software/bash/) is required for running/debugging the executable
- [Node.js](https://nodejs.org/en/download/) is optional for managing the documentation site

{{< callout info >}}
Docs site is using npm scripts to build the documentation and compile source files. The `package.json` houses these scripts which used for various docs development actions.
{{< /callout >}}

## Guidelines

- PRs need to have a clear description of the problem they are solving
- PRs should be small
- Code without tests is not accepted, PRs must not reduce tests coverage
- Contributions must not add additional dependencies
- Before creating a PR, make sure your code is well formatted, abstractions are named properly and design is simple
- In case your contribution can't comply with any of the above please start a GitHub issue for discussion

## How to Contribute?

1. Fork this repository
1. Create a PR on the forked repository
1. Send a pull request to the upstream repository

## Development Scripts

The `makefile` within this repository contains numerous tasks used for project development. Run `make` to see all the available scripts in your terminal.

{{< bs-table >}}
| Task | Description |
| --- | --- |
| `install_from_respository` | Install a local dotfiles CLI from this repository |
| `uninstall` | Uninstall a local dotfiles CLI |
| `release_version_create` | Create release tag in GitHub with version from resources/version.txt |
| `release_version_delete` | Enter a tag to delete its attached release tag from GitHub |
| `calculate_sha_by_commit_hash` | Enter a commit to get its SHA hash |
| `calculate_sha_by_tag` | Enter a tag to get its SHA hash |
| `serve_docs_site` | Run a local site |
| `serve_docs_site_lan` | Run a local site (open for LAN) |
{{< /bs-table >}}

{{< callout warning >}}
Note that some of those development actions require write access to the repository.
{{< /callout >}}

## Testing Locally

Running tests locally allows you to have short validation cycles instead of waiting for the PR status to complete.

**How to run a test suite?**

1. Clone the `dotfiles-cli` repository
2. Run `make tests` to run the tests suite

## Documentation Scripts

The `/docs-site/package.json` includes numerous tasks for developing the documentation site. Run `npm run` to see all the available npm scripts in your terminal. Primary tasks include:

{{< bs-table >}}
| Task | Description |
| --- | --- |
| `npm run docs-build` | Cleans the Hugo destination directory for a fresh serve |
| `npm run docs-serve` | Builds and runs the documentation locally |
| `npm run docs-serve-lan` | Builds and runs the documentation locally, make it available on home network<br> (for testing views on mobile phones) |
{{< /bs-table >}}

## Local documentation 

Running our documentation locally requires the use of Hugo, which gets installed via the `hugo-bin` npm package. Hugo is a blazingly fast and quite extensible static site generator. Here’s how to get it started:

- Run through the [tooling setup](#tooling-setup) above to install all dependencies
- Navigate to `/docs-site` directory and run `npm install` to install local dependencies listed in `package.json`
- From `/docs-site` directory, run `npm run docs-serve` in the command line
- Open [http://localhost:9001/dotfiles-cli](http://localhost:9001/dotfiles-cli) in your browser

Learn more about using Hugo by reading its [documentation](https://gohugo.io/documentation/).
