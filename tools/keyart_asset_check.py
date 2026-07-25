#!/usr/bin/env python3
"""Release gate for the identity-owned title and Steam key-art surfaces."""

from __future__ import annotations

import hashlib
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MASTER = ROOT / "assets/keyart/gangnam_dream_keyart_cast_v1.png"
LEGACY_NAME = "gangnam_dream_keyart_rooftop.png"
PUBLISHER_LOGO = ROOT / "assets/logos/junpac_games_logo_v2.png"
DEPRECATED_PUBLISHER_FILES = (
    ROOT / "assets/logos/junpac_games_logo.jpg",
    ROOT / "assets/logos/junpac_games_logo.jpg.import",
    ROOT / "scenes/ui/JunpacMark.gd",
    ROOT / "scenes/ui/JunpacMark.gd.uid",
)
DERIVATIVES = {
    "steam_capsule_main": (616, 353),
    "steam_header": (460, 215),
    "steam_capsule_small": (231, 87),
}


def png_size(path: Path) -> tuple[int, int]:
    header = path.read_bytes()[:24]
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"not a PNG: {path.relative_to(ROOT)}")
    return struct.unpack(">II", header[16:24])


def png_color_type(path: Path) -> int:
    header = path.read_bytes()[:26]
    if len(header) != 26 or header[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"not a PNG: {path.relative_to(ROOT)}")
    return header[25]


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    failures: list[str] = []

    if not MASTER.exists():
        failures.append("identity-owned master is missing")
    elif png_size(MASTER) != (1920, 1080):
        failures.append(f"master must be 1920x1080, got {png_size(MASTER)}")

    if not PUBLISHER_LOGO.exists():
        failures.append("approved publisher logo is missing")
    else:
        if png_size(PUBLISHER_LOGO) != (1024, 1024):
            failures.append(
                f"publisher logo must be 1024x1024, got {png_size(PUBLISHER_LOGO)}"
            )
        if png_color_type(PUBLISHER_LOGO) != 6:
            failures.append("publisher logo must be an RGBA PNG")

    for path in DEPRECATED_PUBLISHER_FILES:
        if path.exists():
            failures.append(f"deprecated publisher asset remains: {path.relative_to(ROOT)}")

    for stem, expected_size in DERIVATIVES.items():
        official = ROOT / f"assets/keyart/{stem}.png"
        approval = ROOT / f"assets/keyart/{stem}_v2.png"
        for path in (official, approval):
            if not path.exists():
                failures.append(f"missing {path.relative_to(ROOT)}")
                continue
            actual_size = png_size(path)
            if actual_size != expected_size:
                failures.append(
                    f"{path.relative_to(ROOT)} must be {expected_size}, got {actual_size}"
                )
        if official.exists() and approval.exists() and digest(official) != digest(approval):
            failures.append(f"{stem}.png drifted from its approved _v2 export")

    runtime_surfaces = (
        ROOT / "scenes/StartMenu.gd",
        ROOT / "scenes/SplashScreen.gd",
    )
    for source_path in runtime_surfaces:
        source = source_path.read_text(encoding="utf-8")
        if MASTER.name not in source:
            failures.append(f"{source_path.relative_to(ROOT)} does not use the launch master")
        if LEGACY_NAME in source:
            failures.append(f"{source_path.relative_to(ROOT)} still uses legacy rooftop branding")

    splash_source = (ROOT / "scenes/SplashScreen.gd").read_text(encoding="utf-8")
    if "junpac_games_logo.jpg" in splash_source:
        failures.append("SplashScreen still embeds the opaque JUNPAC JPEG")
    if "res://assets/logos/junpac_games_logo_v2.png" not in splash_source:
        failures.append("SplashScreen does not use the approved JUNPAC PNG")
    if "res://scenes/ui/JunpacMark.gd" in splash_source:
        failures.append("SplashScreen still uses the retired code-native JUNPAC mark")

    if failures:
        for failure in failures:
            print(f"KEY_ART_CHECK_FAIL {failure}")
        return 1

    print(
        "KEY_ART_CHECK_OK master=1920x1080 derivatives=616x353,460x215,231x87 "
        "runtime_surfaces=2 publisher_mark=image_asset legacy_runtime_refs=0"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
