---
name: obsidian-add-note
description: "Write or add a note to the user's Obsidian vault (~/vaults/main), e.g. 'add this to a note in my vault', 'save the learnings to my inbox'. Use whenever creating or substantially writing a note in that vault."
---

# Vault note

The vault is at `~/vaults/main`. New notes go in `0. Inbox/` unless the user names another folder.

## Required on every note I write

- **Title starts with 🤖**, in both the filename (`🤖 Title.md`) and the H1 (`# 🤖 Title`).
- **Tag `source/ai`** in the frontmatter `tags:` list.

## Frontmatter format

Match the vault's existing notes:

```
---
date created: Monday, October 5th 2026, 10:28:16 pm
date modified: Monday, October 5th 2026, 10:28:16 pm
tags:
  - source/ai
---
# 🤖 Title
```

Get the current time with `date` and write the day with an ordinal suffix (1st, 2nd, 3rd, 5th...). Tags are YAML list items indented two spaces.

## Style

Look at a recent note in `0. Inbox/` first and match it: plain explanatory prose, `##` sections, bold for key facts, tables where they help, and machine-specific details (e.g. "**My machine:** RTX 5070 Ti, 16 GB VRAM") where relevant. Check any commands in the note actually work before saving.
