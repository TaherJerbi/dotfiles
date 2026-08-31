#!/usr/bin/env bash
# Checks that the external tools this repo's configs (nvim, fish, alacritty,
# herdr) rely on are installed, and reports what's missing.
#
# This file holds only what is true on every machine: the list of required
# commands and why each is needed. Anything machine-specific -- package names,
# the package manager, extra checks, generated files -- lives in
# setup/$HOST-setup.sh, selected by the one word in ~/.config/host.
#
# Usage:
#   ./setup/setup.sh           Check only, print a report.
#   ./setup/setup.sh --install Also install missing packages via this
#                              machine's package manager. May require sudo.
set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SETUP_DIR")"
DO_INSTALL=0
[ "${1:-}" = "--install" ] && DO_INSTALL=1

report_line() { printf '  %-12s %-8s %s\n' "$1" "$2" "$3"; }

# --- machine identity -------------------------------------------------------
# ~/.config/host names this machine in one word. fish's conf.d/00-host.fish
# reads it into $DOTS_HOST and sources fish/conf.d/host/$DOTS_HOST.fish.
# It's gitignored, so set it on a new box.
HOST_FILE="$REPO_DIR/host"
HOST="$(cat "$HOST_FILE" 2>/dev/null | tr -d '[:space:]')"
case "$HOST" in
  macos|cachyos|other) ;;
  *)
    if [ -z "$HOST" ]; then
      echo "Machine identity not set. Run: echo <name> > $HOST_FILE" >&2
    else
      echo "Unknown machine identity '$HOST' in $HOST_FILE." >&2
    fi
    echo "  Options: macos | cachyos | other" >&2
    exit 1
    ;;
esac
echo "Machine identity: $HOST"

# --- host hooks -------------------------------------------------------------
# Defaults, so an identity with no script of its own ("other") still gets a
# useful check-only run. setup/$HOST-setup.sh overrides whichever it wants:
#
#   host_pkg <cmd>      echo the package name providing <cmd> on this machine,
#                       or nothing if it isn't installable here.
#   host_install <pkg>… install those packages.
#   host_checks         extra report_line checks for this machine only.
#   host_post           generated files / symlinks for this machine only.
HOST_PM="none"
host_pkg() { :; }
host_install() { :; }
host_checks() { :; }
host_post() { :; }

HOST_SCRIPT="$SETUP_DIR/$HOST-setup.sh"
if [ -f "$HOST_SCRIPT" ]; then
  # shellcheck source=/dev/null
  . "$HOST_SCRIPT"
else
  echo "No $HOST-setup.sh; running shared checks only (nothing will be installed)."
fi
echo "Package manager: $HOST_PM"
echo

# --- shared dependencies ----------------------------------------------------
# cmd|why it's needed. Package names per machine live in host_pkg.
DEPS="
git|clone/update plugins (nvim, kickstart)
make|build telescope-fzf-native and other native plugins
unzip|mason package extraction (nvim LSP/formatter installs)
cc|compile treesitter parsers and native plugins
rg|telescope live grep
fd|telescope file finding
lazygit|<leader>lg in nvim, 'lg' fish alias
zoxide|fish 'z' jumping, herdr workspace switcher
nvim|this nvim config (requires >= 0.12 for vim.pack)
tree-sitter|compile treesitter parsers
fish|this fish config
alacritty|this alacritty config
"

missing_pkgs=()

echo "Checking dependencies..."
while IFS='|' read -r cmd reason; do
  [ -z "$cmd" ] && continue
  if command -v "$cmd" >/dev/null 2>&1; then
    report_line "$cmd" "ok" "$reason"
    continue
  fi
  pkg="$(host_pkg "$cmd")"
  if [ -n "$pkg" ]; then
    report_line "$cmd" "MISSING" "$reason"
    missing_pkgs+=("$pkg")
  else
    report_line "$cmd" "MISSING" "$reason -- no package known for $HOST, install manually"
  fi
done <<EOF
$DEPS
EOF

# The nvim config uses vim.pack and the PackChanged event, both Neovim 0.12+.
# On 0.11 init.lua aborts with "Invalid 'event': 'PackChanged'".
if command -v nvim >/dev/null 2>&1; then
  nvim_ver="$(nvim --version | head -1 | sed 's/^NVIM v//')"
  nvim_major="${nvim_ver%%.*}"
  nvim_rest="${nvim_ver#*.}"
  nvim_minor="${nvim_rest%%.*}"
  if [ "$nvim_major" -eq 0 ] && [ "$nvim_minor" -lt 12 ]; then
    report_line nvim "TOO OLD" "have $nvim_ver, need >= 0.12 (vim.pack); upgrade neovim"
  fi
fi

echo
echo "Checking optional/manual tools..."

if command -v herdr >/dev/null 2>&1; then
  report_line herdr ok "not package-managed; already on PATH"
else
  report_line herdr "MISSING" "not package-managed; install manually and ensure it's on PATH"
fi

host_checks

# --- install ----------------------------------------------------------------
if [ "${#missing_pkgs[@]}" -gt 0 ]; then
  echo
  if [ "$HOST_PM" = "none" ]; then
    echo "No package manager configured for $HOST; install the MISSING tools above manually."
  elif [ "$DO_INSTALL" -eq 1 ]; then
    echo "Installing missing packages via $HOST_PM..."
    host_install "${missing_pkgs[@]}"
  else
    echo "Missing tools listed above. Re-run with --install to install them via $HOST_PM."
  fi
fi

# --- generated files --------------------------------------------------------
host_post

# Symlinks herdr's own scripts and checks its own dependencies (fzf, jq, eza, bat).
if [ -x "$REPO_DIR/herdr/scripts/setup.sh" ] && command -v herdr >/dev/null 2>&1; then
  echo
  "$REPO_DIR/herdr/scripts/setup.sh"
fi

echo
echo "A Nerd Font is optional but recommended for icons; see https://www.nerdfonts.com/"
