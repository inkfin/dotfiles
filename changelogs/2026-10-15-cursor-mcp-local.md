# Keep Cursor MCP Configuration Machine-Local

Date: 2026-10-15

## What changed

Cursor MCP configuration is no longer deployed from chezmoi. Existing
`~/.config/cursor/mcp.json` and `~/.cursor/mcp.json` files remain on disk and
become machine-local; machines without a config should create an empty
`mcpServers` object before adding local servers.

## Impact

- Applies to machines that previously received the Cursor MCP config or
  symlink from chezmoi.
- Skipping the migration leaves the old managed file or symlink in place,
  though it will no longer be updated by chezmoi.

## Migration steps

1. If `~/.config/cursor/mcp.json` is absent and `~/.cursor/mcp.json` exists,
   copy the latter to the former, following a symlink if needed.
2. If neither path exists, create `~/.config/cursor/mcp.json` with
   `{"mcpServers":{}}`.
3. Keep both paths excluded by the root `.chezmoiignore`; do not add either
   file back to the source state.

## Completion condition

`chezmoi managed` lists neither `.config/cursor/mcp.json` nor
`.cursor/mcp.json`, and `~/.config/cursor/mcp.json` exists as a local file.
