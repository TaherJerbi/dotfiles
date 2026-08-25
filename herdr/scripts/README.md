# herdr scripts

Small helpers layered on top of [herdr](https://herdr.dev) for sesh-style
workspace switching.

## Scripts

- **herdr-workspace-switcher** — popup fuzzy-picker (fzf) combining open
  herdr workspaces and zoxide-known directories. Picking an open workspace
  focuses it; picking a directory creates a new workspace there.
- **herdr-workspace-preview** — preview pane for the switcher above: shows
  the live content of an open workspace's focused pane, or a directory
  listing (+ README) for a not-yet-open directory.

## Dependencies

`fzf`, `jq`, `zoxide`, `eza`, `bat`.

## Setup (fresh install)

```sh
./setup.sh
```

Symlinks the scripts into `~/.local/bin`.

Then add this to `~/.config/herdr/config.toml` (adjust the prefix key to
taste) and run `herdr server reload-config`:

```toml
[keys]
last_pane = "prefix+l"

[ui]
prompt_new_tab_name = false

[[keys.command]]
key = "prefix+f"
type = "popup"
command = "herdr-workspace-switcher"
description = "workspace / directory switcher"
width = "70%"
height = "70%"
```
