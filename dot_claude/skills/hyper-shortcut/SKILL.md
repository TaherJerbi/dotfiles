---
name: hyper-shortcut
description: "Add a new Hyper+<key> global keyboard shortcut that toggles-focus/launches an app via ~/.local/bin/toggle-app, on this KDE Plasma (Wayland) machine. Use when the user asks to add, create, or bind a new app shortcut, especially referencing Hyper, toggle-app, or the existing Hyper+B/F/T shortcuts."
---

# Hyper app-toggle shortcut

This machine binds `Hyper+<letter>` keys to focus-or-launch specific apps via
`~/.local/bin/toggle-app <window-class-regex> <launch-command...>`. The script
focuses the app's window if it exists (minimizing it if already focused), or
launches it if not running.

"Hyper" is emulated by `keyd` (`/etc/keyd/default.conf`): right-Alt is a layer
that sends `Ctrl+Shift+Meta`. So **Hyper+N == Meta+Ctrl+Shift+N** in KDE's
shortcut config — always translate the Hyper key the user asks for into that
modifier combo.

Existing bindings (for reference/pattern-matching):

| Key | App | Class regex | Launch command |
|-----|-----|-------------|-----------------|
| Hyper+T | Terminal | `Alacritty` | `alacritty` |
| Hyper+B | Browser | `brave-browser` | `brave` |
| Hyper+F | Files | `org.kde.dolphin` | `dolphin` |

## Steps to add a new one

1. **Find the next free index.** List `~/.local/share/applications/net.local.toggle-app*.desktop` and pick the next number (e.g. if `toggle-app-4.desktop` exists, use `-5`).

2. **Find the target app's window class.** Check its installed `.desktop` file for `StartupWMClass`:
   ```bash
   grep -ri wmclass /usr/share/applications/<app>.desktop ~/.local/share/applications/<app>.desktop 2>/dev/null
   ```
   If not declared, the runtime WM_CLASS is often the lowercase binary/product name (e.g. Electron apps). When in doubt, launch the app and check with:
   ```bash
   ~/.local/bin/kdotool search --class '<guess>'
   ```
   `kdotool search --class` does a regex/substring match, not full-string equality — a lowercase substring like `obsidian` matches `md.obsidian.Obsidian` fine.

3. **Create the desktop file** at `~/.local/share/applications/net.local.toggle-app-<N>.desktop`:
   ```ini
   [Desktop Entry]
   Exec=/home/cronlab/.local/bin/toggle-app <window-class-regex> <launch-binary>
   Name=Toggle <AppName>
   NoDisplay=true
   StartupNotify=false
   Type=Application
   X-KDE-GlobalAccel-CommandShortcut=true
   ```

4. **Register it with KDE** so it's picked up as a service:
   ```bash
   kbuildsycoca6
   ```

5. **Add the shortcut binding** in `~/.config/kglobalshortcutsrc`, translating Hyper+<key> to `Meta+Ctrl+Shift+<key>`:
   ```bash
   kwriteconfig6 --file kglobalshortcutsrc --group "services" \
     --group "net.local.toggle-app-<N>.desktop" \
     --key "_launch" "Meta+Ctrl+Shift+<KEY>"
   ```

6. **Verify the toggle logic works** (independent of KDE keybinding registration):
   ```bash
   ~/.local/bin/kdotool search --class '<window-class-regex>'   # should find it if running
   ~/.local/bin/toggle-app '<window-class-regex>' <launch-binary>  # should focus/minimize/launch
   ```

## Important limitation: activating the binding live

`kglobalaccel` (KDE's global shortcut daemon) only scans for **new**
command-shortcut `.desktop` files at its own startup — editing
`kglobalshortcutsrc` and running `kbuildsycoca6` does *not* make a brand-new
shortcut go live immediately. You can confirm whether a component is
registered with:
```bash
qdbus6 --literal org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel.allMainComponents
```
Look for `net.local.toggle-app-<N>.desktop` in the output.

On this machine, `kglobalaccel` runs **embedded inside `kwin_wayland`**
(confirm with `busctl --user list | grep kglobalaccel` — if the owning
process is `kwin_wayland`, it's embedded). That means the only way to force
the new shortcut live immediately is to restart `kwin_wayland`, which ends
the Wayland session (logs the user out). **Never do this without explicit
confirmation** — it's a disruptive, session-ending action.

Default behavior: tell the user the config is fully in place and correct,
matching the existing pattern, and that the new Hyper shortcut will become
active automatically after their next logout/login (or reboot). Only offer
to restart `kwin_wayland` immediately if they explicitly ask for it to be
live right now, and confirm first since it will log them out.
