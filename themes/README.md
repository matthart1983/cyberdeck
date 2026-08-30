# Themes

Eight palettes, one contract, sixteen surfaces rendered from it.

```sh
theme                 # what's active, and what else there is
theme blade           # switch — that's the whole command
```

`theme <slug>` renders all sixteen surfaces, runs `install.sh` to re-link them,
reloads everything that can be reloaded from outside (the bar, tmux, the
wallpaper), and then names the two or three things that genuinely cannot be —
Ghostty has no reload-from-CLI, and a shell's exported colours are fixed when it
starts. niri watches its own config file and Zed watches its themes directory,
so both have already caught up by the time it prints.

Add `--render-only` to rewrite the files and stop.

Claude Code is the fifteenth surface, and the only one whose file this repo
does not own: `common/claude/cyberdeck.json` is rendered here and linked into
`~/.claude/themes/`, and `cc-theme` is what points Claude Code at it. See
`common/claude/README.md`.

| Theme | Slug | Character |
|---|---|---|
| Cyberpunk Neon | `cyberpunk-neon` | The rice as shipped. Cyan on navy, magenta accent. |
| Blood Dragon | `blood-dragon` | Hot pink on deep violet. Loudest of the eight. |
| Terminal Green | `terminal-green` | Green phosphor, amber for bold. Closest to the metal. |
| Deep Sea | `deep-sea` | Indigo hull, aqua readouts. Dark without the shouting. |
| Amber CRT | `amber-crt` | One phosphor, one hue family. Red is the only outsider. |
| Ice | `ice` | Low chroma, cold whites. Instrumentation, not neon. |
| Blade | `blade` | Desaturated teal, rust accent. Built for eight-hour days. |
| Paper | `paper` | Warm off-white, ink foreground. The only light one. |

## How it works

A palette is **data**: 47 slots, each a literal `#rrggbb`, plus four metadata
lines. Nothing in it is computed and nothing is executed — `theme` reads these
files, it does not source them, so pointing it at a palette someone sent you
cannot run anything.

Each themed surface is a `.tmpl` beside its output, holding `__CP_SLOT__`
placeholders. `theme <slug>` renders all sixteen. Four forms per slot, because
the surfaces do not agree on how to write a colour and none of them is going to
start:

| Placeholder | Expands to | Used by |
|---|---|---|
| `__CP_FG__` | `#0abdc6` | most things |
| `__CP_FG_RAW__` | `0abdc6` | SketchyBar's `0xAARRGGBB`, and `#rrggbbaa` |
| `__CP_FG_RGB__` | `10, 189, 198` | CSS `rgb()` / `rgba()` |
| `__CP_FG_SEMI__` | `10;189;198` | ANSI truecolor — `EZA_COLORS` |

An unknown placeholder is an error, not a passthrough: a surviving
`__CP_TYPO__` in a rendered config is a colour that silently never applies.

The rendered surfaces are **tracked**. That is deliberate — `theme blade &&
git diff` shows you every surface that moved, and the repo stays something you
can read and steal one file out of. Which theme you run is not tracked:
`themes/active.sh` is a gitignored symlink.

## The slots

### Surfaces (8)
`CP_BG` `CP_BG_ALT` `CP_BG_SUNK` `CP_BG_SEL` `CP_BG_HI` `CP_LINE` `CP_BLACK` `CP_VOID`

### Text (4)
`CP_FG` `CP_FG_DIM` `CP_WHITE` `CP_FG_STRONG`

### Accents (8)
`CP_MAGENTA` `CP_PURPLE` `CP_PURPLE_MID` `CP_BLUE` `CP_ORANGE` `CP_RED` `CP_YELLOW` `CP_GREEN`

### ANSI bright half (8)
`CP_BR_BLACK` `CP_BR_RED` `CP_BR_GREEN` `CP_BR_YELLOW` `CP_BR_BLUE` `CP_BR_MAGENTA` `CP_BR_CYAN` `CP_BR_WHITE`

No formula reproduces a bright set someone chose — I tried fitting one to
Cyberpunk Neon's eight and no single lighten curve comes close. So they are
authored, per theme, like everything else.

### Soft half (13)
`CP_SOFT_FG` `CP_SOFT_DIM` `CP_SOFT_COMMENT` `CP_SOFT_WHITE` `CP_SOFT_MAGENTA`
`CP_SOFT_PURPLE` `CP_SOFT_GREEN` `CP_SOFT_TEAL` `CP_SOFT_ORANGE` `CP_SOFT_YELLOW`
`CP_SOFT_CYAN` `CP_SOFT_RED` `CP_SOFT_BLUE`

Syntax highlighting only. Chrome is glanced at; code is read for hours, and
full-saturation magenta on black is exhausting at that duration.

### Diff (6)
`CP_DIFF_ADD_BG` `CP_DIFF_DEL_BG` `CP_DIFF_ADD_BG_DIM` `CP_DIFF_DEL_BG_DIM`
`CP_DIFF_ADD_WORD` `CP_DIFF_DEL_WORD`

Claude Code paints diffs as filled lines, which no other surface does and no
other slot answers: an added-line background is `CP_GREEN` sunk most of the way
into `CP_BG`, and nothing in the accent half is that. Derived once from
`CP_GREEN`, `CP_RED` and `CP_BG`, then authored per theme like the bright half.

### Metadata (4)
`CP_THEME_NAME` `CP_THEME_SLUG` `CP_THEME_LIGHT` `CP_THEME_BASE`

`CP_THEME_BASE` names the built-in Claude Code theme the overrides sit on top
of — `dark` for seven of these, `light` for Paper. It is the one metadata slot
a surface reads as a value rather than a label.

## Two rules

**`CP_PURPLE` and `CP_BLUE` are surface colours. Never put text in them.**
They sit at 1.4:1 to 2.8:1 against their own background in most of the eight,
which is correct for what they are — inactive borders and selection fills. It
is not a bug to be fixed by lightening them; `CP_PURPLE_MID` exists for the
cases where a purple has to carry a glyph.

**`CP_WHITE` is ANSI 7, not "the bright foreground".** Those are the same
colour on a dark background and exact opposites on a light one, which is what
made a light theme unshippable until they were split. Emphatic text is
`CP_FG_STRONG`; the terminal ramp's light end is `CP_WHITE`. Same for
`CP_BLACK` (ANSI 0, dark in every theme) versus `CP_VOID` (the surface
extreme — black when dark, white when light).

## Adding one

Copy `cyberpunk-neon.sh`, change the 41 values and the three metadata lines,
then:

```sh
test/theme.sh
```

It checks that the palette actually *sets* its variables — `CP_BG ="#000b1e"`
with a space before the `=` is a command, not an assignment, so `bash -n`
passes it and the variable is never set — that all 47 slots are present in
order, that every surface renders, that nothing has drifted from its template,
that switching through every theme and back restores the tree byte for byte,
and that the slots carrying text clear their contrast floor:

| Slot | Floor on `CP_BG` |
|---|---|
| `CP_FG`, `CP_FG_STRONG`, `CP_MAGENTA`, `CP_RED`, `CP_GREEN`, `CP_ORANGE`, `CP_YELLOW` | 4.5:1 |
| `CP_FG_DIM` | 4.0:1 |
| `CP_PURPLE_MID` | 3.0:1 |
| `CP_FG` on `CP_BG_ALT` (the bar) | 4.5:1 |

`CP_FG_DIM`'s floor is 4.0 rather than 4.5 because that is what Cyberpunk Neon
has always shipped, and a test that fails on the default theme teaches nobody
anything. It is the one slot in the set worth watching.
