---
name: chezmoi-skills-add
description: "Add an agent skill to the user's chezmoi dotfiles so it syncs to their other machines, or push local edits of an already-synced skill back into chezmoi. Use when the user asks to sync, track, add or save a skill to chezmoi or their dotfiles. Skills are only synced when the user explicitly asks."
---

# Sync a skill to chezmoi

Skills are kept harness-agnostic:

- The real skill lives in `~/.agents/skills/<name>/`.
- Each agent harness gets a relative symlink to it. For Claude Code that's
  `~/.claude/skills/<name>` → `../../.agents/skills/<name>`.

chezmoi's source dir is `~/.local/share/chezmoi`, or `/mnt/persistent/dotfiles`
on the devpod (run `chezmoi source-path` to confirm). There the skill is
`dot_agents/skills/<name>/`. The Claude link isn't tracked:
`run_onchange_after_30-skill-links.sh` creates it on `chezmoi apply` for every
skill in that directory. Only skills the user names get synced; never add a
whole `skills/` folder.

**The dotfiles repo (github.com/taherjerbi/dotfiles) is public.** Whatever is
added is published on the next push.

## Never sync

- `~/.claude/skills/synced/`: synced by the user's claude.ai account.
- `herdr`, installed per machine by the `skills` CLI (`npx skills`).
- Symlinks into another repo, like the devpod's links into
  `/opt/ff/tools/claude_code/skills/`: that repo owns them.
- Work-only skills on the devpod (e.g. `artifact-private`, `artifact-shared`),
  which name internal hosts. They stay untracked.

If the user asks for one, explain why and don't add it.

Other `skills` CLI skills (listed in `~/.agents/.skill-lock.json`, e.g. the
mattpocock/skills set) are synced like any other skill. To update them, use
the chezmoi-skills-update skill instead of step 2's `re-add`.

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
     (`ls -la ~/.claude/skills`); create it with the `ln -s` above if missing,
     so it works before the next `chezmoi apply`.

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

4. **Ask which machines get it** if the user hasn't said and the content
   suggests it's machine-specific (it mentions KDE, keyd, macOS-only tools,
   work tooling, local paths that only exist on one box). If it is, add it to
   `.chezmoidata/skills.yaml` with the hosts that get it:
   ```yaml
   skillhosts:
     <name>: [cachyos]
   ```
   A skill not listed goes everywhere, so a shared skill needs no entry. Hosts
   are `macos`, `cachyos`, `parrotos`, `devpod`, `other` (the current one is in
   `~/.config/chezmoi/chezmoi.toml`). Skip the question when the skill is
   plainly portable.

5. **Add the skill**: `chezmoi add ~/.agents/skills/<name>`. Not the
   `~/.claude/skills/<name>` link; the links script owns it.

6. **Verify**:
   - `chezmoi managed | grep "skills/<name>"` lists `.agents/skills/<name>/...`.
   - `chezmoi diff` is empty for it, apart from the links script, which re-runs
     because the skill list changed.
   - `git -C "$(chezmoi source-path)" status --short` shows only the expected
     paths.

7. **Commit, don't push.** Commit just this skill (plus
   `.chezmoidata/skills.yaml` if it changed) in the source dir, with a message
   like `Sync <name> skill`. Then tell the user it's committed and ask before
   pushing, since the repo is public.

## Removing a skill from sync

`chezmoi forget ~/.agents/skills/<name>` stops tracking it but leaves the
local copy and link. Other machines keep theirs too unless
`.agents/skills/<name>` and `.claude/skills/<name>` are listed in
`.chezmoiremove`; ask whether they want that. Remove its
`.chezmoidata/skills.yaml` entry if it has one, then commit.
