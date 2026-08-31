# Drop straight into herdr on an interactive shell, unless already inside a
# herdr-managed pane. Deliberately per-host: not a flow every machine wants.
if status is-interactive; and test -z "$HERDR_ENV"
    for herdr in (command -v herdr) $HOME/.local/bin/herdr
        test -x "$herdr"; and exec $herdr
    end
end
