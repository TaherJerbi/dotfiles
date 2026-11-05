---
name: chezmoi-update
description: "Check the user's chezmoi dotfiles for upstream changes, preview exactly what applying them would do on this machine, and offer to pull and apply them. Use when the user asks to update, sync or pull their dotfiles or chezmoi, or asks whether there are dotfile updates."
---

# Check for chezmoi updates

Preview first: fetch and compare, and change nothing until the user says to
run the update (step 6). Never commit or push.

## 1. Find the repo and host

- Source dir: `chezmoi source-path`.
- Host: `chezmoi data --format json | jq -r .host`.
- Branch and upstream: `git -C <src> rev-parse --abbrev-ref HEAD @{u}`.

## 2. Check local state first

Each of these changes the commands the user needs, so note what you find:

- **Uncommitted source edits:** `git -C <src> status --short`.
- **Unpushed commits:** `git -C <src> log --oneline @{u}..HEAD`.
- **Files edited outside chezmoi:** `chezmoi status`. In the first column,
  `M` means the target changed since chezmoi last wrote it, and an apply
  would overwrite that edit.

## 3. Fetch

`git -C <src> fetch --quiet`, then `git -C <src> log --oneline HEAD..@{u}`.
If that prints nothing, say the dotfiles are up to date (plus anything from
step 2) and stop.

## 4. Preview the update on this machine

Check out the upstream commit in a temporary worktree and diff against it, so
the preview is exact for this host without touching the real source dir:

```bash
tmp=$(mktemp -d)
git -C <src> worktree add --detach --quiet "$tmp" @{u}
chezmoi --source "$tmp" status
chezmoi --source "$tmp" diff --no-pager
git -C <src> worktree remove --force "$tmp"
```

Always remove the worktree, even if a command failed.

From that and `git -C <src> diff --stat HEAD..@{u}`, work out:

- **Files** that would change on this machine, grouped by tool (nvim, herdr,
  fish/bash, Claude, skills). Changes for other hosts don't show up in the
  diff, so don't list them.
- **Scripts** that would run: `R` lines for `.chezmoiscripts/` in `status`.
  Say what each does, and whether it needs `sudo` or network access.
- **`chezmoi init` needed** if `.chezmoi.toml.tmpl` changed.
- **Conflicts:** files marked `M` in step 2 that the update also changes.

## 5. Report

Keep it short: plain bullets, one point each, no paragraphs. Use this shape
and drop any section that would be empty:

```
**N new commits** on origin/main.

What changes here:
- nvim: <one line>
- herdr: <one line>

Scripts that will run:
- mise: installs <tools> (needs sudo)

Watch out:
- ~/.config/x was edited locally; apply overwrites it

Run:
1. `chezmoi git pull -- --ff-only`
2. `chezmoi init`   <- only if the config template changed
3. `chezmoi diff`
4. `chezmoi apply`
```

Adjust the commands to what you found:

- **Uncommitted edits or unpushed commits:** put this before the pull:
  commit or stash, then pull with `chezmoi git pull -- --rebase` instead of
  `--ff-only`, and push afterwards.
- **A local edit worth keeping:** run `chezmoi re-add <file>` and commit it
  before pulling, or the apply overwrites it.
- **Scripts that need network access in an offline sandbox:** say so, and
  have the user run `chezmoi apply` themselves (e.g. `! chezmoi apply`).

End the report by offering to run these commands.

## 6. Run on request

Only after the user says yes, run the commands from the report in order, and
stop at the first failure and report it. Leave steps that need the user to
them: committing or stashing local edits, `re-add` decisions, and scripts
that need sudo or network access you don't have.

Then confirm with `chezmoi status` (empty means everything applied) and
report in a line or two what changed and anything left for the user.
