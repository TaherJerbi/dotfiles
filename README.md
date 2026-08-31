# dotfiles

My config for macOS, CachyOS and ParrotOS, managed with
[chezmoi](https://www.chezmoi.io/). This repo is the chezmoi *source
directory*; it lives at `~/.local/share/chezmoi` and its contents map to
`$HOME` — `dot_config/fish/config.fish` becomes `~/.config/fish/config.fish`.

## Setting up a machine

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply taherjerbi
```

Clones this repo, prompts for the host identity, installs missing dependencies
and writes every config into place. To skip the prompt (the key is the prompt
text, not the variable name):

```bash
chezmoi init --apply --promptString "Host identity (macos/cachyos/parrotos/other)=macos" taherjerbi
```

Day to day:

```bash
chezmoi diff        # what would change
chezmoi apply       # write it
chezmoi add <file>  # start tracking an existing file
chezmoi cd          # shell in the source dir, to commit and push
```

On a machine set up before `.osid`/`.pkgfamily` existed, run `chezmoi init`
once to re-render the config — templates error until it has them, and the
identity prompt keeps the answer already stored.

`~/.config/setup/doctor.sh` reports on the tools the configs need, including
the optional ones chezmoi doesn't install (herdr, fzf, jq, eza, bat, clipboard,
Karabiner-Elements).

## Per-machine config

Anything that differs per machine is selected by one of three values, never by
ad-hoc sniffing. All three are set at `chezmoi init` and stored in
`~/.config/chezmoi/chezmoi.toml`.

| value        | set from                | used for                                     |
| ------------ | ----------------------- | -------------------------------------------- |
| `.host`      | the init prompt         | telling machines apart when nothing else can |
| `.osid`      | `/etc/os-release`       | OS and distro, e.g. `linux-parrot`           |
| `.pkgfamily` | `/etc/os-release`       | which package manager to drive               |

Reach for `.osid` or `.pkgfamily` when the OS or distro decides it; `.host` is
the escape hatch for everything else. It's one word — `macos`, `cachyos`,
`parrotos`, or `other` for a machine that should get shared config only — and
it drives:

- **fish.** `fish/conf.d/00-host.fish.tmpl` renders it into `$DOTS_HOST` and
  wires up `fish/host/$DOTS_HOST/`, laid out like a fish config dir of its own:
  `conf.d/*.fish` is sourced, `functions/` and `completions/` are *prepended* to
  their paths so a host can override something shared (macOS overrides
  `fish_prompt` with pure's).
- **anything else**, via `{{ if eq .host "macos" }}` in a template.

Adding a machine: pick a name, add it to the prompt text in
`.chezmoi.toml.tmpl`, and create `dot_config/fish/host/<name>/` if it needs
one. Nothing else — fish just loads that directory if it exists, and packages
follow `.pkgfamily`.

## Packages

`.chezmoidata/packages.yaml` lists the required tools and how to install them
per `.pkgfamily`; `.chezmoiscripts/run_onchange_before_10-packages.sh.tmpl`
resolves it for the machine at hand, and `doctor.sh` reads the same list.

Anything a distro doesn't package — nvim, tree-sitter and lazygit on Debian —
is pinned to a GitHub release in that file and installed into `~/.local`, no
sudo: bare binaries in `~/.local/bin`, archives that need their tree in
`~/.local/opt/<tool>`. Bump `release.version` by hand to upgrade. A tool with a
`minversion` gets reinstalled when what's on `PATH` is older (Debian's neovim
is far below the 0.12 this nvim config needs). A distro whose family isn't
recognised installs nothing and reports what's missing.

## Machine-local files

Listed in `.chezmoiignore`, so chezmoi neither creates nor removes them:
`fish/conf.d/local.fish` (secrets and overrides), `fish/fish_variables`,
`nvim/nvim-pack-lock.json`, `karabiner/automatic_backups`, herdr's runtime
state and Alacritty's `*.bak` migration backups.

## Conventions

`executable_` keeps the +x bit, `private_` keeps 0600/0700, `symlink_` creates
a symlink whose content is its target, and `.tmpl` is rendered as a Go
template.
