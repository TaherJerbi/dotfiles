# Sets $DOTS_HOST, the "which machine is this" switch used to conditionally
# load the rest of this repo.
#
# The value comes from ~/.config/host -- a one-line, gitignored file you write
# by hand once per machine. e.g.
#
#     echo macos > ~/.config/host
#
# Numbered 00- so it runs before every other conf.d snippet.

if not set -q DOTS_HOST
    set -l host_file "$__fish_config_dir/../host"
    if test -r $host_file
        set -gx DOTS_HOST (string trim < $host_file)
    end
end

# Everything under fish/host/$DOTS_HOST is loaded only on that machine, laid
# out like a fish config dir of its own:
#
#   host/<name>/conf.d/*.fish   sourced here, in order
#   host/<name>/functions/      prepended to $fish_function_path
#   host/<name>/completions/    prepended to $fish_complete_path
#
# Prepended, not appended, so a host can override a shared function (macos
# overrides fish_prompt with pure's, for instance). conf.d is sourced by hand
# because fish only reads its own top-level conf.d.
if set -q DOTS_HOST
    set -l host_dir "$__fish_config_dir/host/$DOTS_HOST"
    if test -d $host_dir
        test -d $host_dir/functions; and set -p fish_function_path $host_dir/functions
        test -d $host_dir/completions; and set -p fish_complete_path $host_dir/completions
        for f in $host_dir/conf.d/*.fish
            source $f
        end
    end
end
