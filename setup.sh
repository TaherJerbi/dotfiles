#!/usr/bin/env bash
# Checks that the external tools this repo's configs (nvim, fish, alacritty,
# herdr, karabiner) rely on are installed, and reports what's missing.
#
# Usage:
#   ./setup.sh          Check only, print a report.
#   ./setup.sh --install Also install missing packages via the detected
#                        package manager (pacman on Arch/CachyOS, brew on
#                        macOS). Requires sudo on pacman systems.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DO_INSTALL=0
[ "${1:-}" = "--install" ] && DO_INSTALL=1

if command -v pacman >/dev/null 2>&1; then
  PM=pacman
elif command -v brew >/dev/null 2>&1; then
  PM=brew
else
  PM=none
fi

# cmd|pacman pkg|brew pkg (prefix with "cask:" for a brew cask)|why it's needed
DEPS="
git|git|git|clone/update plugins (nvim, kickstart)
make|make|make|build telescope-fzf-native and other native plugins
unzip|unzip|unzip|mason package extraction (nvim LSP/formatter installs)
cc|gcc|gcc|compile treesitter parsers and native plugins
rg|ripgrep|ripgrep|telescope live grep
fd|fd|fd|telescope file finding
lazygit|lazygit|lazygit|<leader>lg in nvim, 'lg' fish alias
zoxide|zoxide|zoxide|fish 'z' jumping, herdr workspace switcher
nvim|neovim|neovim|this nvim config
fish|fish|fish|this fish config
alacritty|alacritty|cask:alacritty|this alacritty config
"

echo "Package manager detected: $PM"
echo

missing_installable=()
report_line() { printf '  %-10s %-8s %s\n' "$1" "$2" "$3"; }

echo "Checking dependencies..."
while IFS='|' read -r cmd pacman_pkg brew_pkg reason; do
  [ -z "$cmd" ] && continue
  if command -v "$cmd" >/dev/null 2>&1; then
    report_line "$cmd" "ok" "$reason"
  else
    report_line "$cmd" "MISSING" "$reason"
    missing_installable+=("$cmd|$pacman_pkg|$brew_pkg")
  fi
done <<EOF
$DEPS
EOF

echo
echo "Checking optional/manual tools..."

if command -v herdr >/dev/null 2>&1; then
  report_line herdr ok "not package-managed; already on PATH"
else
  report_line herdr "MISSING" "not package-managed; install manually and ensure it's on PATH"
fi

if command -v xclip >/dev/null 2>&1 || command -v xsel >/dev/null 2>&1 \
  || command -v wl-copy >/dev/null 2>&1 || command -v pbcopy >/dev/null 2>&1; then
  report_line clipboard ok "'\"+y' clipboard yank in nvim"
else
  report_line clipboard "MISSING" "install xclip/xsel (X11) or wl-clipboard (Wayland); macOS has pbcopy built in"
fi

case "$(uname -s)" in
  Darwin)
    if [ -d "/Applications/Karabiner-Elements.app" ]; then
      report_line karabiner ok "reads karabiner/karabiner.json"
    else
      report_line karabiner "MISSING" "brew install --cask karabiner-elements"
    fi
    ;;
  *)
    report_line karabiner "n/a" "macOS-only, irrelevant on this platform"
    ;;
esac

if [ "$DO_INSTALL" -eq 1 ] && [ "${#missing_installable[@]}" -gt 0 ] && [ "$PM" != "none" ]; then
  echo
  echo "Installing missing packages via $PM..."
  for entry in "${missing_installable[@]}"; do
    IFS='|' read -r cmd pacman_pkg brew_pkg <<< "$entry"
    case "$PM" in
      pacman)
        sudo pacman -S --needed --noconfirm "$pacman_pkg"
        ;;
      brew)
        if [[ "$brew_pkg" == cask:* ]]; then
          brew install --cask "${brew_pkg#cask:}"
        else
          brew install "$brew_pkg"
        fi
        ;;
    esac
  done
elif [ "${#missing_installable[@]}" -gt 0 ]; then
  echo
  if [ "$PM" = "none" ]; then
    echo "No supported package manager (pacman/brew) found; install the MISSING tools above manually."
  else
    echo "Missing tools listed above. Re-run with --install to install them via $PM."
  fi
fi

# Symlinks herdr's own scripts and checks its own dependencies (fzf, jq, eza, bat).
if [ -x "$REPO_DIR/herdr/scripts/setup.sh" ] && command -v herdr >/dev/null 2>&1; then
  echo
  "$REPO_DIR/herdr/scripts/setup.sh"
fi

echo
echo "A Nerd Font is optional but recommended for icons; see https://www.nerdfonts.com/"
echo "and set vim.g.have_nerd_font = true in nvim/init.lua once installed."
