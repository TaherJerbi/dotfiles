# dotfiles

One config repo tracked across several machines — currently macOS and CachyOS.
Managed with [chezmoi](https://www.chezmoi.io/): this repo is the chezmoi
*source directory*, and it lives at `~/.local/share/chezmoi`.

Most of it is shared; anything that differs per machine is selected either by
the OS (`.chezmoi.os`) or by a **machine identity**, never by ad-hoc sniffing.

## Layout

Source paths map to targets under `$HOME` by chezmoi's naming conventions —
`dot_config/fish/config.fish` becomes `~/.config/fish/config.fish`.

| source                                    | target / role                          |
| ----------------------------------------- | -------------------------------------- |
| `dot_config/**`                           | everything under `~/.config`           |
| `.chezmoi.toml.tmpl`                      | prompts for the machine identity       |
| `.chezmoiignore`                          | targets chezmoi must never touch       |
| `.chezmoiscripts/run_onchange_before_10-packages.sh.tmpl` | installs dependencies  |
| `.chezmoiscripts/run_onchange_after_20-herdr-links.sh.tmpl` | herdr scripts onto PATH |

Prefixes that matter here: `executable_` preserves the +x bit, `private_`
preserves 0600/0700, `symlink_` creates a symlink whose content is its target,
and `.tmpl` marks a file rendered as a Go template.

## Setting up a machine

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply taherjerbi
```

That clones this repo, prompts for the identity, installs missing
dependencies, and writes every config into place. To script the prompt (note
the key is the *prompt text*, not the variable name):

```bash
chezmoi init --apply --promptString "Host identity (macos/cachyos/other)=macos" taherjerbi
```

Day to day:

```bash
chezmoi diff        # what would change
chezmoi apply       # write it
chezmoi add <file>  # start tracking an existing file
chezmoi cd          # shell in the source dir, to commit and push
```

## The machine identity

One word, answered once at `chezmoi init` and stored in
`~/.config/chezmoi/chezmoi.toml` as `data.host`. Valid values today: `macos`,
`cachyos`, `other`. `other` is the escape hatch: shared config only.

`fish/conf.d/00-host.fish.tmpl` bakes it straight into `$DOTS_HOST` at apply
time — there's no intermediate file to keep in sync. Prefer `.chezmoi.os` (`darwin`/`linux`) for anything the OS alone
can decide; reserve `.host` for what it can't — telling two Linux boxes apart.

## fish

`fish/conf.d/00-host.fish.tmpl` renders `data.host` into `$DOTS_HOST` and wires
up `fish/host/$DOTS_HOST/`, which is laid out like a fish config dir of its
own:

| path                        | what happens                       |
| --------------------------- | ---------------------------------- |
| `host/<name>/conf.d/*.fish` | sourced in order                   |
| `host/<name>/functions/`    | prepended to `$fish_function_path` |
| `host/<name>/completions/`  | prepended to `$fish_complete_path` |

Prepended, not appended, so a host can override something shared — macOS
overrides `fish_prompt` with pure's.

## Dependencies

`run_onchange_before_10-packages.sh.tmpl` installs the required tools (git,
make, unzip, cc, rg, fd, lazygit, zoxide, nvim ≥ 0.12, tree-sitter, fish,
alacritty) via brew or pacman. `run_onchange_` means it re-runs only when its
rendered content changes, not on every apply.

For a check-only report — including the optional tools that script doesn't
manage (herdr, fzf, jq, eza, bat, clipboard, Karabiner-Elements):

```bash
~/.config/setup/doctor.sh
```

## Adding a machine

1. Pick a one-word name, e.g. `parrotos`.
2. Add it to the prompt text in `.chezmoi.toml.tmpl`.
3. Add `dot_config/fish/host/parrotos/conf.d/00-parrotos.fish` (plus
   `functions/` and `completions/` beside it, if it needs them).
4. If its package manager isn't brew or pacman, extend the OS branch in
   `.chezmoiscripts/run_onchange_before_10-packages.sh.tmpl`.

fish needs no edit; it just loads `fish/host/<name>/` if it exists.

## Machine-local files (never tracked)

Listed in `.chezmoiignore`, so chezmoi will neither create nor remove them.

| file                          | what it is                            |
| ----------------------------- | ------------------------------------- |
| `fish/conf.d/local.fish`      | secrets and per-machine overrides     |
| `fish/fish_variables`         | fish's own universal-variable state   |
| `nvim/nvim-pack-lock.json`    | written by `vim.pack`                 |
| `karabiner/automatic_backups` | Karabiner-Elements' own backups       |
| `herdr/*.log`, `*.sock`       | herdr runtime state                   |

`alacritty/local.toml` and `rofimoji.rc` used to be on this list — they're now
a template and a `symlink_` entry respectively, so chezmoi generates both.
