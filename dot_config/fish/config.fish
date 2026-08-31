# fish config — the parts shared by every machine.
#
# Per-machine config lives in host/$DOTS_HOST/, picked by the one-word value
# chezmoi bakes into conf.d/00-host.fish. Machine-local secrets go in
# conf.d/local.fish (gitignored).
#
# Note: conf.d/* is sourced BEFORE this file, so $DOTS_HOST and anything the
# per-host file sets (Homebrew's PATH, for instance) is already in place here.

# --- PATH -------------------------------------------------------------------
set -gx VOLTA_HOME "$HOME/.volta"

for dir in \
    "$HOME/.local/bin" \
    "$VOLTA_HOME/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/go/bin"
    test -d $dir; and fish_add_path -g $dir
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
