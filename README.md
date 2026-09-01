<div align="center">

# CYBERDECK

**A cyberpunk rice of macOS and Fedora — tiling, bar, terminal, shell and a live system HUD.**

Cyberpunk Neon across AeroSpace/niri, SketchyBar/Waybar, Ghostty, zsh, tmux,
btop, bat, delta, fastfetch and Zed — from one palette, in one repo.

*SIP stays enabled. Nothing here asks you to disable it.*

![tour](capture/out/tour.gif)

**[📖 Read the Field Manual](https://matthart1983.github.io/cyberdeck/)** — every
key, command and surface in one searchable page, macOS and Fedora side by side.

[Where this is](#where-this-is) · [Where it's heading](#where-its-heading) · [ROADMAP.md](ROADMAP.md)

</div>

---

## Where this is

46 commits since 23 August, and it has been the daily driver throughout. Both
halves run: macOS 13+ on AeroSpace and SketchyBar, Fedora on niri and Waybar,
from one palette and one installer.

The parts I would call finished are the ones with tests behind them. The
palette engine renders 8 themes across 16 surfaces from 47 colour slots, and
`test/theme.sh` checks the contract, the drift and the contrast floors on every
one. The installer writes only on difference, and `test/idempotent.sh` runs the
real thing twice against a throwaway `$HOME` rather than asserting idempotence
in a comment. `rice-doctor` is 28 checks on Fedora, each failure carrying its
own remediation. The field manual is 1,497 lines and covers both platforms from
one page.

The honest gaps. **There is no CI** — both suites run by hand, and that is the
first item on the roadmap below. The Fedora half is ahead of the macOS half and
pulling further ahead, because Fedora is the machine I actually use. And the
four HUD tools live in their own repos, so this one is configuration rather
than the monitors themselves.

| | macOS | Fedora |
|---|---|---|
| tiling | AeroSpace | niri |
| bar | SketchyBar | Waybar |
| focus ring | JankyBorders | niri draws its own |
| dock | — | second bar, same Waybar process |
| volume in the bar | — | slider plus readout |
| power profile | — | speedometer beside the battery |
| launcher panel | — | fuzzel and nwg-drawer |
| Ghostty | prebuilt cask | built from upstream's signed tarball |
| system layer | `snapshot` / `defaults` / `restore` | `packages.sh`, opt-in |
| HUD · themes · zsh · tmux · manual · doctor | same | same |

Nothing in the macOS column is planned to close. niri's own focus ring and
Waybar's exclusive zone are better than what they replace, and macOS keeps
volume in its own menu bar, so those rows stay blank on purpose.

This is one person's setup, published because the parts are worth stealing, and
the pieces are independent. Take the bar without the tiling, the HUD without
either, or just the Ghostty theme.

## Where it's heading

An operations layer. A workstation for running infrastructure rather than one
that looks like it could. [`ROADMAP.md`](ROADMAP.md) is the whole plan, written
down before any of it is built, because the ordering is the part that matters.

The thesis is one sentence. What separates an operations workstation from a
terminal with `kubectl` installed is that it always knows, and always shows,
which cluster and which environment the next command lands on. So one resolver
writes one file, every surface subscribes, and the environment class drives an
accent overlay: point at production and the bar, the prompt, the tmux status
line and the focus ring all change colour together. An unmatched context
classifies as `unknown`, and `unknown` is styled like production, because the
classification is the safety property and its failure mode has to be caution.

Seven phases. **None of them are built yet** — no `ops/`, no CI, no extracted
libraries. This is a plan, not a changelog.

| Phase | Size | What it unlocks |
|---|---|---|
| 0 · Foundations | a weekend | CI, plus shared libraries for Prometheus scraping and doctor output. Turns phases 2 and 4 from scripting into configuration. |
| 1 · Context | 1–2 weeks | The spine. Phases 2, 3 and 5 are all consumers of it. |
| 2 · Kubernetes | 1–2 weeks | A cluster you read from the bar and drive from a HUD layout, with an advisory guardrail on destructive verbs. |
| 3 · Fleet SSH | 1–2 weeks | One inventory file driving the resolver, the SSH config, parallel exec and a per-host HUD. Parallelises with phase 2. |
| 4 · Observability | 1 week | Alerts and dashboards become a config file instead of new scripts. |
| 5 · Incident mode | 3–4 days | One command puts the machine into incident posture and hands you a timeline at the end. |
| 6 · Hardening | 1 week | `ops-doctor`, gitleaks in CI, and whatever ports to macOS cheaply. |

Kubernetes, fleet SSH and observability are in scope. Cloud CLIs, Terraform and
Ansible are out, not forever, just not first. It arrives as a fourth top-level
directory under the same rule as the other three: opt-in, idempotent, and
`install.sh` never calls it.

Sizes assume evenings and weekends.

## The HUD

`hud` tiles four terminal monitors into one screen — [soundwatch](https://github.com/matthart1983/soundwatch),
[netwatch](https://github.com/matthart1983/netwatch), [syswatch](https://github.com/matthart1983/syswatch)
and [diskwatch](https://github.com/matthart1983/diskwatch): audio, network, system and disk,
all themed from the same palette. Four panes, one author, both platforms —
soundwatch grew an ALSA backend and libpulse meters, so the CoreAudio tap is
one implementation behind its backend trait rather than the whole tool.

`C-a z` zooms the selected pane to the whole window and back — tmux's own
binding, left alone. Worth knowing because a pane in the grid is about 115×26,
which is why `hud` starts each tool in `--lite`; zoomed it is the full 232×53,
so `L` (or `V` in syswatch and diskwatch) gives you the full view instead of a
"terminal too small" line.

**Dense wants 130×44, and does not say so when it cannot have it.** Below 44
rows netwatch quietly draws two of its four boxes rather than refusing, which
reads as a broken render instead of a size problem. That is why anything in
this rice meant to reach dense is launched with a font size rather than the
configured 14: a maximised terminal on a 1920×1280 output is 168×38 at 14 —
wide enough and six rows short, so `V` could never get there however far you
zoomed. `hud` runs at 10 (232×53) and the bar's netwatch items open at 11
(211×48).

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

It documents both platforms from one page. The **macOS / Fedora** switch in the
sidebar (or `t`) swaps AeroSpace for niri, SketchyBar for Waybar, and `cmd` for
`ctrl+shift` — everything the two halves genuinely share is written once, and
the `/` filter only ever searches the platform you're on. Your choice is
remembered.

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
sudo dnf install niri waybar swaybg fuzzel nwg-drawer wl-clipboard brightnessctl

# terminal + shell layer
sudo dnf install zsh zsh-autosuggestions zsh-syntax-highlighting
sudo dnf install eza bat fd-find fzf zoxide atuin git-delta ripgrep \
                 fastfetch btop tmux jq python3-pillow

# the HUD's four panes (optional — hud degrades to whatever is installed)
cargo install netwatch-tui syswatch diskwatch
cargo install --git https://github.com/matthart1983/soundwatch

# or just run the lot, plus the Framework/power bits
~/.dotfiles/linux/packages.sh
```

Three things Fedora does not package, and `packages.sh` deliberately will not
install behind your back:

- **Ghostty** — not in the repos, not on Fedora's filtered Flathub, and the
  only prebuilt binaries are third-party COPRs. So the rice builds it from
  upstream's signed source tarball instead:

  ```sh
  ~/.dotfiles/linux/ghostty.sh
  ```

  Sudo, once, for the GTK build dependencies; Ghostty itself lands in
  `~/.local` and leaves no root-owned files. The tarball's minisign signature
  is checked before anything is unpacked, and the Zig version is read out of
  the source that was just verified — Fedora ships two Zig minors and only one
  of them can build Ghostty. Budget a few minutes for the compile. Until you
  run it the rice works in any terminal; only `ghostty/config` goes unused.
- **powerlevel10k** — `git clone --depth=1 https://github.com/romkatv/powerlevel10k
  ~/.local/share/powerlevel10k`, then source it at the top of `~/.zshrc`.
- **JetBrainsMono Nerd Font** — drop the release zip in `~/.local/share/fonts`
  and run `fc-cache -f`.

`soundwatch` is the one not on crates.io, hence the `--git`. It is a fourth
pane on Fedora too, and unlike on macOS there is nothing to sign: no
CoreAudio tap to bind and no consent to grant. Devices, streams, latency and
xruns all come out of `/proc/asound`, and only the meters want a library —
`libpulse`, dlopened at first use rather than linked, so a machine with no
sound server still runs the tool and names the part that is missing instead of
failing to start. On a Fedora desktop `pipewire-pulseaudio` already provides
it; `rice-doctor` reports that as its own line.


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

## Themes

Eight of them. One command moves all sixteen themed surfaces at once:

```sh
theme                 # what's active, and what else there is
theme blade           # tiling, bar, terminal, shell, tmux, editor, HUD, wallpaper
```

One command. It renders the sixteen surfaces, re-links them, reloads what can
be reloaded from outside, and tells you the two or three things that can't be —
Ghostty has no reload-from-CLI, and a shell's colours are fixed at start.

| Theme | Character |
|---|---|
| `cyberpunk-neon` | The rice as shipped. Cyan on navy, magenta accent. |
| `blood-dragon` | Hot pink on deep violet. Loudest of the eight. |
| `terminal-green` | Green phosphor, amber for bold. Closest to the metal. |
| `deep-sea` | Indigo hull, aqua readouts. Dark without the shouting. |
| `amber-crt` | One phosphor, one hue family. Red is the only outsider. |
| `ice` | Low chroma, cold whites. Instrumentation, not neon. |
| `blade` | Desaturated teal, rust accent. Built for eight-hour days. |
| `paper` | Warm off-white, ink foreground. The only light one. |

A palette is 47 colour slots of literal hex in `themes/<slug>.sh` — data, read
rather than sourced. Each themed surface is a `.tmpl` beside its output;
`theme` renders them. Nothing is mirrored by hand any more, which is the point:
eight themes across sixteen surfaces is 128 files that would drift with
nothing to catch it.

The rendered surfaces are tracked, so `theme blade && git diff` shows you
every surface that moved. Which theme you run is not: `themes/active.sh` is a
gitignored symlink, and a fresh clone falls back to the default.

**Full contract, and the two rules that matter — [`themes/README.md`](themes/README.md).**

## Palette

The default. `themes/cyberpunk-neon.sh` is the whole of it; `palette.sh` now
points at whichever theme is active, for the scripts that can read a shell
variable. The surfaces cannot, which is why they are rendered instead.

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

The repo is split three ways: `common/`, `macos/`, `linux/`. Every path under
`common/` works identically on both platforms; the two platform directories
mirror each other, and each holds its own `install.sh` and `bin/rice-doctor`.

| Path | What |
|---|---|
| `palette.sh` | points at the active theme — what scripts source |
| **`themes/`** | |
| `themes/<slug>.sh` | one palette per theme: 47 slots of literal hex, no logic |
| `themes/README.md` | the slot contract, the contrast floors, and how to add one |
| `themes/active.sh` | gitignored symlink to whichever is in use |
| `install.sh` | dispatcher — runs `common/` then the platform half |
| `test/idempotent.sh` | runs the installer twice against a throwaway `$HOME` and fails if the second run writes anything |
| `test/theme.sh` | renders all 8 themes across all 16 surfaces and checks the contract, the drift and the contrast floors |
| **`common/`** | |
| `common/install.sh` | the symlinks and settings both platforms share |
| `common/lib.sh` | `link` / `copy` / `render` / `seed` — the helpers that make a re-run a no-op |
| `common/lib-path.sh` | the three bin dirs the rice adds to PATH — sourced by the shell, `hud` and the dock |
| `common/ghostty/` | terminal config + `themes/cyberdeck`, plus `platform-{macos,linux}.conf` |
| `common/zsh/cyberpunk.zsh` | aliases, tool init, PATH, p10k colour overrides |
| `common/tmux/tmux.conf` | neon status bar, vim nav, tpm plugins |
| `common/bat/` | `cyberdeck.tmTheme` — also drives delta and fzf previews |
| `common/btop/themes/` | btop theme — btop is still themed, just not in the HUD |
| `common/syswatch/` | one line, seeded once: `theme = "terminal"`, so the HUD's middle pane matches the other two |
| `common/netwatch/` | the same one line, for a worse symptom — netwatch's own palette draws graph lows in hardcoded truecolor at 1.02:1 |
| `common/fastfetch/` | config + ASCII logo |
| `common/zed/themes/` | Zed theme — neon chrome, desaturated syntax |
| `common/atuin/themes/` | atuin (ctrl-R) theme |
| `common/bin/theme` | the switcher — renders every themed surface from one palette |
| `common/bin/theme-render` | expands one `.tmpl` against one palette; four colour notations |
| `common/claude-settings.py` | patches Claude Code's theme + statusline, leaving your other settings alone |
| `common/zed-settings.py` | selects the Zed theme in `settings.json`, preserving its comments |
| `common/bin/hud` | four-pane dashboard |
| `common/bin/rice-doctor` | health check; dispatches to the platform half |
| `common/bin/cc-statusline` | Claude Code statusline: model, dir, git, context |
| `common/bin/tmux-battery` | battery glyph for the status bar |
| `common/bin/rice-capture` | render the demo tapes |
| **`macos/`** | |
| `macos/install.sh` | the macOS half — links, LaunchAgent, sketchybar |
| `macos/aerospace/` | tiling WM config — workspaces, keybinds, window rules |
| `macos/sketchybar/` | the bar: `sketchybarrc`, `colors.sh`, `icons.sh`, `plugins/` |
| `macos/launchd/` | LaunchAgent for the netwatch daemon that feeds the bar |
| `macos/bin/borders.sh` | JankyBorders launcher (magenta on focus) |
| `macos/bin/rice-doctor` | the macOS half of the health check |
| `macos/defaults.sh` | system settings apply + `snapshot.sh` / `restore.sh` |
| **`linux/`** | |
| `linux/install.sh` | the Fedora half — links, systemd unit, wallpaper |
| `linux/niri/` | tiling compositor config — the AeroSpace counterpart |
| `linux/waybar/` | the bar: `config.jsonc`, `style.css`, `scripts/` |
| `linux/nwg-drawer/` | the launcher panel's stylesheet — a themed surface like the bar's |
| `linux/systemd/` | user unit for the netwatch daemon, and the session's PATH (`environment.d/`) |
| `linux/packages.sh` | package + firmware layer (opt-in, needs sudo) |
| `linux/ghostty.sh` | builds Ghostty from upstream's signed tarball into `~/.local` (opt-in) |
| `linux/bin/rice-doctor` | the Fedora half of the health check |
| `linux/bin/drawer` | sizes the launcher panel to the focused output and toggles it |
| `linux/bin/dock` | the dock's slot table — resolves each one, focuses or launches it |
| `linux/bin/power` | the bar's power-profile item — probe, picker, and the doctor's line |
| `linux/bin/wifi` | the bar's Wi-Fi item — probe, network picker, radio toggle, doctor line |
| `linux/dock-icons/` | `generate.py` draws a palette tile for each slot with no real icon; `fetch` pulls the ones published upstream |
| `linux/vscode.sh` | the editor slot's IDE: VSCodium from Flathub, or VS Code from Microsoft's repo (opt-in) |
| **root** | |
| `capture/` | VHS tapes; GIFs land in `capture/out/` (gitignored) |
| `wallpaper/generate.py` | wallpaper generator (PIL, no numpy) |
| `attic/` | anything the installer displaced, under a per-run timestamp (gitignored) |

niri draws its own focus ring, so JankyBorders has no Linux counterpart —
that is one fewer daemon on the Fedora side, not a missing feature.

## Re-running the install

`install.sh` is idempotent, and that is tested rather than asserted:

```sh
test/idempotent.sh
```

It runs the real installer twice against a throwaway `$HOME` — with systemd,
launchd, brew and the bar stubbed out so a test can never bounce the live
daemon — and fails unless the second run reports zero writes *and* leaves a
byte-identical tree. Three fixtures: a fresh machine, one whose `~/.config`
already holds real directories where the rice wants symlinks, and one still on
the pre-restructure layout.

The themes have their own:

```sh
test/theme.sh
```

Eight palettes across sixteen surfaces is 128 renders nobody is going to check
by eye. It proves each palette actually *sets* its variables (a space before the
`=` makes it a command, which `bash -n` passes and which sets nothing), that
every palette fills the same contract in the same order, that every surface
renders with no unknown placeholder and no literal colour left behind, that the
tracked surfaces are exactly what the templates produce, that switching through
all eight themes and back restores the tree byte for byte, and that every slot
carrying text clears its contrast floor.

Nothing is ever overwritten in place. Whatever the installer displaces is moved
to `attic/<timestamp>/`, mirroring its path under `$HOME`.

## Commands

| Command | Does |
|---|---|
| `hud` | soundwatch + netwatch + syswatch + diskwatch in a tiled grid (`hud -r` rebuilds) |
| `fetch` | fastfetch with the CYBERDECK logo |
| `cmd + \`` | Ghostty quick-terminal dropdown |
| `prefix` = `C-a` | tmux prefix; `\|` and `-` split, `hjkl` navigate |
| `dock list` | Linux: every dock slot and what it resolved to here (`dock check` for drift) |
| `pkill -USR2 waybar` | reload both bars — what makes a newly installed app's dock icon appear |
| `rice-doctor` | verify aerospace, borders, bar, netwatch feed, configs, secrets |
| `rice-capture` | render demo GIFs (`rice-capture hud` for just one) |
| `theme [slug]` | show or switch the palette — renders, re-links and reloads in one |
| `cc-theme [value]` | show or switch Claude Code's theme — `custom:cyberdeck` is the palette's own; `cc-theme --all` walks them |
| `open`/`xdg-open docs/cyberdeck-manual.html` | the [field manual](https://matthart1983.github.io/cyberdeck/) — every key and command for both platforms, searchable |

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
| `wifi` | `nmcli` — SSID and signal, click to pick a network (Fedora only) |
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

The Fedora bar has one thing macOS's does not: **volume**, as two items that
read as one — a `pulseaudio/slider` you drag or click a position on, and a
`wireplumber` readout beside it carrying the level and the mute state. Click
the readout to mute, right-click it for soundwatch, the same idiom as cpu and
mem opening btop.

The slider is there because **scrolling a bar item is a mouse-wheel gesture and
this is a laptop.** The obvious build is scroll-to-set — that is what every
waybar config does — and on this machine the module never saw a scroll event at
all, which left the volume readable and mutable from the bar and not settable,
which is the one thing a volume control is for. Clicking a position is a
gesture a trackpad is good at. The scroll handlers stay configured for a mouse,
and they run the identical `wpctl` the Framework's F1–F3 run, so the bar and
the keyboard cannot disagree about what a notch is worth.

There is no macOS counterpart because macOS keeps volume in its own menu bar.

It also has a **Wi-Fi** item, leftmost of the network cluster, because it is
the question the two items beside it assume an answer to. They could already
say a great deal about the link and nothing at all about *which* network: "why
is this slow" was one click away, and "join the other access point" meant a
terminal. Click it for a picker of everything in range — signal, a padlock on
the secured ones, markers for the current and the saved — plus rows to
disconnect or switch the radio off. Right-click toggles the radio.

`linux/bin/wifi` drives `nmcli` rather than NetworkManager's D-Bus API, which
is a deliberate difference from the power item next door. Setting a power
profile is one property and a `busctl set-property`. Joining a network is scan,
match, secrets agent, activate, then wait for the state to settle — and nmcli
is NetworkManager's own client for exactly that sequence. Reimplementing it
over raw D-Bus in bash would be a worse copy of it. Nothing needs polkit:
`nmcli general permissions` already grants `wifi.scan`, `network-control`,
`settings.modify.own` and `enable-disable-wifi`.

A saved network activates its existing profile rather than being asked for a
password NetworkManager already holds — otherwise you end up with two profiles
for one network. An open one connects with no prompt. A secured one gets a
`fuzzel --password` box. **802.1X is refused rather than attempted**: enterprise
networks need certificates, an identity and sometimes an inner method, none of
which fit in a one-line password box, and pretending otherwise leaves you with
a profile that silently never connects. It says so and points at
`nm-connection-editor`.

It also has a **power profile** item, immediately left of the battery, because
that is the knob for the gauge beside it — the one control on the bar that
changes how fast the number to its right goes down. A speedometer in three
positions: green needle-left for power saver, white for balanced, orange
needle-right for performance. Click it for the picker, right-click to go back
to balanced.

This is not the `custom/power` button at the far right, which is the **session**
menu — lock, log out, power off. Same word, different question, and putting
them in one popup would mean "Power saver" and "Power off" two rows apart.

`linux/bin/power` is the whole of it, and it talks D-Bus to
`net.hadess.PowerProfiles` rather than running `tuned-adm`. Fedora 41 moved the
desktop from power-profiles-daemon to tuned-ppd, which exists to serve exactly
that interface — it is what GNOME's own switcher talks to — so the item keeps
working if the daemon underneath is swapped back, and it reads the profile list
off the bus instead of hard-coding three names tuned spells differently anyway
(`power-saver` is tuned's `powersave`; `performance` is
`throughput-performance`). Setting the profile needs no polkit authorisation,
so a click can just do it.

Verified on this machine that one property moves all four knobs together: the
tuned profile, the ACPI `platform_profile` the firmware reads, the cpufreq
governor, and the `energy_performance_preference`.

It polls at 30s, not the display item's 5s. The profile changes when someone
changes it, and the click that changes it pokes `SIGRTMIN+9` so the item is
right immediately; the interval is only there to notice a profile set from
somewhere else. A bar that wakes to spawn a probe every five seconds is the
thing this item exists to help with.

## The dock

Fedora only, and a second bar out of the same Waybar process — `config.jsonc`
is an array, so one reload and one stylesheet move both.

There were already two launchers, answering two different questions: fuzzel
(`Mod+Space`) for when you can name the thing, the app panel (`Mod+A`) for when
you can't. The dock is the third question — the handful you open every day,
where naming and browsing are both slower than a target that is always in the
same place. Applications left of the divider, the terminal toolbelt right of
it; hover them and they answer magenta and blue respectively.

| Slot | Resolves to, in order |
|---|---|
| term · editor · browser | ghostty · zed → code → rustrover → nvim · chrome → brave → firefox |
| claude · notes · chat · files | claude-desktop → `claude` in a terminal · obsidian · slack → discord → whatsapp · nautilus → thunar → dolphin |
| hud · git · containers | the HUD · lazygit → tig · lazydocker → ctop |
| k8s · net | k9s · wireshark → termshark |

The list lives in `linux/bin/dock`, and **a slot that resolves nothing is not
drawn**: the dock is exactly as wide as the software this machine actually has
and grows an icon the day you install the next thing. `dock list` shows what
resolved, `dock check` reports drift between that table and the bar, and
`rice-doctor` reports both. Clicking focuses a window that is already open —
cycling, if there is more than one — before it starts a second copy.

The icons are **real application icons**, not a font. Each slot resolves its
app's own `.desktop` file, reads the `Icon=` key and puts it through the GTK
icon theme, so the dock shows exactly what every other launcher on the machine
shows for that app — and installing something new gets its real icon with no
edit anywhere. That is why these are waybar `image` modules rather than
`custom` ones: a custom module can only return text.

The terminal toolbelt cannot work that way. There is no icon on the machine for
lazygit, k9s or the HUD, because none of those projects ship one, and Adwaita's
generic stand-ins are its old 48px legacy set — sitting those beside Ghostty's
and VS Code's current icons reads as four icons and five mistakes. Those slots
get a drawn tile instead: `linux/dock-icons/generate.py` renders a rounded
outline and a short monogram from the active palette, so they move with `theme`
like every other surface. A terminal-hosted slot never falls back to `argv[0]`'s
icon, which matters more than it sounds: `argv[0]` is `ghostty` for every one of
them, so that fallback would quietly give the HUD, git, k8s and containers the
same terminal icon.

Two slots sit outside both paths. Claude Code installs a binary and a URL
handler and **no icon at all** — its `.desktop` file has no `Icon=` key to read.
So there is a third layer: anything in
`~/.local/share/cyberdeck/dock-icons/real/` wins over a drawn tile, the
generator never writes there, and `linux/dock-icons/fetch` pulls the published
mark into it. That is opt-in and not called by `install.sh`, which is offline
and idempotent and should stay both; a public dotfiles repo is also the wrong
place to redistribute someone's trademark. Drop your own PNG in that directory
to override any slot.

The dock **fully disappears**, and comes back when the pointer reaches anywhere
along the bottom edge. At rest nothing is drawn: no icons, no plate, no
chevron.

Two nested groups do it. `dockzone` is what the pointer has to reach and paints
nothing; the stylesheet gives it 500px of padding either side, and padding is
inside the widget, so its event box covers all of it — roughly 1300px of bottom
edge that reveals the dock. `dockrow` sits inside and is the visible plate,
only as wide as the icons. Nothing changes size when the pointer arrives; only
opacity does.

Which node can listen at all is the fiddly part, and it cost three attempts.
CSS `:hover` is GTK's PRELIGHT flag, set from pointer crossing events, which
need a `GdkWindow`. Every waybar module has one, a group included, because
waybar wraps each in a `GtkEventBox`. The bar's layer-shell window and the
plain `GtkBox`es it packs — `.modules-left`, `.modules-center`,
`.modules-right` — do not, so `window#waybar.dock:hover` and
`.modules-center:hover` match nothing and the dock never appears. Expanding
pads either side failed differently: waybar packs `.modules-center` at its
natural size, so `expand` has no leftover space to take.

Two more things had to go, and both were bugs you could feel. A drawer reveals
on its own hover, so its first child is the trigger — which meant making that
child wide and then collapsing it on hover to keep the icons centred. Collapsing
the thing the pointer is standing on is unstable: hover near its edge and it
shrinks out from under you, the pointer is no longer over it, and the dock
flickers. And the bar carried `margin-bottom`, which shortens the *surface*, so
the last few pixels of the screen were not the dock at all — running the pointer
to the physical edge, which is exactly how anyone reaches for a dock, took it
off and shut it again. The gap is padding inside the surface now.

**The dock is not exclusive**, so windows use the space it sits in. That is a
change of mind — reserving 68px along the bottom of every output to display
nothing is a strip of screen you paid for and never see. The cost is real and
worth knowing: a layer-shell surface takes pointer input across its whole area
whether or not it painted anything there, and waybar cannot shape that region,
so while the dock is invisible it still swallows clicks in the band it
occupies. The band *is* the surface, which is why the bar's height came down to
46 — it is now only as tall as the icons need. `Mod+D` takes it away entirely
when even that is in the way, and that works because `on-sigusr1` is a
**per-bar** parameter, so one `pkill -USR1 waybar` reaches the dock (`toggle`)
and not the status bar (`noop`) — which is also why the dock still does not
need to be a second waybar process.

The separator is the last glyph down there, and it is set in **JetBrainsMono
Nerd Font Propo** rather than the family the rest of the bar uses. Nerd Fonts ship three families: the default gives a glyph a
single-cell advance with double-width ink, so GTK lays out on 16.2px while the
glyph paints 21–25px and it overflows its own box to the right. Propo widens
the cell to the ink instead. The slots used to need this too, and no longer do,
because they are images.

Everything right of the divider runs in a terminal, and each of those gets its
own GTK app-id — `ghostty --class=com.mitchellh.ghostty-<slot>`, derived from
the slot name so the flag and the window rule cannot drift apart. Two things
depend on it, and both look like a dead button without it. niri files every
plain `com.mitchellh.ghostty` window on the `term` workspace, so a tool you
opened by clicking would appear somewhere you are not looking; and an
un-addressable window means the second click starts a second one, which for the
HUD is worse than nothing — both terminals attach to the same tmux session, and
tmux clamps a shared session to its smallest client.

One number in there is load-bearing: the HUD opens at `--font-size=10`, not the
configured 14. netwatch, syswatch and diskwatch each refuse to draw below
80×24, and `hud` tiles three of them into one window. A maximised column on a
1920×1280 output is 168×38 cells at 14 — 83×18 per pane, and all three print an
apology instead of a graph. At 10 it is 232×52, and every pane clears the floor.

## Notes

- **`ctrl+c` copies and still interrupts.** Ghostty's `performable:` prefix
  consumes a bind only if its action did something, and `copy_to_clipboard`
  does nothing without a selection — so `ctrl+c` copies when text is selected
  and sends SIGINT when it is not. `ctrl+v` pastes. `ctrl+shift+c/v` stay
  bound. `ctrl+a`, `ctrl+w` and `ctrl+t` are deliberately untouched: the first
  is the tmux prefix and readline's beginning-of-line, the second is
  delete-word, the third is transpose-chars and fzf's file widget.
- Secrets live in `~/.config/secrets.zsh` (chmod 600), never in this repo.
- **The HUD's palette** arrives through the terminal, not through a config each
  tool ships — but only diskwatch gets that for free. Both syswatch and
  netwatch default to a palette of their own, and `install.sh` seeds
  `theme = "terminal"` for each. syswatch's own palette is merely a different
  one: greens where the rest of the grid is cyan. netwatch's is worse — it
  draws the low end of every graph in **hardcoded truecolor**, `rgb(0,66,0)`
  and `rgb(0,0,69)`, which measure 1.67:1 and 1.02:1 against these
  backgrounds. The second is not dim, it is invisible, so the traffic graphs
  read as half-missing. `terminal` drops the hardcoded RGB entirely.
  **Seeded, not linked**, because both tools write that file back when you
  change a setting in their own UI, and a symlink would put those writes in
  this repo. `rice-doctor` reports what each file actually says rather than
  what was installed.
- **macOS:** the menu bar is hidden now that SketchyBar replaces it. Undo with
  `defaults delete NSGlobalDomain _HIHideMenuBar`, or `macos/restore.sh`.
- **Fedora:** nothing equivalent to hide. Waybar declares its own exclusive
  zone, so niri gets out of its way — unlike AeroSpace's `outer.top`, which
  has to be hand-counted to clear the menu bar plus the bar. Both bars do,
  including the dock along the bottom.
- **Fedora:** Firefox reports `org.mozilla.firefox` as its Wayland app-id, not
  `firefox` — the bare name is the X11 `WM_CLASS`. The `open-on-workspace "web"`
  rule matched only the latter, so Firefox had been opening wherever you were
  standing rather than on `web`. Both are matched now.
- **Fedora, the session PATH:** niri runs under `systemd --user`, whose PATH is
  `/usr/local/bin:/usr/bin`. Everything the compositor spawns inherits it — and
  because Ghostty is single-instance, that one process is what runs every
  `ghostty -e <tool>` on the machine. So `ghostty -e btop` works and
  `ghostty -e hud` opens a window that dies, with nothing anywhere to say why.
  `linux/systemd/environment.d/cyberdeck.conf` is the fix, and it is read at
  login: `rice-doctor` checks the running compositor rather than trusting that
  linking the file was enough.
- **Framework 13:** `linux/packages.sh` also installs `power-profiles-daemon`
  and refreshes firmware through `fwupd` — Framework ships BIOS over LVFS, so
  `sudo fwupdmgr update` is the whole update path. `rice-doctor` checks both,
  plus that `/sys/power/mem_sleep` is on `s2idle`, which is what the AMD boards
  want. The battery enumerates as `BAT1`, not `BAT0`; `bin/tmux-battery` and
  the Waybar battery module both account for that.
- **Fingerprint** — the Framework's Goodix reader needs nothing built or
  patched. Fedora ships `fprintd`, and `authselect enable-feature
  with-fingerprint` puts `pam_fprintd` in `system-auth` as `sufficient`;
  `/etc/pam.d/swaylock` is `auth include login` and `login` substacks
  `system-auth`, so **the lock screen and `sudo` both take a print with no
  config of their own**. The one step nothing can do for you is enrolling:

  ```sh
  fprintd-enroll              # touch the reader until it stops asking
  fprintd-enroll -f right-middle-finger    # a second finger is worth having
  ```

  `rice-doctor` checks all three links in that chain separately, because "the
  fingerprint doesn't work" is almost always zero fingers enrolled rather than
  anything wrong with PAM.
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
read for hours, chrome is glanced at. Both halves are in every palette: the
chrome slots, and the thirteen `CP_SOFT_*` ones that only syntax uses. The
installer selects the theme in Zed's `settings.json` too — linking the file
only puts it in Zed's picker.

Claude Code is set to the `dark-ansi` theme so it inherits the Ghostty ANSI
palette rather than duplicating it, plus a neon statusline from
`common/bin/cc-statusline`. That is also why every palette authors a full ANSI
bright half: `theme blade` has to move Claude Code with everything else, and it
only ever sees the terminal's sixteen colours.

## Captures

`rice-capture` renders `capture/*.tape` through VHS into `capture/out/`.

Two things the tapes have to work around:

- VHS points `ZDOTDIR` at its own temp rc, so `~/.zshrc` never loads and none
  of the rice exists. Each tape re-execs into a real interactive shell first.
- `hud.tape` needs a canvas over 160x50 cells, because all four tools refuse
  to draw below 80x24 and each gets a quarter of the screen.

## License

MIT — see [LICENSE](LICENSE).
