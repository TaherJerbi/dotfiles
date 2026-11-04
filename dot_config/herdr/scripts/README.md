# herdr scripts

Small helpers layered on top of [herdr](https://herdr.dev) for sesh-style
workspace switching.

## Scripts

- **herdr-workspace-switcher** — popup fuzzy-picker (fzf) combining open
  herdr workspaces and zoxide-known directories. Picking an open workspace
  focuses it; picking a directory creates a new workspace there. `ctrl-f`
  switches to searching every directory under `$HERDR_SWITCHER_ROOTS`
  (default `$HOME`) with `fd`; `ctrl-r` switches back; `ctrl-d`, then `enter`
  to confirm, closes the highlighted open workspace. The popup's bottom
  border lists the keys.
- **herdr-workspace-preview** — preview pane for the switcher above: shows
  the live content of an open workspace's focused pane, or a directory
  listing (+ README) for a not-yet-open directory.

## Dependencies

`fzf`, `jq`, `zoxide`, `fd`, `eza`, `bat`.

## Setup (fresh install)

Handled by chezmoi: `.chezmoiscripts/run_onchange_after_20-herdr-links.sh.tmpl`
symlinks these scripts into `~/.local/bin` on `chezmoi apply`, and re-runs only
when one of them changes.
