# rofimoji

KDE's built-in emoji picker (Meta+.) only _types_ emoji directly into apps
that support Wayland's text-input protocol. Alacritty (and most GPU-rendered
terminals) don't, so it silently falls back to copying to the clipboard.
This setup replaces it with `rofimoji`, configured to copy the emoji and then
auto-send Ctrl+V, which works in any app.

`ydotool type` and `wtype` were both tried as direct typers and don't work
here: `ydotool` can't synthesize non-ASCII keystrokes (emoji come out as
nothing), and KWin doesn't expose the Wayland virtual-keyboard protocol
`wtype` needs. Copy + auto-paste sidesteps both problems since Ctrl+V is a
plain ASCII shortcut.

## Setup (KDE Plasma, Wayland, Arch/CachyOS)

1. Install packages:

   ```bash
   sudo pacman -S rofi rofimoji ydotool wl-clipboard
   ```

2. Enable the ydotool daemon (sends the Ctrl+V paste keystroke):

   ```bash
   systemctl --user enable --now ydotool.service
   ```

3. Make sure your user can access `/dev/uinput` (ydotoold needs it):

   ```bash
   ls -la /dev/uinput   # look for your user or a group you're in
   ```

   If not, add yourself to the group that owns it and log out/in:

   ```bash
   sudo usermod -aG ydotool "$USER"   # group name may vary by system
   ```

4. Run `../setup/setup.sh` from the repo root — it symlinks `rofimoji.rc` here into
   `~/.config/rofimoji.rc`, which is the only place rofimoji looks for it.

5. In System Settings → Shortcuts, disable KDE's own Meta+. emoji-picker
   binding, then add a Custom Shortcut → Command/URL: `rofimoji`, bound to
   your preferred shortcut.

6. Test: focus a text field and press Meta+. (or run `rofimoji` directly) —
   picking an emoji should paste it in place.
