---
name: chezmoi-skills-update
description: "Update the agent skills installed by the `skills` CLI (npx skills, e.g. mattpocock/skills) and copy the updates into the user's chezmoi dotfiles so every machine gets them. Use when the user asks to update, upgrade or refresh their skills. For pulling dotfile changes from the repo, use chezmoi-update instead."
---

# Update `skills` CLI skills in chezmoi

Some skills in the dotfiles come from the `skills` CLI: their copies are
tracked in chezmoi like any other skill, and the CLI's lock,
`~/.agents/.skill-lock.json`, records where each came from. This skill updates
them with the CLI, then copies the result into chezmoi for the other machines.

The CLI needs the network: never run `npx skills` yourself. Give the user the
command to run as `! <command>` and wait for its output.

## 1. Find the tracked CLI skills

- Source dir: `chezmoi source-path`.
- Lock entries: `jq -r '.skills | to_entries[] | "\(.key)\t\(.value.source)"' ~/.agents/.skill-lock.json`.
- Keep the ones chezmoi tracks:
  `chezmoi managed --include=dirs | grep '^.agents/skills/'`. Others (e.g.
  `herdr`) are per machine; leave them alone.
- If `git -C <src> status --short` isn't clean, tell the user and stop; the
  commit at the end must hold only this update.

## 2. Update

Have the user run `! npx skills update -g`.

## 3. Skills added or removed upstream

`update` only refreshes installed skills. For each source from step 1, have
the user run `! npx skills add <source> -g -l`, which lists the source's skills
without installing anything. Compare with the tracked skills from that source
and ask the user about each difference:

- **New upstream**: to add it, have them run
  `! npx skills add <source> -g -y -a claude-code -s <name>`, then
  `chezmoi add ~/.agents/skills/<name>`.
- **Gone upstream**: to drop it, follow the chezmoi-skills-add skill's
  "Removing a skill from sync", then have them run
  `! npx skills remove -g -y -s <name>` to delete the local copy.

## 4. Copy the updates into chezmoi

Run `~/.agents/skills/chezmoi-skills-update/skills-sync.sh`. It replaces the
source copy of every tracked CLI skill, so files an update added or removed are
picked up too, and prints `git status` for the skills.

If nothing changed, say the skills are up to date and stop.

## 5. Review

Read `git -C <src> diff` (and any new files) and summarize, per skill, what
changed in behaviour: new or removed rules, steps, files. Call out every change
to a `description:` line separately, since that decides when the skill fires.
Ask the user to confirm before committing.

## 6. Commit, don't push

Commit the skill changes (plus `.chezmoiremove` if step 3 touched it) with a
message like `Update mattpocock/skills skills`. Then tell the user it's
committed and ask before pushing: the repo is public, and pushing is what
sends the update to the other machines.
