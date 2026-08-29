#!/usr/bin/env bash
# Ghostty, built from upstream source. Opt-in and needs sudo, exactly like
# linux/packages.sh — install.sh never calls this.
#
#   ~/.dotfiles/linux/ghostty.sh                 build the pinned release
#   GHOSTTY_VERSION=1.3.2 ~/.dotfiles/linux/ghostty.sh
#   GHOSTTY_REBUILD=1     ~/.dotfiles/linux/ghostty.sh   rebuild what is there
#
# Why source, when nothing else in this repo is built from source: Fedora does
# not package Ghostty, and Fedora's filtered Flathub does not carry it. The
# only prebuilt binaries are third-party COPRs, and packages.sh deliberately
# refuses to pick one of those for you. Upstream publishes signed source
# tarballs, so building one is the shortest path that still ends at an
# artifact signed by the people who wrote it.
#
# Sudo is used for the build dependencies and nothing else. Ghostty itself
# installs into ~/.local, so this leaves no root-owned files behind and
# `rm -rf ~/.local/bin/ghostty ~/.local/share/ghostty` undoes it.
set -euo pipefail
D="${D:-$HOME/.dotfiles}"
# shellcheck source=common/lib.sh
source "$D/common/lib.sh"

VERSION="${GHOSTTY_VERSION:-1.3.1}"
PREFIX="${GHOSTTY_PREFIX:-$HOME/.local}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/cyberdeck/ghostty"
SRC="$CACHE/ghostty-$VERSION"

# Upstream's minisign key, from PACKAGING.md. Pinned here on purpose: fetching
# the key from the same host as the tarball would verify nothing.
GHOSTTY_KEY='RWQlAjJC23149WL2sEpT/l0QKy7hMIFhYdQOFy0Z7z7PbneUgvlsnYcV'

die() { printf '  %s✘%s %s\n' "${_c_warn}" "${_c_off}" "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Already there?
# ---------------------------------------------------------------------------
installed_version() {
  [ -x "$PREFIX/bin/ghostty" ] || return 1
  "$PREFIX/bin/ghostty" +version 2>/dev/null \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

if [ -z "${GHOSTTY_REBUILD:-}" ] && [ "$(installed_version || true)" = "$VERSION" ]; then
  same "$PREFIX/bin/ghostty ($VERSION)"
  summary "ghostty"
  exit 0
fi

# ---------------------------------------------------------------------------
# Build dependencies
# ---------------------------------------------------------------------------
# The GTK stack has to come from Fedora — it is the one part of the build that
# Zig does not vendor. Everything else Ghostty depends on (freetype, harfbuzz,
# oniguruma, simdutf, glslang, spirv-cross, zlib …) is fetched and compiled by
# `zig build`, which is why this list is shorter than upstream's packaging
# notes suggest.
DEPS=(
  # toolchain and codegen
  pkgconf-pkg-config blueprint-compiler gettext libxml2 ncurses git minisign
  # GTK4 / libadwaita, and the layer-shell binding the quick terminal needs
  gtk4-devel libadwaita-devel gtk4-layer-shell-devel
  gobject-introspection-devel glib2-devel
  # display servers
  wayland-devel wayland-protocols-devel libxkbcommon-devel
  libX11-devel libXcursor-devel libXi-devel libXrandr-devel
  mesa-libGL-devel
  # GTK's media backend
  gstreamer1-devel gstreamer1-plugins-base-devel
  # runtime: icons, and the schemas GTK reads for the system colour scheme
  adwaita-icon-theme gsettings-desktop-schemas desktop-file-utils
)

MISSING=()
for p in "${DEPS[@]}"; do rpm -q "$p" >/dev/null 2>&1 || MISSING+=("$p"); done

echo "==> build dependencies"
if [ ${#MISSING[@]} -eq 0 ]; then
  same "${#DEPS[@]} packages already installed"
else
  chg "${#MISSING[@]} packages: ${MISSING[*]}"
  sudo dnf install -y "${MISSING[@]}"
fi

# pandoc renders the man pages, and Fedora retired it. The build detects that
# and skips the docs on its own; say so rather than letting `man ghostty`
# quietly not exist.
command -v pandoc >/dev/null || warn "pandoc not in Fedora's repos — man pages will be skipped"

# ---------------------------------------------------------------------------
# Source: fetch, verify, unpack
# ---------------------------------------------------------------------------
echo "==> source"
mkdir -p "$CACHE"
TARBALL="$CACHE/ghostty-$VERSION.tar.gz"
BASE="https://release.files.ghostty.org/$VERSION/ghostty-$VERSION.tar.gz"

if [ -f "$TARBALL" ] && [ -f "$TARBALL.minisig" ]; then
  same "$TARBALL"
else
  curl -fsSL --proto '=https' "$BASE"         -o "$TARBALL"        || die "download failed: $BASE"
  curl -fsSL --proto '=https' "$BASE.minisig" -o "$TARBALL.minisig" || die "no signature for $VERSION"
  chg "$TARBALL"
fi

# The whole reason to prefer the tarball over a git checkout: this line.
minisign -Vm "$TARBALL" -P "$GHOSTTY_KEY" >/dev/null \
  || die "signature check FAILED for $TARBALL — do not build this"
same "signature verified (minisign)"

# Unpack fresh every time. A half-built tree from an interrupted run is worse
# than the twenty seconds this costs.
rm -rf "$SRC"
mkdir -p "$SRC"
tar -xzf "$TARBALL" -C "$SRC" --strip-components=1
chg "$SRC"

# ---------------------------------------------------------------------------
# Zig
# ---------------------------------------------------------------------------
# Ghostty pins a Zig *minor*: build.zig rejects anything whose major.minor
# differs, because Zig still breaks its own language between releases. Fedora
# 44 ships 0.15.2 in the base repo and 0.16.0 in updates, so a plain
# `dnf install zig` gets you a compiler that cannot build this. The required
# version is read out of the source that was just verified, so bumping
# GHOSTTY_VERSION moves the toolchain with it.
echo "==> zig"
REQ="$(sed -n 's/.*\.minimum_zig_version = "\([0-9.]*\)".*/\1/p' "$SRC/build.zig.zon")"
[ -n "$REQ" ] || die "could not read minimum_zig_version from build.zig.zon"
REQ_MM="${REQ%.*}"

# True when $1 is a zig whose major.minor is the pinned one and whose patch is
# not older — the same test build.zig makes, so a failure here is a clear
# message instead of a @compileError three screens long.
zig_ok() {
  local v; v="$("$1" version 2>/dev/null)" || return 1
  [ "${v%.*}" = "$REQ_MM" ] || return 1
  [ "${v##*.}" -ge "${REQ##*.}" ] 2>/dev/null
}

ZIG=""
if command -v zig >/dev/null && zig_ok zig; then
  ZIG="$(command -v zig)"
  same "system zig $(zig version)"
elif sudo dnf install -y "zig-$REQ" >/dev/null 2>&1 && zig_ok /usr/bin/zig; then
  ZIG=/usr/bin/zig
  chg "zig $REQ from Fedora"
else
  # Fedora has moved on and no longer carries the pinned minor. Fall back to
  # the official build, into a cache directory — not onto the system, so this
  # never fights dnf over /usr/bin/zig.
  ARCH="$(uname -m)-linux"
  ZIG_DIR="$CACHE/zig/$REQ"
  if [ -x "$ZIG_DIR/zig" ]; then
    same "cached zig $REQ ($ZIG_DIR)"
  else
    read -r ZURL ZSHA < <(
      curl -fsSL --proto '=https' https://ziglang.org/download/index.json |
      python3 -c 'import json,sys
i, v, a = json.load(sys.stdin), sys.argv[1], sys.argv[2]
b = i.get(v, {}).get(a)
print(b["tarball"], b["shasum"]) if b else sys.exit(1)' "$REQ" "$ARCH"
    ) || die "ziglang.org publishes no $REQ build for $ARCH"

    ZTAR="$CACHE/$(basename "$ZURL")"
    curl -fsSL --proto '=https' "$ZURL" -o "$ZTAR" || die "download failed: $ZURL"
    echo "$ZSHA  $ZTAR" | sha256sum -c --quiet - \
      || die "checksum FAILED for $ZTAR"
    mkdir -p "$ZIG_DIR"
    tar -xJf "$ZTAR" -C "$ZIG_DIR" --strip-components=1
    chg "zig $REQ ($ZIG_DIR)"
  fi
  ZIG="$ZIG_DIR/zig"
fi

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------
# -Dcpu=baseline so the binary survives being copied to another machine;
# -Doptimize=ReleaseFast is what upstream ships. -Dversion-string because a
# source tarball is not a git checkout: without it the build cannot find a
# revision and stamps itself 1.3.1-dev+0000000, which is a lie about what you
# are running. This step fetches Ghostty's own dependencies, so it needs the
# network.
echo "==> build (this takes a few minutes)"
( cd "$SRC" && "$ZIG" build --prefix "$PREFIX" \
    -Doptimize=ReleaseFast -Dcpu=baseline -Dversion-string="$VERSION" )
chg "$PREFIX/bin/ghostty $(installed_version || echo '?')"

# ---------------------------------------------------------------------------
# terminfo
# ---------------------------------------------------------------------------
# The build compiles a terminfo database into $PREFIX/share/terminfo, but
# ncurses only searches /etc/terminfo, /usr/share/terminfo and ~/.terminfo —
# a ~/.local install lands in none of them, and every curses program inside
# Ghostty then runs against an unknown TERM. Copying the database into
# ~/.terminfo is what makes `xterm-ghostty` resolve for the whole user.
echo "==> terminfo"
DB="$PREFIX/share/terminfo"
if infocmp -x xterm-ghostty >/dev/null 2>&1; then
  same "xterm-ghostty"
elif [ -d "$DB" ]; then
  # -a, not -R: tic writes the term-name aliases as symlinks, and plain -R
  # dereferences them into duplicate copies.
  mkdir -p "$HOME/.terminfo" && cp -a "$DB/." "$HOME/.terminfo/" \
    && chg "$HOME/.terminfo (from $DB)" \
    || warn "could not copy terminfo — set TERM=xterm-256color in ghostty/config"
else
  warn "no terminfo database at $DB — set TERM=xterm-256color in ghostty/config"
fi

# ---------------------------------------------------------------------------
echo "==> desktop entry"
if command -v update-desktop-database >/dev/null; then
  update-desktop-database "$PREFIX/share/applications" 2>/dev/null && chg "desktop database" \
    || warn "update-desktop-database failed"
else
  warn "desktop-file-utils missing — the app grid may not see Ghostty until relogin"
fi

summary "ghostty"
case ":$PATH:" in
  *":$PREFIX/bin:"*) ;;
  *) warn "$PREFIX/bin is not on PATH — add it to ~/.zshrc" ;;
esac
echo "    niri already spawns Ghostty on Mod+Return; nothing in the rice needs"
echo "    changing. Re-run this script to move to a newer release."
