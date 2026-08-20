# Herdr setup

Reach this file when Herdr is missing, unhealthy, integrations are stale, or config must change.
Linux and macOS only — on Windows, point at https://herdr.dev.

## Steps

Done when `herdr config check` succeeds and needed integrations report `current`.

1. **Present?** `command -v herdr` — missing → `curl -fsSL https://herdr.dev/install.sh | sh`;
   outdated → `herdr update`.
2. **Healthy?** `herdr status` — client and server protocol-compatible.
3. **Integrations.** Hooks give real lifecycle state. Install only for CLIs that exist:
   `command -v <cli>` then `herdr integration install <target>`. Diff against
   `herdr integration status`; reinstall anything not `current`. New CLIs later → user asks.
4. **Config** (chezmoi-managed — edit source, not the live file):

```bash
chezmoi edit ~/.config/herdr/config.toml   # or dot_config/herdr/config.toml.tmpl
chezmoi diff
chezmoi apply
herdr server reload-config
herdr config check
```

Worktrees collect under `~/.agents/worktrees` via `[worktrees].directory` — Herdr owns paths;
do not pass worktree directories by hand.

## Gotchas

- **Panes open bash instead of zsh.** The herdr *server* inherits the passwd
  `$SHELL` (often `/bin/bash`), not your interactive shell — so fresh/restored/remote-attached
  panes start bash unless `[terminal].default_shell` is pinned. Root fix: set
  `default_shell = "zsh"` in `dot_config/herdr/config.toml.tmpl` (empty means `$SHELL`, then
  `/bin/sh`). New panes pick it up after `reload-config`; an existing pane keeps its shell
  until recreated, so a session restore (server restart) re-shells the whole layout.
- Editing `~/.zshrc` or making your shell a login shell does **not** change the server's
  env — the server uses whatever env launched it.
