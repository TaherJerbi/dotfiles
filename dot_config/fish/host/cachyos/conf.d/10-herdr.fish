# Drop straight into herdr on an interactive shell, unless already inside a
# herdr-managed pane. Deliberately per-host: not a flow every machine wants.
#
# Only *defines* the hook here: conf.d is sourced before config.fish, so
# exec'ing at this point would hand herdr — and every popup command it spawns —
# a PATH without ~/.local/bin or mise's shims. config.fish calls this last.
function dots_host_autostart
    if status is-interactive; and test -z "$HERDR_ENV"
        for herdr in (command -v herdr) $HOME/.local/bin/herdr
            test -x "$herdr"; and exec $herdr
        end
    end
end
