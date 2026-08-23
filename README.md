# Cyberpunk rice

Cyberpunk Neon theming for macOS: Ghostty, zsh, tmux, btop, bat, delta,
fastfetch, and a four-pane HUD built from the *Watch tools.

## Install

```sh
git clone <this repo> ~/.dotfiles && ~/.dotfiles/install.sh && exec zsh
```

`install.sh` is idempotent. The macOS system layer is separate and opt-in:

```sh
~/.dotfiles/macos/snapshot.sh    # record current state FIRST
~/.dotfiles/macos/defaults.sh    # apply
~/.dotfiles/macos/restore.sh     # undo, from the snapshot
```

## Palette

`palette.sh` is the single source of truth. Every other themed surface
mirrors it by hand, because none of them can read shell variables.

| Role | Hex |
|---|---|
| bg / bg-alt | `#000b1e` / `#091833` |
| fg / fg-dim | `#0abdc6` / `#0f7d84` |
| magenta (accent) | `#ea00d9` |
| purple | `#711c91` |
| blue | `#133e7c` |
| green / yellow | `#00ff9f` / `#f3e600` |
| orange / red | `#f57800` / `#ff0055` |

## Layout

| Path | What |
|---|---|
| `ghostty/` | terminal config + `themes/cyberpunk-neon` |
| `zsh/cyberpunk.zsh` | aliases, tool init, p10k colour overrides |
| `tmux/tmux.conf` | neon status bar, vim nav, tpm plugins |
| `bat/` | `cyberpunk-neon.tmTheme` — also drives delta and fzf previews |
| `btop/themes/` | btop theme |
| `fastfetch/` | config + ASCII logo |
| `bin/hud` | four-pane dashboard |
| `bin/tmux-battery` | battery glyph for the status bar |
| `wallpaper/generate.py` | wallpaper generator (PIL, no numpy) |
| `macos/` | defaults apply + snapshot + restore |

## Commands

| Command | Does |
|---|---|
| `hud` | btop + netwatch + syswatch + diskwatch in a tiled grid (`hud -r` rebuilds) |
| `fetch` | fastfetch with the CYBERDECK logo |
| `cmd + \`` | Ghostty quick-terminal dropdown |
| `prefix` = `C-a` | tmux prefix; `\|` and `-` split, `hjkl` navigate |

## Notes

- Secrets live in `~/.config/secrets.zsh` (chmod 600), never in this repo.
- Menu-bar hiding is commented out in `macos/defaults.sh` — enable it when
  SketchyBar lands, not before, or you lose the clock with nothing replacing it.
- tmux configs use literal hex; tmux has no shell variables.
- `bin/hud` uses named pane targets (`{left}`, `{top-right}`) because
  `pane-base-index` is 1.
