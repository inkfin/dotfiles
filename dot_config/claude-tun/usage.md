# Claude TUN container

Linux only. Requires Python 3.9+, iproute2, nftables, util-linux, bubblewrap, user
namespaces, and access to `/dev/net/tun`. Use a Mihomo build with the gVisor TUN
stack. The launcher expects the official native Claude binary and accepts its
path through `--claude`. It runs as a regular user, without Docker or sudo.

## Verify first

```sh
~/.local/scripts/claude-tun self-check
```

Use `--mihomo /absolute/path/to/mihomo` if the binary is outside PATH. The
self-check runs a local SOCKS5 stub, checks TCP and DNS through the TUN, and
stops Mihomo while the client namespace stays alive. It requires no external
network connection or account.

## Configure and run

Copy the example without replacing any existing configuration.

```sh
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/claude-tun"
if [ ! -e "$config_dir/upstream.json" ]; then
  install -m 600 "$config_dir/upstream.example.json" "$config_dir/upstream.json"
fi
```

Edit `upstream.json` and set the authorized SOCKS5 server's literal IP, port,
and optional username and password. `dns_address` is the IPv4 address of a
recursive resolver reachable **from the SOCKS5 server** over TCP/53. The
launcher sends DNS through SOCKS5. Protect the local config as mode 600. Plain
SOCKS5 does not encrypt its authentication handshake. Use a trusted transport
for credentials. The real config is machine-local and ignored by chezmoi.

```sh
~/.local/scripts/claude-tun start /absolute/path/to/project
~/.local/scripts/claude-tun start /absolute/path/to/project --help
```

The session runs in the foreground. In another terminal with the same
`XDG_STATE_HOME`, stop it with:

```sh
~/.local/scripts/claude-tun stop
```

The container receives the project and a dedicated persistent home under
`${XDG_STATE_HOME:-$HOME/.local/state}/claude-tun/home`. Use a dedicated
project copy when a repository contains credentials or sockets. The
launcher supplies system tools and certificate stores read-only, with no
host home, SSH agent, Docker socket, or proxy variables. The outside
browser used for OAuth has its own network path.

## Network behavior

The Claude container has only a private veth to the gateway. The gateway has
no external network interface. Its sole external path is a Unix socket
connected to a host process that dials the configured SOCKS5 endpoint only.
The socket is outside the workload's mounts. Gateway firewall policy
allows IPv4 forwarding between the private interface and the TUN, and
drops other forwarding. IPv6 is disabled for the workload, and UDP other
than intercepted DNS is unsupported by this SOCKS5 relay. If the TUN, relay,
or upstream is unavailable, requests fail. The launcher makes no changes to
host interfaces, routes, DNS, or firewall.

The outer container disables nested user namespaces, so Claude's optional
Linux Bash sandbox cannot start inside it. Keep Claude's permission prompts
enabled. The test stub validates the network path. A real Claude session and
the configured SOCKS5 server need their own smoke test.

## Locale, timezone, fonts and project tools

Defaults are `C.UTF-8`, `UTC` and system fonts. Copy
`environment.example.json` to the local `environment.json` to change the
defaults. For project-specific settings, keep a separate trusted host
file outside the writable project and pass it before the workspace:

```sh
~/.local/scripts/claude-tun start --environment /absolute/path/to/environment.json /absolute/path/to/project
```

- `locale` selects an installed locale such as `en_US.UTF-8` or
  `zh_CN.UTF-8`. Use `locale -a` on the host to list what's installed.
- `timezone` selects an installed IANA zone such as `Asia/Shanghai`.
  The container gets both `TZ` and its own read-only `/etc/localtime`.
- `font_dirs` adds read-only host font directories to Fontconfig.
  They appear under `/opt/fonts`. Fonts displayed by the outer terminal
  are still controlled by that terminal.
- `toolchains` maps each name to a dedicated host directory. For example,
  `{"llvm": "/opt/llvm-20"}` mounts it at `/opt/toolchains/llvm` and adds
  `/opt/toolchains/llvm/bin` before system tools in the container PATH.
  Use relocatable toolchains or configure their container paths explicitly.
  Build outputs belong in the writable project or sandbox home.

Use dedicated asset directories you control. Read-only mounts still
expose file contents and can expose Unix sockets, so keep credentials
and sockets out of the directories. Asset directories must not overlap
the writable project or private launcher files. Locale and mount options
do not alter the network namespace or firewall rules.

## Read-only training queries with mock data

Enable the training MCP server for one session:

```sh
~/.local/scripts/claude-tun start \
  --training-fixture ~/.config/claude-tun/training-fixture.example.json \
  /absolute/path/to/project
```

Ask Claude to call `get_job_status` or `get_recent_logs` for job
`mock-123`. The log tool defaults to 20 lines and accepts 1–100.
The broker returns the tail in chronological order. Unknown operations,
unexpected arguments and invalid job IDs are rejected by the host broker.

The launcher passes a stdio MCP adapter to Claude and mounts only the
broker's private Unix socket. The broker loads the fixture on the host.
It has no command execution, job mutation or live training backend.
Use synthetic data in the fixture and keep it outside the writable
project. A future real backend can keep credentials on the host, with
job visibility and log filtering enforced there.

The socket is a deliberate local exception to the TUN boundary. It can
answer while Mihomo is down, and closes with the launcher session.

## Read-only training queries with GameAIR

Copy `training-gameair.example.json` to the local
`training-gameair.json` and set the project, workspace, and exact allowed
job IDs. Use a trusted host Avatar checkout with its existing
`.venv`. Keep that checkout outside the writable project mounted into
Claude. For changes to the same repository, use a separate working copy.

```sh
~/.local/scripts/claude-tun start \
  --training-gameair ~/.config/claude-tun/training-gameair.json \
  /absolute/path/to/project-copy
```

The broker uses Avatar's existing host authentication
(`~/.gameair/config.json` or `GAMEAIR_TOKEN` and the GameAIR user
environment variables). The mounted socket accepts only the two MCP
queries. The GameAIR client permits only the GET endpoints for job
metadata, pods, and log content. The broker checks the exact job ID,
project, and workspace before returning data.

Logs come from pod index 0 for the configured role and stream. The
response is a live tail bounded by the requested line count and 8 KiB of
text. The host bearer value is removed if it appears in log text. Only
allow jobs whose logs may be shared with the Claude session. The broker
does not persist log text. A terminated job may still report status even
after its live pod logs are unavailable.
