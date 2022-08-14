---
layout: docs
title: Shell Support
description: Integrations of `dotfiles-cli` with supported shells.
group: content
toc: true
aliases: "/docs/latest/configuration/"
---

## RC File Header

The `dotfiles-cli` allows reloading an existing shell session easily without the need to open a new terminal tab or manually source any file. It allows reloading an active shell session by running the `dotfiles reload` command.

Since it is not possible to tamper with parent shell process environment from a nested shell, the `dotfiles-cli` adds a header to the RC file that enables the session reload to take place without creating a nested shell.

**Supported RC files:**

- `.zshrc`
- `.bashrc`
- `.bash_profile`

**Header example:**

```bash
############################################################################# 
#           THIS SECTION IS AUTO-GENERATED BY THE dotfiles CLI 
# 
#                         dotfiles RELOAD SESSION 
#                (https://github.com/ZachiNachshon/dotfiles-cli) 
# Limitation: 
# It is not possible to tamper with parent shell process from a nested shell. 
# 
# Solution: 
# The dotfiles reload command creates a new shell session which in turn 
# run the RC file (this file). 
# The following script will source a reload_session.sh script under 
# current shell session without creating a nested shell session. 
############################################################################# 
DOTFILES_CLI_INSTALL_PATH=${DOTFILES_CLI_INSTALL_PATH:-${HOME}/.config/dotfiles-cli} 
DOTFILES_CLI_RELOAD_SESSION_SCRIPT_PATH=${DOTFILES_CLI_INSTALL_PATH}/reload_session.sh 
 
if [[ -e ${DOTFILES_CLI_RELOAD_SESSION_SCRIPT_PATH} ]]; then 
  export LOGGER_SILENT=True 
  source ${DOTFILES_CLI_RELOAD_SESSION_SCRIPT_PATH} 
else 
  echo -e 'Dotfiles CLI is not installed, cannot load plugins/reload session. path: $DOTFILES_CLI_INSTALL_PATH' 
fi 
```

{{< callout info >}}
Do not change the header location on the RC file since other session related content (`exports` / `aliases`) might rely on the reloaded sources.
{{< /callout >}}