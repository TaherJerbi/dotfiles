# Loaded only when ~/.config/host says "macos". Sourced from
# fish/conf.d/00-host.fish, before the pure/fisher snippets beside it.

/opt/homebrew/bin/brew shellenv fish | source

# --- fisher -----------------------------------------------------------------
# fisher and the pure prompt are macOS-only, so they live in this host dir
# rather than fish/{functions,conf.d,completions}. $fisher_path keeps `fisher
# install/update` writing here too, instead of back into the shared dirs.
#
# Caveat: fisher hardcodes its plugin list to $__fish_config_dir/fish_plugins,
# so that one file has to stay at fish/fish_plugins. Nothing reads it on other
# machines.
set -gx fisher_path "$__fish_config_dir/host/macos"

for dir in \
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
