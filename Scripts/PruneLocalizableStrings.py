#!/usr/bin/env python3
"""Remove localization keys not referenced by L10n.swift."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "Repetida" / "Localization" / "L10n.swift"
XCSTRINGS = ROOT / "Repetida" / "Localization" / "Localizable.xcstrings"

STRING_PARAM_HINTS = (
    "name",
    "code",
    "team",
    "sticker",
    "flag",
    "label",
    "date",
    "kind",
)


def to_catalog_key(template: str) -> str:
    result = template
    for var in re.findall(r"\\\((\w+)\)", template):
        var_lower = var.lower()
        token = "%@" if any(hint in var_lower for hint in STRING_PARAM_HINTS) else "%lld"
        result = result.replace(f"\\({var})", token, 1)
    return result.strip()


def referenced_keys() -> set[str]:
    content = L10N.read_text()
    templates = re.findall(r'String\(localized: "([^"]+)"', content)
    return {to_catalog_key(template) for template in templates}


def main() -> None:
    keep = referenced_keys()
    data = json.loads(XCSTRINGS.read_text())
    strings = data["strings"]
    removed = sorted(key for key in strings if key not in keep)
    for key in removed:
        del strings[key]
    XCSTRINGS.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    print(f"Kept {len(strings)} keys, removed {len(removed)} stale keys")


if __name__ == "__main__":
    main()
