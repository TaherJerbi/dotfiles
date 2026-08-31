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
# mise provides most of what follows (rg, fd, nvim, ...), so it activates
# first. Shims stay on PATH for non-fish callers; see run_onchange_after_20.
if command -v mise >/dev/null
    mise activate fish | source
end

if command -v zoxide >/dev/null
    zoxide init fish | source
end

if command -v direnv >/dev/null; and not functions -q __direnv_export_eval
    direnv hook fish | source
end

# --- host autostart ---------------------------------------------------------
# Last, so anything it exec's (herdr) inherits the PATH built above.
functions -q dots_host_autostart; and dots_host_autostart
