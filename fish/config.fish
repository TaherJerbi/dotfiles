# fish config — shared between macOS and CachyOS.
# Everything here is guarded by an existence check so the same file works on
# both machines. Machine-local secrets go in conf.d/local.fish (gitignored).

if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# --- PATH -------------------------------------------------------------------
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
else if test -x /usr/local/bin/brew
    /usr/local/bin/brew shellenv fish | source
end

set -gx VOLTA_HOME "$HOME/.volta"

for dir in \
    "$HOME/.local/bin" \
    "$VOLTA_HOME/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/go/bin" \
    /opt/homebrew/opt/libpq/bin \
    /usr/local/texlive/2024/bin/universal-darwin \
    "$HOME/Library/Android/sdk/platform-tools" \
    "$HOME/Library/Android/sdk/emulator" \
    "$HOME/Library/Android/sdk/tools/bin"
    test -d $dir; and fish_add_path -g $dir
end

if test -d "$HOME/Library/Android/sdk"
    set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
end

if test -d /usr/local/texlive/2024/texmf-dist/doc/man
    set -gx MANPATH /usr/local/texlive/2024/texmf-dist/doc/man $MANPATH
    set -gx INFOPATH /usr/local/texlive/2024/texmf-dist/doc/info $INFOPATH
end

# --- environment ------------------------------------------------------------
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx ESLINT_D_ROOT auto

# --- aliases ----------------------------------------------------------------
alias lg lazygit

# --- tools ------------------------------------------------------------------
if command -v zoxide >/dev/null
    zoxide init fish | source
end

if command -v direnv >/dev/null; and not functions -q __direnv_export_eval
    direnv hook fish | source
end

# --- herdr ------------------------------------------------------------------
# Launch herdr automatically on interactive shell startup, unless we're
# already inside a herdr-managed pane.
if status is-interactive
    and test -z "$HERDR_ENV"
    and command -v herdr >/dev/null
    exec herdr
end
