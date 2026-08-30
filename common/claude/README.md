# Claude Code

Claude Code's theme is a key in `~/.claude/settings.json`, which is **its** file,
not one this repo links over. The rice owns two keys in it — `theme` and
`statusLine` — and `common/claude-settings.py` patches exactly those two and
leaves the rest of your preferences alone.

```sh
cc-theme                    # what's active, and what else there is
cc-theme dark               # switch
cc-theme custom:cyberdeck   # the rice's own, rendered from the palette
cc-theme next | prev        # step through them
cc-theme demo               # the swatch board
cc-theme --all              # walk them all, demo each, then put it back
cc-theme --check            # settings.json and themes/claude-theme agree
```

## The seven

Claude Code's own labels, lifted from its binary rather than paraphrased. The
list lives in `themes.psv`, which `cc-theme` and `claude-settings.py` both read,
so a theme Claude Code adds later is one line and nothing else.

| Value | Label | Character |
|---|---|---|
| `auto` | Auto (match terminal) | Dark or light, decided from the terminal's reported background at startup. |
| `dark` | Dark mode | Fixed RGB. Ignores the palette entirely. |
| `light` | Light mode | Fixed RGB on a light ground. |
| `dark-daltonized` | Dark mode (colorblind-friendly) | Diffs move off red/green onto blue/orange. |
| `light-daltonized` | Light mode (colorblind-friendly) | The same reassignment, light ground. |
| `dark-ansi` | Dark mode (ANSI colors only) | **The default here.** Defers to the terminal's sixteen — so, this palette. |
| `light-ansi` | Light mode (ANSI colors only) | The same deference, light ground. |

`dark-ansi` is the rice default for one reason: it is the only family that
inherits the palette. The other five ship fixed colours and will sit at odds
with every other surface the moment you run `theme blade`. Switching to one is
a deliberate choice to leave the rice's colours behind in that one window.

## Why the choice is a file

Which Claude Code theme you run is a property of your machine, exactly as
`themes/active.sh` is — so it lives in `themes/claude-theme`, one line, gitignored.

That file is not a convenience. `theme <slug>` runs `install.sh`, and
`install.sh` writes Claude Code's settings; before this existed, the theme was
hardcoded to `dark-ansi` there, so **switching palettes silently reverted
whatever Claude Code theme you had chosen.** `install.sh` now reads
`themes/claude-theme` and passes it through, and `cc-theme --check` tells you if
the two ever drift apart.

A fresh clone has no such file and gets `dark-ansi`, so nothing has to exist for
this to work.

## The demo has two halves, and only one of them is here

`cc-theme demo` draws the terminal's sixteen colours. For `dark-ansi` and
`light-ansi` that is not a stand-in — Claude Code asks the terminal for those
colours and the terminal answers with this palette, so the swatch board *is* the
theme.

For the other five it is only context. Claude Code paints its own chrome from
fixed RGB, and no process outside it can reproduce that. So the second half is
`demo.md`: open it inside Claude Code after switching and look at the diff block,
the syntax highlighting and the blockquote. Diffs are where the seven diverge
most, and the entire reason the two colourblind-friendly ones exist.

## `custom:cyberdeck` — the fifteenth surface

Claude Code reads user-defined themes as loose `.json` files in
`~/.claude/themes/`, and selects one with `"theme": "custom:<slug>"`. So
`cyberdeck.json` is rendered from `theme.json.tmpl` like every other surface,
linked into `~/.claude/themes/`, and `theme blade` moves it with the rest.

The file it renders to is the shape Claude Code expects:

```json
{ "name": "Cyberdeck — Blade", "base": "dark", "overrides": { "text": "#a8c4c0" } }
```

- **`base`** is the built-in theme the overrides sit on top of, and comes from
  `CP_THEME_BASE` — `light` for Paper, `dark` for the other seven. A slot you do
  not override falls through to it, so getting this wrong is what would make
  Paper unreadable.
- **`overrides`** fills all seventy-two slots, so nothing falls through in
  practice. A key Claude Code does not know is dropped in silence rather than
  refused, which is the failure this repo is least able to see — so the whole
  set was taken from the shipped binary's own theme table rather than guessed.
- **Colours** may be `#rrggbb`, `#rgb`, `rgb(r, g, b)`, `ansi256(n)` or
  `ansi:<name>`. The template emits `#rrggbb` via the `_RAW` form, which is also
  why no literal colour appears in it.

### What maps to what

Most of it is the obvious thing — `text` is `CP_FG`, `error` is `CP_RED`,
`success` is `CP_GREEN`, the eight subagent colours are the accent half, the
shimmer slots are the bright half. Two decisions are not obvious:

**Diffs needed six new palette slots.** Claude Code fills whole lines, which no
other surface does: an added-line background is `CP_GREEN` sunk most of the way
into `CP_BG`, and nothing in the accent half is that colour. `CP_DIFF_ADD_BG`
and its five siblings were derived once and are now authored per theme, exactly
as the bright half is. See `themes/README.md`.

**Claude's own colours are themed too.** `claude`, `clawd_body` and
`briefLabelClaude` are Anthropic's orange by default; here they follow
`CP_ORANGE`. That is a deliberate rice choice, not an oversight — delete those
three lines from `theme.json.tmpl` and re-render if you would rather Claude kept
its own colour in your terminal.

### Switching between it and the built-ins

`cc-theme` lists whatever is in `~/.claude/themes/`, not just what this repo
ships, so a `.json` you drop in there yourself appears alongside `custom:cyberdeck`
and can be selected the same way.
