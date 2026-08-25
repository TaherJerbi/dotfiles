# alacritty

`alacritty.toml` is shared between machines. Anything host-specific goes in
`local.toml`, which is gitignored and imported from `[general] import`.
`../setup.sh` generates the `[terminal.shell]` block; the font is manual.

## local.toml on the Mac

```toml
[terminal.shell]
program = "/opt/homebrew/bin/fish"
args = ["--login"]

[font.normal]
family = "JetBrainsMono Nerd Font"
```
