#!/usr/bin/env python3
"""Point Claude Code at the rice's theme and statusline.

    claude-settings.py <settings.json> <statusline-command> [theme]

~/.claude/settings.json is Claude Code's own file and holds the user's other
preferences, so this patches the two keys the rice owns and leaves everything
else exactly as it found it. Prints "changed" or "same" for install.sh to
report; writes nothing when there is nothing to change.

The theme used to be hardcoded here, which meant `theme blade` — which runs
install.sh — silently reverted whatever you had switched to. It is now an
argument, and `cc-theme` and install.sh both pass one, so the choice survives a
palette switch. Omitting it keeps the old default.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_THEME = "dark-ansi"
CUSTOM = "custom:"


def known_themes():
    """The values settings.json accepts, from the one file that lists them."""
    out = []
    try:
        with open(os.path.join(HERE, "claude", "themes.psv")) as fh:
            for line in fh:
                line = line.strip()
                if line and not line.startswith("#"):
                    out.append(line.split("|", 1)[0])
    except OSError:
        pass
    return out


path, command = sys.argv[1], sys.argv[2]
theme = sys.argv[3] if len(sys.argv) > 3 else DEFAULT_THEME

# A theme Claude Code would reject leaves it with no colours at all, and the
# file this came from is machine-local and hand-editable. Refuse loudly
# rather than writing something that breaks the UI.
#
# "custom:<slug>" selects ~/.claude/themes/<slug>.json, which is where the
# fourteenth surface lands — so the check is that the file is there, not that
# the name is in a list this repo controls.
if theme.startswith(CUSTOM):
    slug = theme[len(CUSTOM):]
    custom = os.path.join(os.path.dirname(path), "themes", slug + ".json")
    if not slug or not os.path.exists(custom):
        print("invalid-theme")
        sys.exit(0)
else:
    allowed = known_themes()
    if allowed and theme not in allowed:
        print("invalid-theme")
        sys.exit(0)

try:
    with open(path) as fh:
        before = fh.read()
    settings = json.loads(before) if before.strip() else {}
except FileNotFoundError:
    before, settings = None, {}
except json.JSONDecodeError:
    # Someone's hand-edit is not ours to discard.
    print("invalid")
    sys.exit(0)

settings["theme"] = theme
settings["statusLine"] = {"type": "command", "command": command}

after = json.dumps(settings, indent=2) + "\n"
if before is not None and json.loads(before or "{}") == json.loads(after):
    print("same")
    sys.exit(0)

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as fh:
    fh.write(after)
print("changed")
