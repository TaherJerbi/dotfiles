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

`~/.config/setup/doctor.sh` reports on the tools the configs need, plus the
few chezmoi doesn't install (a clipboard tool, Karabiner-Elements).

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

`.chezmoidata/packages.yaml` lists the required tools; `doctor.sh` reads the
same list. [mise](https://mise.jdx.dev) installs a tool unless the entry says
`system: true`, and knows it by `cmd` unless a `mise:` key overrides the name —
so most entries are the one line naming the command. Two scripts split along
the `system:` line:

- `.chezmoiscripts/run_onchange_before_10-packages.sh.tmpl` installs the six
  tools mise has no entry for — `git`, `make`, `cc`, `unzip`, `fish`,
  `alacritty` — and mise itself. A distro whose family isn't recognised
  installs nothing and reports what's missing.
- `.chezmoiscripts/run_onchange_after_20-mise.sh.tmpl` generates
  `/etc/mise/config.toml` and installs it with `sudo env
  MISE_DATA_DIR=/usr/local/share/mise mise install`. Not `mise install
  --system`: that flag changes where tools land but still asks "already
  installed?" of the invoking user's data dir, so it quietly no-ops whenever
  that user already has them.

Tools go in system-wide — `/usr/local/share/mise/installs`, with shims in
`/usr/local/share/mise/shims` — rather than under `~`, so root gets the same
ones. Otherwise uninstalling a distro package to stop it clashing with mise's
copy also takes it away from `sudo`. Every user's mise searches that directory
on its own, and `/etc/mise/config.toml` is the lowest-precedence config in the
chain, so a personal or per-project `mise.toml` still wins. Where `sudo`
enforces a `secure_path` the script adds the shims to it via
`/etc/sudoers.d/10-mise-shims`. All of which means `chezmoi apply` asks for a
password whenever the tool list changes.

`mise` versions are `latest` unless a tool sets `version:`, so upgrading is
`sudo mise upgrade` rather than a hand-edited URL. `minversion` survives as a floor
`doctor.sh` reports; nothing enforces it, because mise's `latest` clears every
floor this repo has.

## Machine-local files

Listed in `.chezmoiignore`, so chezmoi neither creates nor removes them:
`fish/conf.d/local.fish` (secrets and overrides), `fish/fish_variables`,
`nvim/nvim-pack-lock.json`, `karabiner/automatic_backups`, herdr's runtime
state and Alacritty's `*.bak` migration backups.

## Conventions

`executable_` keeps the +x bit, `private_` keeps 0600/0700, `symlink_` creates
a symlink whose content is its target, and `.tmpl` is rendered as a Go
template.
