#!/usr/bin/env python3
"""Cyberpunk Neon wallpaper generator.

Deliberately low-contrast: this sits behind tiled windows and shows through
gaps, so it has to read as atmosphere, not as a poster competing with text.
Palette matches ~/.dotfiles/palette.sh.
"""
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageChops

BLACK   = (0x04, 0x07, 0x13)
BG      = (0x00, 0x0b, 0x1e)
BG_ALT  = (0x09, 0x18, 0x33)
BLUE    = (0x13, 0x3e, 0x7c)
CYAN    = (0x0a, 0xbd, 0xc6)
MAGENTA = (0xea, 0x00, 0xd9)
PURPLE  = (0x71, 0x1c, 0x91)


def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


def build(w, h):
    horizon = int(h * 0.63)
    img = Image.new("RGB", (w, h), BG)
    d = ImageDraw.Draw(img)

    # Sky: deepest black at the top easing into navy at the horizon.
    for y in range(horizon):
        t = (y / horizon) ** 1.6
        d.line([(0, y), (w, y)], fill=lerp(BLACK, BG_ALT, t))

    # Ground: navy falling back to black at the bottom edge.
    for y in range(horizon, h):
        t = (y - horizon) / max(1, h - horizon)
        d.line([(0, y), (w, y)], fill=lerp(BG_ALT, BLACK, t ** 0.8))

    # Horizon glow — a wide magenta/purple bloom, blurred hard and screened on.
    glow = Image.new("RGB", (w, h), (0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gw, gh = int(w * 0.75), int(h * 0.10)
    gd.ellipse(
        [w // 2 - gw // 2, horizon - gh // 2, w // 2 + gw // 2, horizon + gh // 2],
        fill=tuple(c // 3 for c in MAGENTA),
    )
    gd.ellipse(
        [w // 2 - gw // 3, horizon - gh, w // 2 + gw // 3, horizon + gh // 3],
        fill=tuple(c // 4 for c in PURPLE),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=w // 22))
    img = ImageChops.screen(img, glow)

    # Perspective grid on its own layer so it can be blurred and dimmed.
    grid = Image.new("RGB", (w, h), (0, 0, 0))
    gd = ImageDraw.Draw(grid)
    line_col = tuple(c // 2 for c in BLUE)
    vp = (w // 2, horizon)

    # Verticals converging on the vanishing point.
    span = w * 3
    step = w // 22
    x = -span
    while x <= span:
        gd.line([vp, (vp[0] + x, h)], fill=line_col, width=2)
        x += step

    # Horizontals: spacing grows toward the viewer for the depth cue.
    y, gap = horizon, 3.0
    while y < h:
        gd.line([(0, int(y)), (w, int(y))], fill=line_col, width=2)
        y += gap
        gap *= 1.30

    grid = grid.filter(ImageFilter.GaussianBlur(radius=1.2))
    img = ImageChops.screen(img, grid)

    # A single cyan horizon rule — the one crisp edge in the whole image.
    rule = Image.new("RGB", (w, h), (0, 0, 0))
    ImageDraw.Draw(rule).line(
        [(0, horizon), (w, horizon)], fill=tuple(c // 3 for c in CYAN), width=2
    )
    img = ImageChops.screen(img, rule.filter(ImageFilter.GaussianBlur(radius=2)))

    # CRT scanlines.
    scan = Image.new("RGB", (w, h), (255, 255, 255))
    sd = ImageDraw.Draw(scan)
    for y in range(0, h, 3):
        sd.line([(0, y), (w, y)], fill=(228, 228, 232), width=1)
    img = ImageChops.multiply(img, scan)

    # Vignette to keep the corners quiet under window gaps.
    vign = Image.new("L", (w, h), 0)
    vd = ImageDraw.Draw(vign)
    inset = int(min(w, h) * 0.06)
    vd.ellipse([-inset, -inset, w + inset, h + inset], fill=255)
    vign = vign.filter(ImageFilter.GaussianBlur(radius=min(w, h) // 8))
    img = Image.composite(img, Image.new("RGB", (w, h), BLACK), vign)

    return img


if __name__ == "__main__":
    targets = [(3024, 1964, "cyberpunk-mbp.png"), (3840, 2160, "cyberpunk-4k.png")]
    outdir = sys.argv[1] if len(sys.argv) > 1 else "."
    for w, h, name in targets:
        path = f"{outdir}/{name}"
        build(w, h).save(path)
        print(f"wrote {path} ({w}x{h})")
