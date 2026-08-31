#!/usr/bin/env python3
"""Dock tiles for the slots no icon exists for.

Four of the dock's slots are ordinary applications and have a real icon: the
system icon theme has Ghostty's, VS Code's, Firefox's, Nautilus's. The rest run
inside a terminal — lazygit, k9s, the HUD — and there is no icon anywhere on the
machine for any of them, because none of those projects ship one.

Adwaita's generic stand-ins (`applications-development`, `utilities-terminal`)
were the obvious answer and are the wrong one: they are the old 48px legacy set,
and sitting them beside Ghostty's and VS Code's current icons reads as four
icons and five mistakes.

So these are drawn instead: a rounded tile in the palette's own colours with a
short monogram. They cannot be mistaken for a missing icon, they match the bar
they sit in, and they move with `theme` like every other surface.

Same shape as wallpaper/generate.py, and for the same reason — this is a
program rather than a template, so it reads the palette directly instead of
keeping a third copy of the numbers.
"""
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

D = os.environ.get("D") or os.path.expanduser("~/.dotfiles")
_active = os.path.join(D, "themes/active.sh")
_palette = _active if os.path.exists(_active) else os.path.join(D, "themes/cyberpunk-neon.sh")
_slots = dict(re.findall(r'^(CP_[A-Z0-9_]+)="(#[0-9a-f]{6})"',
                         open(_palette).read(), re.M))


def _c(slot, alpha=255):
    h = _slots[slot].lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (alpha,)


# The tile is rendered at 4x and downsampled, which is cheaper than antialiasing
# a rounded rectangle by hand and is what the wallpaper generator does with its
# own geometry.
SIZE = 128
SS = 4
RADIUS = 28

# slot -> monogram. One treatment for all six rather than colouring the
# toolbelt separately: CP_BLUE was the obvious accent and the palette itself
# rules it out, with the comment "NOT a text colour. ANSI 4" written beside it.
# In deep-sea it is #245c8f, which against the bar reads as a smudge. The
# app/toolbelt division is already carried by the separator and the hover
# colour, so it does not need saying a third time in the ink.
TILES = {
    "claude":     "CC",
    "hud":        "HUD",
    "git":        "GIT",
    "containers": "BOX",
    "k8s":        "K8S",
    "net":        "NET",
}

FONT_CANDIDATES = [
    os.path.expanduser("~/.local/share/fonts/JetBrainsMonoNerd/JetBrainsMonoNerdFont-Bold.ttf"),
    "/usr/share/fonts/jetbrains-mono-fonts/JetBrainsMono-Bold.ttf",
    "/usr/share/fonts/dejavu-sans-fonts/DejaVuSans-Bold.ttf",
]


def _font(px):
    for p in FONT_CANDIDATES:
        if os.path.exists(p):
            return ImageFont.truetype(p, px)
    # Last resort. The tile still draws; the monogram is just smaller and
    # bitmap, which is better than the generator failing and the dock losing
    # half its slots.
    return ImageFont.load_default()


def tile(text):
    n = SIZE * SS
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    # Transparent behind the outline, which matters more than it sounds. These
    # are images now, and an image cannot recolour on hover the way a glyph
    # could — so hover became a plate drawn by the stylesheet underneath, and a
    # tile with its own opaque fill would sit on top of it and hide it.
    inset = 6 * SS
    d.rounded_rectangle([inset, inset, n - 1 - inset, n - 1 - inset],
                        radius=RADIUS * SS, outline=_c("CP_FG_DIM"), width=3 * SS)

    # Fit the monogram to the plate instead of trusting one point size for
    # both "CC" and "HUD" — three characters at two characters' size overflow
    # the tile, and the overflow is what makes a set of these look unmade.
    target = (n - 2 * inset) * (0.58 if len(text) <= 2 else 0.70)
    px = int(n * 0.42)
    while px > 8:
        f = _font(px)
        l, t, r, b = d.textbbox((0, 0), text, font=f)
        if (r - l) <= target:
            break
        px -= 2
    f = _font(px)
    l, t, r, b = d.textbbox((0, 0), text, font=f)
    d.text(((n - (r - l)) / 2 - l, (n - (b - t)) / 2 - t), text,
           font=f, fill=_c("CP_FG"))

    return img.resize((SIZE, SIZE), Image.LANCZOS)


def main(out_dir):
    os.makedirs(out_dir, exist_ok=True)
    written = []
    for slot, text in TILES.items():
        p = os.path.join(out_dir, f"{slot}.png")
        img = tile(text)
        # Only write on difference, so a re-run is a no-op and the installer's
        # "changed" count stays honest. Same rule as common/lib.sh.
        if os.path.exists(p):
            try:
                if Image.open(p).tobytes() == img.tobytes():
                    continue
            except Exception:
                pass
        img.save(p)
        written.append(slot)
    print(" ".join(written))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1
         else os.path.expanduser("~/.local/share/cyberdeck/dock-icons"))
