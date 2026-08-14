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
