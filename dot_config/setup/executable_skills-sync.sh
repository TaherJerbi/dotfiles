#!/usr/bin/env bash
# Copies `skills` CLI updates into chezmoi. Run after `npx skills update -g`.
#
# Refreshes every skill in ~/.agents/.skill-lock.json that chezmoi already
# tracks, replacing its source dir so files the update added or removed are
# picked up too. Untracked CLI skills (e.g. herdr) are left alone; add a new
# one with `chezmoi add ~/.agents/skills/<name>`.
set -euo pipefail

lock="$HOME/.agents/.skill-lock.json"
src="$(chezmoi source-path)"
managed="$(chezmoi managed --include=dirs)"

for name in $(jq -r '.skills | keys[]' "$lock"); do
  grep -qxF ".agents/skills/$name" <<<"$managed" || continue
  rm -rf "$src/dot_agents/skills/$name"
  chezmoi add "$HOME/.agents/skills/$name"
done

git -C "$src" status --short -- dot_agents/skills
