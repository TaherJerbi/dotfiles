#!/usr/bin/env bash
# Check-only report of the tools this repo's configs (nvim, fish, alacritty,
# herdr) rely on. Installs nothing -- that's chezmoi's job, in
# .chezmoiscripts/run_onchange_before_10-packages.sh.tmpl.
#
# This also covers the optional and manually-installed tools that script
# deliberately doesn't manage.
#
#   ~/.config/setup/doctor.sh
set -euo pipefail

report() { printf '  %-12s %-8s %s\n' "$1" "$2" "$3"; }
have() { command -v "$1" >/dev/null 2>&1; }
check() { if have "$1"; then report "$1" ok "$2"; else report "$1" MISSING "$2"; fi; }

echo "Machine identity: $(cat "$HOME/.config/host" 2>/dev/null || echo '(unset)')"
echo
echo "Required (installed by chezmoi's package script)..."
check git         "clone/update plugins (nvim, kickstart)"
check make        "build telescope-fzf-native and other native plugins"
check unzip       "mason package extraction (nvim LSP/formatter installs)"
check cc          "compile treesitter parsers and native plugins"
check rg          "telescope live grep"
check fd          "telescope file finding"
check lazygit     "<leader>lg in nvim, 'lg' fish alias"
check zoxide      "fish 'z' jumping, herdr workspace switcher"
check nvim        "this nvim config (requires >= 0.12 for vim.pack)"
check tree-sitter "compile treesitter parsers"
check fish        "this fish config"
check alacritty   "this alacritty config"

# The nvim config uses vim.pack and the PackChanged event, both Neovim 0.12+.
# On 0.11 init.lua aborts with "Invalid 'event': 'PackChanged'".
if have nvim; then
  ver="$(nvim --version | head -1 | sed 's/^NVIM v//')"
  major="${ver%%.*}"; rest="${ver#*.}"; minor="${rest%%.*}"
  if [ "$major" -eq 0 ] && [ "$minor" -lt 12 ]; then
    report nvim "TOO OLD" "have $ver, need >= 0.12 (vim.pack); upgrade neovim"
  fi
fi

echo
echo "Optional / not package-managed..."
check herdr "install manually and ensure it's on PATH"
for cmd in fzf jq eza bat; do
  check "$cmd" "herdr workspace switcher"
done

case "$(uname -s)" in
  Darwin)
    check pbcopy "'\"+y' clipboard yank in nvim"
    if [ -d "/Applications/Karabiner-Elements.app" ]; then
      report karabiner ok "reads karabiner/karabiner.json"
    else
      report karabiner MISSING "brew install --cask karabiner-elements"
    fi
    ;;
  Linux)
    if have xclip || have xsel || have wl-copy; then
      report clipboard ok "'\"+y' clipboard yank in nvim"
    else
      report clipboard MISSING "pacman -S xclip (X11) or wl-clipboard (Wayland)"
    fi
    ;;
esac

echo
echo "A Nerd Font is optional but recommended for icons; see https://www.nerdfonts.com/"
