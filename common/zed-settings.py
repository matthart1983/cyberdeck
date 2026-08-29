#!/usr/bin/env python3
"""Select the rice's theme in Zed.

    zed-settings.py <settings.json> <theme name>

common/install.sh links the theme *file* into ~/.config/zed/themes, which makes
it appear in Zed's theme picker and does nothing else. Zed only uses a theme
once settings.json names it, so this sets that one key.

settings.json is the user's file and Zed writes it as JSONC — with comments,
which Zed's own default settings are almost entirely made of. json.dump would
give the key back and throw every comment away, so this splices the new value
into the original text and leaves every other byte where it was.

Prints "changed", "same" or "invalid" for install.sh to report.
"""
import json
import os
import re
import sys

# The display name comes from the active palette — `theme blade` has to move
# Zed with everything else, and Zed's picker shows this string.
path, THEME = sys.argv[1], sys.argv[2]

try:
    with open(path) as fh:
        text = fh.read()
except FileNotFoundError:
    text = ""


def blank_comments(src):
    """A copy of src with // and /* */ comments replaced by spaces.

    Offsets are preserved, so anything found in the copy can be spliced into
    the original. Comment markers inside string literals are left alone —
    a theme named "http://…" would otherwise eat the rest of the line.
    """
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if c == '"':
            j = i + 1
            while j < n:
                if src[j] == "\\":
                    j += 2
                    continue
                if src[j] == '"':
                    j += 1
                    break
                j += 1
            out.append(src[i:j])
            i = j
        elif src.startswith("//", i):
            j = src.find("\n", i)
            j = n if j < 0 else j
            out.append(" " * (j - i))
            i = j
        elif src.startswith("/*", i):
            j = src.find("*/", i + 2)
            j = n if j < 0 else j + 2
            # Keep the newlines: line numbers in any later error stay honest.
            out.append("".join(ch if ch == "\n" else " " for ch in src[i:j]))
            i = j
        else:
            out.append(c)
            i += 1
    return "".join(out)


def value_end(src, i):
    """Index one past the JSON value starting at src[i], or None."""
    n = len(src)
    if src[i] == '"':
        j = i + 1
        while j < n:
            if src[j] == "\\":
                j += 2
                continue
            if src[j] == '"':
                return j + 1
            j += 1
        return None
    if src[i] in "{[":
        close = {"{": "}", "[": "]"}[src[i]]
        depth, j = 0, i
        while j < n:
            if src[j] == '"':
                j = value_end(src, j)
                if j is None:
                    return None
                continue
            if src[j] in "{[":
                depth += 1
            elif src[j] in "}]":
                depth -= 1
                if depth == 0:
                    return j + 1 if src[j] == close else None
            j += 1
        return None
    j = i
    while j < n and src[j] not in ",}]" and not src[j].isspace():
        j += 1
    return j if j > i else None


def find_top_level_key(src, key):
    """(value_start, value_end) for a key at depth 1, or None."""
    n, i, depth = len(src), 0, 0
    while i < n:
        c = src[i]
        if c == '"':
            end = value_end(src, i)
            if end is None:
                return None
            if depth == 1 and src[i + 1:end - 1] == key:
                j = end
                while j < n and src[j].isspace():
                    j += 1
                if j < n and src[j] == ":":
                    j += 1
                    while j < n and src[j].isspace():
                        j += 1
                    ve = value_end(src, j)
                    if ve is not None:
                        return j, ve
            i = end
            continue
        if c in "{[":
            depth += 1
        elif c in "}]":
            depth -= 1
        i += 1
    return None


if not text.strip():
    new = '{\n  "theme": "%s"\n}\n' % THEME
else:
    mask = blank_comments(text)
    open_brace = mask.find("{")
    # A hand-edit that does not parse is not ours to rewrite. Trailing commas
    # are stripped first because Zed accepts them and json does not.
    try:
        json.loads(re.sub(r",(\s*[}\]])", r"\1", mask))
    except (ValueError, RecursionError):
        print("invalid")
        sys.exit(0)
    if open_brace < 0:
        print("invalid")
        sys.exit(0)

    span = find_top_level_key(mask, "theme")
    if span is None:
        close = mask.rfind("}")
        if mask[open_brace + 1:close].strip():
            new = (text[:open_brace + 1]
                   + '\n  "theme": "%s",' % THEME
                   + text[open_brace + 1:])
        else:
            # An empty {} — write the whole object rather than wedging a key
            # in and leaving the brace on the same line.
            new = text[:open_brace] + '{\n  "theme": "%s"\n}' % THEME + text[close + 1:]
    elif mask[span[0]] == "{":
        # The object form, {"mode": "system", "light": …, "dark": …}. Only the
        # dark slot is ours: this rice has no light half, and flattening the
        # key to a bare string would silently throw away whichever light theme
        # the user picked for daytime.
        start, end = span
        inner = find_top_level_key(mask[start:end], "dark")
        if inner:
            ds, de = start + inner[0], start + inner[1]
            if mask[ds] == '"' and mask[ds + 1:de - 1] == THEME:
                print("same")
                sys.exit(0)
            new = text[:ds] + '"%s"' % THEME + text[de:]
        else:
            new = text[:start + 1] + '\n    "dark": "%s",' % THEME + text[start + 1:]
    else:
        start, end = span
        if mask[start] == '"' and mask[start + 1:end - 1] == THEME:
            print("same")
            sys.exit(0)
        new = text[:start] + '"%s"' % THEME + text[end:]

if new == text:
    print("same")
    sys.exit(0)

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as fh:
    fh.write(new)
print("changed")
