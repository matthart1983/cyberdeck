# Cyberpunk rice

Cyberpunk Neon theming for macOS: AeroSpace tiling, SketchyBar, JankyBorders,
Ghostty, zsh, tmux, btop, bat, delta, fastfetch, and a four-pane HUD built
from the *Watch tools.

SIP stays enabled. Nothing here needs it disabled.

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
| `aerospace/` | tiling WM config — workspaces, keybinds, window rules |
| `sketchybar/` | the bar: `sketchybarrc`, `colors.sh`, `icons.sh`, `plugins/` |
| `launchd/` | LaunchAgent for the netwatch daemon that feeds the bar |
| `bin/hud` | four-pane dashboard |
| `bin/borders.sh` | JankyBorders launcher (magenta on focus) |
| `bin/rice-doctor` | health check for every layer; exits non-zero if one is down |
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
| `rice-doctor` | verify aerospace, borders, bar, netwatch feed, configs, secrets |

## Window management

`alt` is the tiling modifier throughout.

| Keys | Does |
|---|---|
| `alt` + `hjkl` / arrows | focus |
| `alt shift` + `hjkl` / arrows | move window |
| `alt` + `1`–`9` | switch workspace |
| `alt shift` + `1`–`9` | send window to workspace, follow it |
| `alt` + `-` / `=` | resize · `alt shift =` balances |
| `alt` + `/` `,` | tiles / accordion layout |
| `alt` + `f` | float this window · `alt shift f` fullscreen |
| `alt` + `tab` | back-and-forth |
| `alt shift` + `r` | resize mode (`hjkl`, `b` balance, `esc` out) |
| `alt shift` + `;` | service mode — `r` reset tree, `f` float, `esc` reload config |

Workspaces: 1 term · 2 code · 3 web · 4 chat · 5 notes · 6 infra.
Apps land there automatically via `on-window-detected` rules.

## The bar

The two right-hand items are fed by **netwatch's own daemon**, not by
`netstat` or `ping`. A LaunchAgent runs `netwatch daemon --metrics`, which
serves Prometheus on `127.0.0.1:9464`; `plugins/netwatch_lib.sh` scrapes it
with a 1.5s ceiling so a sick daemon can never stall the bar.

| Item | Source |
|---|---|
| `link` | `netwatch_gateway_rtt_seconds`, `dns_rtt`, `loss_ratio`, `connections` — colours on the worst signal, goes red on any loss |
| `net` | `netwatch_interface_{receive,transmit}_bytes_per_second` on the default route |
| `cpu` / `mem` | `top` one-shot · `memory_pressure` (free RAM is meaningless on macOS) |
| `disk` | `/System/Volumes/Data` — `/` is the sealed snapshot and always reads 4% |
| workspaces | AeroSpace, repainted by `exec-on-workspace-change` |

No sudo: the daemon does interface counters and probes, not packet capture.
Cost measured at 0.4% CPU / 15MB RSS.

## Notes

- Secrets live in `~/.config/secrets.zsh` (chmod 600), never in this repo.
- The menu bar is hidden now that SketchyBar replaces it. Undo with
  `defaults delete NSGlobalDomain _HIHideMenuBar`, or `macos/restore.sh`.
- **AeroSpace needs Accessibility permission granted by hand** on first run
  (System Settings ▸ Privacy & Security ▸ Accessibility). Until it is, the
  CLI reports "can't connect to AeroSpace server" even though the app is up,
  and the bar's workspace indicators stay hidden.
- SketchyBar and JankyBorders come from the `felixkratz/formulae` tap, which
  Homebrew requires you to `brew trust` before installing.
- tmux configs use literal hex; tmux has no shell variables.
- `bin/hud` uses named pane targets (`{left}`, `{top-right}`) because
  `pane-base-index` is 1.
