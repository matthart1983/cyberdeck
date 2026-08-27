<div align="center">

# CYBERDECK

**A cyberpunk rice of macOS and Fedora — tiling, bar, terminal, shell and a live system HUD.**

Cyberpunk Neon across AeroSpace/niri, SketchyBar/Waybar, Ghostty, zsh, tmux,
btop, bat, delta, fastfetch and Zed — from one palette, in one repo.

*SIP stays enabled. Nothing here asks you to disable it.*

![tour](capture/out/tour.gif)

**[📖 Read the Field Manual](https://matthart1983.github.io/cyberdeck/)** — every
key, command and surface in one searchable page.

</div>

---

## The HUD

`hud` tiles four terminal monitors into one screen — [soundwatch](https://github.com/matthart1983/soundwatch),
[netwatch](https://github.com/matthart1983/netwatch), [syswatch](https://github.com/matthart1983/syswatch)
and [diskwatch](https://github.com/matthart1983/diskwatch): audio, network, system and disk,
all themed from the same palette. Four panes, one author.

![hud](capture/out/hud.gif)

## The shell

![shell](capture/out/shell.gif)

---

## What makes this one different

Most bars shell out to `netstat` and `ping` for their network readout. This one
doesn't. It's fed by [netwatch](https://github.com/matthart1983/netwatch)'s own
headless daemon over a Prometheus endpoint, so the bar shows **gateway RTT, DNS
RTT, packet loss and live connection count** — diagnostics, not decoration. See
[The bar](#the-bar).

## The Field Manual

Everything this rice binds, in one page you can search: the tiling keys, the
bar's items and where each one gets its data, the Ghostty and tmux bindings,
the shell aliases, and how to undo any of it.

**→ [matthart1983.github.io/cyberdeck](https://matthart1983.github.io/cyberdeck/)**

It ships with the repo too, so it works offline and without GitHub:

```sh
open ~/.dotfiles/docs/cyberdeck-manual.html     # macOS
xdg-open ~/.dotfiles/docs/cyberdeck-manual.html # Fedora
```

## Requirements

A Nerd Font on either platform (the configs ask for JetBrainsMono Nerd Font).

### macOS

macOS 13+. Homebrew.

```sh
# window layer
brew install --cask nikitabobko/tap/aerospace
brew tap felixkratz/formulae
brew trust felixkratz/formulae      # Homebrew gates this tap; sketchybar and
brew install sketchybar borders     # borders are upstreamed by its author

# terminal + shell layer
brew install --cask ghostty font-jetbrains-mono-nerd-font
brew install eza bat fd fzf zoxide atuin git-delta ripgrep fastfetch btop tmux jq

# the HUD's four panes (optional — hud degrades to whatever is installed)
cargo install netwatch-tui syswatch diskwatch
# soundwatch must be built with `make`, not cargo: the binary needs a bound
# Info.plist for macOS to prompt for audio consent, or every sample is zero.
git clone https://github.com/matthart1983/soundwatch && cd soundwatch && make build
```

`netwatch` is also what feeds the bar's network items. Without it the bar still
works; those two items read `netwatch off`.

### Fedora

Fedora 42+. Everything below is in Fedora's own repos:

```sh
# window layer
sudo dnf install niri waybar swaybg fuzzel wl-clipboard brightnessctl

# terminal + shell layer
sudo dnf install zsh zsh-autosuggestions zsh-syntax-highlighting
sudo dnf install eza bat fd-find fzf zoxide atuin git-delta ripgrep \
                 fastfetch btop tmux jq python3-pillow

# or just run the lot, plus the Framework/power bits
~/.dotfiles/linux/packages.sh
```

Three things Fedora does not package, and `packages.sh` deliberately will not
install behind your back:

- **Ghostty** — not in the repos, not on Fedora's filtered Flathub. Only
  third-party COPRs carry it; pick one yourself. The rice runs in any terminal
  until you do; only `ghostty/config` goes unused.
- **powerlevel10k** — `git clone --depth=1 https://github.com/romkatv/powerlevel10k
  ~/.local/share/powerlevel10k`, then source it at the top of `~/.zshrc`.
- **JetBrainsMono Nerd Font** — drop the release zip in `~/.local/share/fonts`
  and run `fc-cache -f`.

`soundwatch` is macOS-only — it binds a CoreAudio tap. On Linux `hud` comes up
as a three-pane grid instead of four; the other three are the same cargo
installs.


## Install

```sh
git clone https://github.com/matthart1983/cyberdeck ~/.dotfiles
~/.dotfiles/install.sh
exec zsh
```

`install.sh` detects the platform, runs `common/install.sh`, then the matching
`macos/` or `linux/` half. It only symlinks and loads services — it is
idempotent and touches no system settings. Each platform's system layer is
separate and opt-in.

On Fedora that opt-in layer is `linux/packages.sh` (above). On macOS:

```sh
~/.dotfiles/macos/snapshot.sh    # record YOUR current state first — required
~/.dotfiles/macos/defaults.sh    # apply (refuses to run without a snapshot)
~/.dotfiles/macos/restore.sh     # undo, replaying the snapshot
```

The snapshot is machine-specific and deliberately not committed. `defaults.sh`
refuses to run until you have one, so the undo path can never be missing when
the apply path has run.

Then check your work:

```sh
rice-doctor      # every layer, exits non-zero if one is down
```

On macOS, **AeroSpace needs Accessibility permission granted by hand** the first
time (System Settings ▸ Privacy & Security ▸ Accessibility). Until it is, its
CLI reports "can't connect to AeroSpace server" even though the app is running,
and the bar's workspace indicators stay hidden. `rice-doctor` calls this out.

On Fedora there is no equivalent grant: log out, pick **niri** at the session
chooser, and it comes up with Waybar already running.

## Making it yours

This is one person's setup, published because the parts are worth stealing.
Fork it and edit `palette.sh` — it's the single source of truth, and every
themed surface mirrors it. The pieces are independent: take the bar without the
tiling, the HUD without either, or just the Ghostty theme.

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

The repo is split three ways: shared, `macos/`, `linux/`. Anything not under a
platform directory works identically on both.

| Path | What |
|---|---|
| `palette.sh` | the single source of truth, shared |
| `install.sh` | dispatcher — runs `common/` then the platform half |
| `common/install.sh` | the symlinks both platforms share |
| `ghostty/` | terminal config + `themes/cyberpunk-neon`, plus `platform-{macos,linux}.conf` |
| `zsh/cyberpunk.zsh` | aliases, tool init, p10k colour overrides |
| `tmux/tmux.conf` | neon status bar, vim nav, tpm plugins |
| `bat/` | `cyberpunk-neon.tmTheme` — also drives delta and fzf previews |
| `btop/themes/` | btop theme — btop is still themed, just not in the HUD |
| `fastfetch/` | config + ASCII logo |
| `aerospace/` | **macOS** tiling WM config — workspaces, keybinds, window rules |
| `sketchybar/` | **macOS** bar: `sketchybarrc`, `colors.sh`, `icons.sh`, `plugins/` |
| `launchd/` | **macOS** LaunchAgent for the netwatch daemon that feeds the bar |
| `macos/bin/rice-doctor` | the macOS half of the health check |
| `linux/niri/` | **Fedora** tiling compositor config — the AeroSpace counterpart |
| `linux/waybar/` | **Fedora** bar: `config.jsonc`, `style.css`, `scripts/` |
| `linux/systemd/` | **Fedora** user unit for the netwatch daemon |
| `linux/packages.sh` | **Fedora** package + firmware layer (opt-in, needs sudo) |
| `linux/bin/rice-doctor` | the Fedora half of the health check |
| `bin/hud` | four-pane dashboard |
| `bin/borders.sh` | **macOS** JankyBorders launcher (magenta on focus); on Fedora niri draws its own focus ring |
| `bin/rice-doctor` | health check for every layer; dispatches to the platform half |
| `bin/tmux-battery` | battery glyph for the status bar |
| `zed/themes/` | Zed theme — neon chrome, desaturated syntax |
| `atuin/themes/` | atuin (ctrl-R) theme |
| `bin/cc-statusline` | Claude Code statusline: model, dir, git, context |
| `bin/rice-capture` | render the demo tapes |
| `capture/` | VHS tapes; GIFs land in `capture/out/` (gitignored) |
| `wallpaper/generate.py` | wallpaper generator (PIL, no numpy) |
| `macos/` | defaults apply + snapshot + restore, plus the macOS install half |

## Commands

| Command | Does |
|---|---|
| `hud` | soundwatch + netwatch + syswatch + diskwatch in a tiled grid (`hud -r` rebuilds) |
| `fetch` | fastfetch with the CYBERDECK logo |
| `cmd + \`` | Ghostty quick-terminal dropdown |
| `prefix` = `C-a` | tmux prefix; `\|` and `-` split, `hjkl` navigate |
| `rice-doctor` | verify aerospace, borders, bar, netwatch feed, configs, secrets |
| `rice-capture` | render demo GIFs (`rice-capture hud` for just one) |
| `open`/`xdg-open docs/cyberdeck-manual.html` | the [field manual](https://matthart1983.github.io/cyberdeck/) — every key and command, searchable |

## Window management

`alt` is the tiling modifier on macOS; **`super` on Fedora**. That is the one
deliberate divergence in the whole port: on Linux `alt`+letter is the GTK
mnemonic accelerator, so binding it here would make every app's menu bar
unreachable. Everything below reads the same with the modifier swapped.

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
Apps land there automatically — `on-window-detected` rules on macOS,
`window-rule { open-on-workspace }` on Fedora.

Two keys mean something slightly different under niri, because it is a
*scrollable* tiler rather than a tree tiler: there is no tree to flatten and
no sizes to balance. `super /` cycles the preset column widths, `super ,`
toggles a tabbed column — niri's accordion. Both are annotated in
`linux/niri/config.kdl`.

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

On Fedora the same two items are Waybar custom modules reading the same
endpoint, with the daemon under `systemctl --user` instead of launchd. The
other four items shrink to nothing there: `cpu`, `mem`, `disk` and `battery`
each needed a shell plugin on macOS only because `top`, `memory_pressure` and
`pmset` have to be parsed. Waybar reads all four out of `/proc` and `/sys`
itself, so `linux/waybar/scripts/` holds just the two netwatch ones — which
was always the part worth having.

## Notes

- Secrets live in `~/.config/secrets.zsh` (chmod 600), never in this repo.
- **macOS:** the menu bar is hidden now that SketchyBar replaces it. Undo with
  `defaults delete NSGlobalDomain _HIHideMenuBar`, or `macos/restore.sh`.
- **Fedora:** nothing equivalent to hide. Waybar declares its own exclusive
  zone, so niri gets out of its way — unlike AeroSpace's `outer.top`, which
  has to be hand-counted to clear the menu bar plus the bar.
- **Framework 13:** `linux/packages.sh` also installs `power-profiles-daemon`
  and refreshes firmware through `fwupd` — Framework ships BIOS over LVFS, so
  `sudo fwupdmgr update` is the whole update path. `rice-doctor` checks both,
  plus that `/sys/power/mem_sleep` is on `s2idle`, which is what the AMD boards
  want. The battery enumerates as `BAT1`, not `BAT0`; `bin/tmux-battery` and
  the Waybar battery module both account for that.
- **AeroSpace needs Accessibility permission granted by hand** on first run
  (System Settings ▸ Privacy & Security ▸ Accessibility). Until it is, the
  CLI reports "can't connect to AeroSpace server" even though the app is up,
  and the bar's workspace indicators stay hidden.
- SketchyBar and JankyBorders come from the `felixkratz/formulae` tap, which
  Homebrew requires you to `brew trust` before installing.
- tmux configs use literal hex; tmux has no shell variables.
- `bin/hud` uses named pane targets (`{left}`, `{top-right}`) because
  `pane-base-index` is 1.

## App layer

Zed keeps the neon UI chrome but uses **desaturated syntax colours** — code is
read for hours, chrome is glanced at. Both palettes live in `palette.sh`.

Claude Code is set to the `dark-ansi` theme so it inherits the Ghostty ANSI
palette rather than duplicating it, plus a neon statusline from
`bin/cc-statusline`.

## Captures

`rice-capture` renders `capture/*.tape` through VHS into `capture/out/`.

Two things the tapes have to work around:

- VHS points `ZDOTDIR` at its own temp rc, so `~/.zshrc` never loads and none
  of the rice exists. Each tape re-execs into a real interactive shell first.
- `hud.tape` needs a canvas over 160x50 cells, because all four tools refuse
  to draw below 80x24 and each gets a quarter of the screen.

## License

MIT — see [LICENSE](LICENSE).
