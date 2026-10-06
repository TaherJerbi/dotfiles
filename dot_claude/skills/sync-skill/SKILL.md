---
name: sync-skill
description: "Add a Claude Code skill from ~/.claude/skills to the user's chezmoi dotfiles so it syncs to their other machines, or push local edits of an already-synced skill back into chezmoi. Use when the user asks to sync, track, add or save a skill to chezmoi or their dotfiles. Skills are only synced when the user explicitly asks."
---

# Sync a skill to chezmoi

Skills live in `~/.claude/skills/<name>/`. chezmoi's source dir is
`~/.local/share/chezmoi` (run `chezmoi source-path` to confirm), where they map
to `dot_claude/skills/<name>/`. Only skills the user names get synced; never
add the whole `skills/` folder.

**The dotfiles repo (github.com/taherjerbi/dotfiles) is public.** Whatever is
added is published on the next push.

## Never sync

- `skills/synced/`: synced by the user's claude.ai account.
- Any skill that is a symlink (e.g. `skills/herdr` → `~/.agents/skills/herdr`):
  another tool installs and owns it. Check with `ls -la ~/.claude/skills`.

Both are already in `.chezmoiignore`. If the user asks for one, explain why
and don't add it.

## Steps

1. **Check the skill exists** and is a real directory, not a symlink:
   `ls -la ~/.claude/skills/<name>`.

2. **See if it's already tracked**: `chezmoi managed | grep "skills/<name>"`.
   - Already tracked: the user probably edited it locally. Show
     `chezmoi diff ~/.claude/skills/<name>` (the diff is source → target, so
     it shows the local edits reversed), then `chezmoi re-add ~/.claude/skills/<name>`
     and skip to step 6.

3. **Read every file in the skill** and scan it before publishing:
   tokens, API keys, passwords, emails, private hostnames/IPs, client or
   employer names, anything from a `.env`. Hardcoded home paths like
   `/home/cronlab` are fine. If something sensitive turns up, stop and tell the
   user what and where; don't add the skill until they decide.

4. **Ask whether it's machine-specific** if the content suggests it (it
   mentions KDE, keyd, macOS-only tools, a specific GPU, local paths that only
   exist on one box). If so, add a host gate to `.chezmoiignore` next to the
   existing `hyper-shortcut` one:
   ```
   {{ if ne .host "cachyos" }}
   .claude/skills/<name>
   {{ end }}
   ```
   Hosts are `macos`, `cachyos`, `parrotos`, `other` (current one is in
   `~/.config/chezmoi/chezmoi.toml`). Prefer `.chezmoi.os` (`"darwin"`,
   `"linux"`) when the OS is what decides it. Skip the question when the skill
   is plainly portable.

5. **Add it**: `chezmoi add ~/.claude/skills/<name>`.

6. **Verify**:
   - `chezmoi managed | grep "skills/<name>"` lists it.
   - `chezmoi diff` is empty for it.
   - `git -C "$(chezmoi source-path)" status --short` shows only the expected
     paths.

7. **Commit, don't push.** Commit just this skill (plus `.chezmoiignore` if
   it changed) in the source dir, with a message like
   `Sync <name> Claude skill`. Then tell the user it's committed and ask before
   pushing, since the repo is public.

## Removing a skill from sync

`chezmoi forget ~/.claude/skills/<name>` stops tracking it but leaves the local
copy. Other machines keep their copy too unless it's also listed in
`.chezmoiremove`; ask whether they want that. Remove any host gate for it from
`.chezmoiignore`, then commit.
