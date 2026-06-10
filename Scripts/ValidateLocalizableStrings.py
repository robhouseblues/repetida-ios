#!/usr/bin/env python3
"""Fail if Localizable.xcstrings has missing or untranslated pt-BR entries."""

from __future__ import annotations

import json
import re
import sys
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

# Auto-extracted format-only keys; no pt-BR copy needed.
ALLOW_EMPTY = {"·", "%lld", "%lld%%", "+%lld"}


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


def main() -> int:
    refs = referenced_keys()
    data = json.loads(XCSTRINGS.read_text())
    strings = data["strings"]
    errors: list[str] = []

    for key in sorted(refs):
        if key not in strings:
            errors.append(f"missing catalog key: {key}")
            continue
        pt = strings[key].get("localizations", {}).get("pt-BR", {}).get("stringUnit", {})
        value = pt.get("value", "")
        state = pt.get("state", "")
        if not pt:
            errors.append(f"no pt-BR localization: {key}")
        elif state != "translated":
            errors.append(f"not translated ({state}): {key}")
        elif not value.strip():
            errors.append(f"empty value: {key}")
        elif value.startswith(key.split()[0]) and "." in value.split()[0] and "%" not in value:
            errors.append(f"placeholder value: {key} => {value}")

    for key, entry in sorted(strings.items()):
        if key in refs or key in ALLOW_EMPTY:
            continue
        pt = entry.get("localizations", {}).get("pt-BR", {}).get("stringUnit", {})
        if not pt:
            errors.append(f"orphan key without pt-BR: {key}")
        elif pt.get("state") != "translated":
            errors.append(f"orphan key not translated: {key}")

    if errors:
        print("Localization validation failed:")
        for error in errors:
            print(f"  - {error}")
        return 1

    print(f"OK: {len(refs)} L10n keys, {len(strings)} catalog entries")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
