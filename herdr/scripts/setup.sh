#!/usr/bin/env bash
# Sets up the scripts in this directory on a fresh machine: symlinks each
# script into ~/.local/bin. Safe to re-run.
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"

echo "Linking scripts into $BIN_DIR"
for script in herdr-workspace-switcher herdr-workspace-preview; do
  chmod +x "$SCRIPTS_DIR/$script"
  ln -sf "$SCRIPTS_DIR/$script" "$BIN_DIR/$script"
  echo "  $script"
done

echo
echo "Checking dependencies..."
missing=()
for cmd in fzf jq zoxide eza bat; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo "  Missing (install for full functionality): ${missing[*]}"
else
  echo "  All present: fzf jq zoxide eza bat"
fi
