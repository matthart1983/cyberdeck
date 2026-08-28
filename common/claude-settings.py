#!/usr/bin/env python3
"""Point Claude Code at the rice's theme and statusline.

~/.claude/settings.json is Claude Code's own file and holds the user's other
preferences, so this patches the two keys the rice owns and leaves everything
else exactly as it found it. Prints "changed" or "same" for install.sh to
report; writes nothing when there is nothing to change.
"""
import json
import os
import sys

path, command = sys.argv[1], sys.argv[2]

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

settings["theme"] = "dark-ansi"
settings["statusLine"] = {"type": "command", "command": command}

after = json.dumps(settings, indent=2) + "\n"
if before is not None and json.loads(before or "{}") == json.loads(after):
    print("same")
    sys.exit(0)

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as fh:
    fh.write(after)
print("changed")
