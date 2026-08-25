if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

export PATH="$HOME/.local/bin:$PATH"

if command -v zoxide >/dev/null
    zoxide init fish | source
end

# Launch herdr automatically on interactive shell startup, unless we're
# already inside a herdr-managed pane.
if status is-interactive
    and test -z "$HERDR_ENV"
    and command -v herdr >/dev/null
    exec herdr
end
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

set -gx EDITOR vim
set -gx VISUAL vim

alias lg lazygit
