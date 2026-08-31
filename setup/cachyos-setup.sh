# CachyOS (Arch) half of setup.sh. Sourced by setup/setup.sh when
# ~/.config/host says "cachyos"; $REPO_DIR, $HOST and report_line() come from
# there.

HOST_PM=pacman

host_pkg() {
  case "$1" in
    cc)          echo gcc ;;
    rg)          echo ripgrep ;;
    nvim)        echo neovim ;;
    tree-sitter) echo tree-sitter-cli ;;
    *)           echo "$1" ;;
  esac
}

host_install() {
  sudo pacman -S --needed --noconfirm "$@"
}

host_checks() {
  if command -v xclip >/dev/null 2>&1 || command -v xsel >/dev/null 2>&1 \
    || command -v wl-copy >/dev/null 2>&1; then
    report_line clipboard ok "'\"+y' clipboard yank in nvim"
  else
    report_line clipboard "MISSING" "pacman -S xclip (X11) or wl-clipboard (Wayland)"
  fi
}

host_post() {
  # rofimoji only ever reads ~/.config/rofimoji.rc directly (it has no notion
  # of a config subfolder), but the real file lives in rofimoji/rofimoji.rc to
  # match this repo's per-app-folder layout. Symlink it into place; the symlink
  # itself isn't tracked in git since it's a generated, machine-local artifact.
  # Linux-only: rofi is X11/Wayland, so this never applies on macOS.
  local link="$REPO_DIR/rofimoji.rc"
  if [ -f "$REPO_DIR/rofimoji/rofimoji.rc" ] && [ ! -e "$link" ]; then
    ln -s rofimoji/rofimoji.rc "$link"
    echo
    echo "Symlinked rofimoji.rc -> rofimoji/rofimoji.rc"
  fi
}
