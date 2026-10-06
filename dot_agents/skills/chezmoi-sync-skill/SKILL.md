---
name: chezmoi-sync-skill
description: "Add an agent skill to the user's chezmoi dotfiles so it syncs to their other machines, or push local edits of an already-synced skill back into chezmoi. Use when the user asks to sync, track, add or save a skill to chezmoi or their dotfiles. Skills are only synced when the user explicitly asks."
---

# Sync a skill to chezmoi

Skills are kept harness-agnostic:

- The real skill lives in `~/.agents/skills/<name>/`.
- Each agent harness gets a relative symlink to it. For Claude Code that's
  `~/.claude/skills/<name>` → `../../.agents/skills/<name>`.

chezmoi's source dir is `~/.local/share/chezmoi` (run `chezmoi source-path` to
confirm). There the skill is `dot_agents/skills/<name>/` and the Claude link is
`dot_claude/skills/symlink_<name>`. Only skills the user names get synced;
never add a whole `skills/` folder.

**The dotfiles repo (github.com/taherjerbi/dotfiles) is public.** Whatever is
added is published on the next push.

## Never sync

- `~/.claude/skills/synced/`: synced by the user's claude.ai account.
- Skills installed by the `skills` CLI (`npx skills`). They're listed in
  `~/.agents/.skill-lock.json` (e.g. `herdr`), and that tool installs and
  updates them.

These are already in `.chezmoiignore`. If the user asks for one, explain why
and don't add it.

## Steps

1. **Find the skill.**
   - In `~/.agents/skills/<name>/` already: good.
   - Only in `~/.claude/skills/<name>/` as a real directory (Claude Code
     creates new skills there): move it and link it back:
     ```
     mv ~/.claude/skills/<name> ~/.agents/skills/<name>
     ln -s ../../.agents/skills/<name> ~/.claude/skills/<name>
     ```
   - Make sure `~/.claude/skills/<name>` is a symlink to it either way
     (`ls -la ~/.claude/skills`); create it with the `ln -s` above if missing.

2. **See if it's already tracked**: `chezmoi managed | grep "skills/<name>"`.
   - Already tracked: the user probably edited it locally. Show
     `chezmoi diff ~/.agents/skills/<name>` (the diff is source → target, so
     it shows the local edits reversed), then
     `chezmoi re-add ~/.agents/skills/<name>` and skip to step 6.

3. **Read every file in the skill** and scan it before publishing:
   tokens, API keys, passwords, emails, private hostnames/IPs, client or
   employer names, anything from a `.env`. Hardcoded home paths like
   `/home/cronlab` are fine. If something sensitive turns up, stop and tell the
   user what and where; don't add the skill until they decide.

4. **Ask whether it's machine-specific** if the content suggests it (it
   mentions KDE, keyd, macOS-only tools, a specific GPU, local paths that only
   exist on one box). If so, add a host gate to `.chezmoiignore` inside the
   existing `hyper-shortcut` block or a new one, covering both paths:
   ```
   {{ if ne .host "cachyos" }}
   .agents/skills/<name>
   .claude/skills/<name>
   {{ end }}
   ```
   Hosts are `macos`, `cachyos`, `parrotos`, `other` (current one is in
   `~/.config/chezmoi/chezmoi.toml`). Prefer `.chezmoi.os` (`"darwin"`,
   `"linux"`) when the OS is what decides it. Skip the question when the skill
   is plainly portable.

5. **Add both the skill and the link**:
   ```
   chezmoi add ~/.agents/skills/<name> ~/.claude/skills/<name>
   ```
   Check `dot_claude/skills/symlink_<name>` contains
   `../../.agents/skills/<name>`.

6. **Verify**:
   - `chezmoi managed | grep "skills/<name>"` lists both
     `.agents/skills/<name>/...` and `.claude/skills/<name>`.
   - `chezmoi diff` is empty for them.
   - `git -C "$(chezmoi source-path)" status --short` shows only the expected
     paths.

7. **Commit, don't push.** Commit just this skill and its link (plus
   `.chezmoiignore` if it changed) in the source dir, with a message like
   `Sync <name> skill`. Then tell the user it's committed and ask before
   pushing, since the repo is public.

## Removing a skill from sync

`chezmoi forget ~/.agents/skills/<name> ~/.claude/skills/<name>` stops tracking
both but leaves the local copies. Other machines keep theirs too unless both
paths are also listed in `.chezmoiremove`; ask whether they want that. Remove
any host gate for it from `.chezmoiignore`, then commit.
