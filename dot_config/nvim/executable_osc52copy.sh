#!/usr/bin/env bash
# Clipboard copy for ttyd/tmux/code-server.
# Reads text from stdin and routes it to the host clipboard:
#   - code-server (VS Code): OSC 52 is broken there; use `code-server -c` instead.
#   - tmux: write OSC 52 directly to the client TTY so it bypasses tmux's pane
#     buffer and reaches the browser's navigator.clipboard.writeText().
#   - bare terminal: emit OSC 52 to stdout (direct connection to the terminal).
#     Only useful when run from a shell -- nvim captures a clipboard job's
#     stdout, so personal/init.lua uses nvim's native OSC 52 in that case.

text=$(cat)
b64=$(printf '%s' "$text" | base64 -w 0)

if [ -n "$VSCODE_IPC_HOOK_CLI" ]; then
    printf '%s' "$text" | code-server -c
elif [ -n "$TMUX" ]; then
    tty=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
    printf "\e]52;c;%s\a" "$b64" > "${tty:-/dev/tty}"
else
    printf "\e]52;c;%s\a" "$b64"
fi
