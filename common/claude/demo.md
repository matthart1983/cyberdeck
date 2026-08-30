# Claude Code theme demo

Read this inside Claude Code after `cc-theme <value>`. Everything below is here
to make one of Claude Code's colour slots visible; nothing below is real code.

The one to compare everything against is `cc-theme custom:cyberdeck`, which is
rendered from the active palette and moves when you run `theme <slug>`.

`cc-theme demo` draws the terminal half of this — the sixteen ANSI colours. It
cannot draw the half on this page, because Claude Code paints its own chrome
and no outside process can reproduce it. That's why this file exists.

## Diffs — where the seven differ most

This is the slot worth judging a theme on, and the entire reason the two
colourblind-friendly themes exist: they move added/removed off red/green and
onto blue/orange.

```diff
@@ -1,7 +1,8 @@
 def render(palette, template):
-    slots = parse(palette)
-    return template.replace(slots)
+    slots = parse(palette, strict=True)
+    if unknown := find_placeholders(template) - slots.keys():
+        raise KeyError(f"no such slot: {sorted(unknown)}")
+    return template.substitute(slots)

-# TODO: handle the light themes
+# Light themes are handled by CP_THEME_LIGHT.
```

Look at three things: the green of an added line, the red of a removed one, and
whether the *word-level* highlight inside a changed line is distinguishable from
the line-level one. `dark` and `dark-ansi` differ most here.

## Syntax highlighting

```python
CP_SLOTS = 41                      # numbers
NAME = "Blade"                     # strings

class Palette:
    """Docstrings and comments share a slot in most themes."""

    def __init__(self, slug: str, *, light: bool = False) -> None:
        self.slug = slug
        self.light = light          # keywords, params, self

    @property
    def is_dark(self) -> bool:
        return not self.light
```

```bash
theme blade && git diff --stat    # the rice's own idiom
cc-theme next                     # and this one's
```

## Text weights

The **strong** slot, the *emphasis* slot, `inline code`, and a
[link](https://docs.claude.com/en/docs/claude-code). Plain body text sits
between the strong and the dim, and a theme that collapses those three into one
grey is a theme you will misread at the end of a long day.

> A blockquote uses the subtle slot. On `light-ansi` this is the line most
> likely to disappear into the background, so it is the one to check.

## Structure

| Slot | Where you see it | Check it by |
|---|---|---|
| `success` | a tool that worked | running anything |
| `error` | a failed command | running `false` |
| `warning` | a caveat | a diff that touches many files |
| `permission` | the approval prompt | editing a file |
| `planMode` | the plan-mode banner | `/plan` |
| `bashBorder` | the box around shell output | any Bash call |

1. Ordered lists use the body slot.
2. Nested items step in:
   - and bullets use the subtle slot for their markers
   - which is worth a look on the daltonized pair

---

Horizontal rules, like the one above, use the same slot as table borders. If it
vanished on this theme, that's the answer.
