#!/usr/bin/env python3
"""Generate Gangnam Dream image assets with the OpenAI Images API.

Default model is `gpt-image-2` for this project. Pass --model to use another
enabled model if the account/API surface exposes a different image model name.
"""

from __future__ import annotations

import argparse
import base64
import datetime as dt
import os
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


STYLE_SUMMARY = """Unified Gangnam Dream art direction: full anime / Korean manhwa visual novel art for a serious 2026 Seoul noir life-sim. Use expressive clean linework, clearly illustrated faces, cel shading with soft gradient shadows, simplified skin, sharp readable silhouettes, and cinematic anime background painting. The mood comes from the existing asset set: late-night Seoul, class anxiety, cramped rooms, rain, empty transit, offices, hospitals, rooftops, and lonely city lights. Palette stays restrained and dark: charcoal, ink navy, graphite gray concrete, muted brown wood, pale hospital gray, restrained olive, warm amber practical lamps, city-window gold, cold blue monitor/window glow, fluorescent white, and subdued purple PC-bang neon. Lighting is motivated and low-key: desk lamps, ceiling fluorescents, refrigerators, subway fixtures, monitors, rain reflections, shop lights, and skyline windows create dramatic value separation, but all surfaces remain anime-rendered rather than photographic. Characters should be serious seinen/manhwa-style VN portraits, not cute chibi and not real actors. Backgrounds should be anime painted game backgrounds with clean perspective, simplified readable forms, atmospheric shadows, and UI-friendly negative space. Absolutely avoid photorealism, DSLR portraits, visible pores, camera bokeh, hyperreal skin texture, celebrity-photo lighting, raw-photo textures, sci-fi UI, magic effects, glowing abstract rings, and oversaturated colors."""

MASTER_STYLE_GUIDE = """Full anime Korean noir visual-novel game art set in Seoul, 2026. High-quality 2D anime / manhwa illustration, clean linework, cel shading, soft gradient shadows, simplified but believable forms, expressive faces, restrained cinematic lighting, dark charcoal and ink navy palette with warm amber practical lights and cold blue highlights. Serious urban melancholy, grounded Korean spaces, no chibi, no fantasy, no photorealism."""


@dataclass(frozen=True)
class Asset:
    path: str
    category: str
    prompt: str


ASSETS: list[Asset] = [
    Asset("assets/characters/main_character_neutral_goshiwon.png", "portrait", "Half-body portrait of a Korean man, early 30s, lean face, short-to-medium dark hair, prominent dark circles. Dark crewneck sweatshirt and jeans. Neutral expression: tired but quietly observant. Background: cramped goshiwon room, bare wall, small desk lamp, overloaded power strip. Dramatic desk lamp side-lighting, warm amber glow. No suit, no tie, no middle-aged appearance."),
    Asset("assets/characters/main_character_tired.png", "portrait", "Same Korean man, early 30s, lean face, dark circles, dark crewneck sweatshirt. Exhausted expression: eyes half-closed, slight slouch, hand on face or chin resting on hand. Same cramped goshiwon room, even dimmer. Sleepless night atmosphere. No suit, no tie, no middle-aged appearance."),
    Asset("assets/characters/main_character_determined.png", "portrait", "Same Korean man, early 30s, same face and casual clothing. Eyes sharp and forward-looking, jaw set, slightly straighter posture. Same goshiwon room lit a shade brighter, as if dawn is breaking. Quiet resolve, not heroic fantasy. No suit, no tie."),
    Asset("assets/characters/main_character_happy.png", "portrait", "Same Korean man, early 30s, same face and casual clothing. Genuine surprised happiness: real smile, eyes crinkled, holding a smartphone screen-out with no readable text. Same room, warmer light. Joy that feels earned and unexpected. No suit, no tie."),
    Asset("assets/characters/main_character_shocked.png", "portrait", "Same Korean man, early 30s, same face and casual clothing. Wide-eyed shock, mouth slightly open, both hands gripping a phone. Ambiguous: could be good or terrible news. Same goshiwon room in the dark. No suit, no tie."),
    Asset("assets/characters/main_character_30s.png", "portrait", "Same Korean man, slightly more polished, simple button-up shirt, not a suit, more office casual. Hair neater, cautious confidence. Background: a nicer one-room apartment behind. Still grounded and modest."),
    Asset("assets/characters/main_character_50s.png", "portrait", "Same man now in his 50s, same facial structure, grey at temples, slight crow's feet, well-fitted dark jacket. Bittersweet wisdom. Background: floor-to-ceiling window with Seoul night skyline. Success with solitude."),
    Asset("assets/characters/npc_romantic_interest.png", "portrait", "Portrait of a Korean woman, late 20s. Bright but slightly melancholy eyes. Casual oversized coat or turtleneck sweater. Shoulder-length natural black hair. Warm half-smile with a hint of worry. Background: blurred Seoul street at dusk, warm shop lights. Not glamorous, real and grounded."),
    Asset("assets/characters/npc_boss.png", "portrait", "Portrait of a Korean man, late 30s to early 40s. Slightly greasy confidence. Slim-fit blazer, expensive watch glimpsed. Hair slicked back. Wide practiced smile that does not reach the eyes. Background: dim bar interior. Opportunistic but not cartoon villain."),
    Asset("assets/characters/npc_close_friend.png", "portrait", "Portrait of a Korean man, early 30s. Ordinary salt-of-the-earth look. Comfortable hoodie or casual jacket, round-ish face, natural warm expression. Slightly awkward warmth, a real friend trying to cheer someone up. Background: pojangmacha interior."),
    Asset("assets/characters/npc_mentor.png", "portrait", "Portrait of a Korean woman, mid-40s. Competent and composed. Neat blazer, reading glasses held in hand. Short professional hair. No-nonsense expression with underlying warmth. Background: blurred corporate office or cafe interior."),
    Asset("assets/characters/npc_tip_seller.png", "portrait", "Portrait of a middle-aged Korean man, 50s. Worn padded jacket, holding a wrinkled racing form newspaper. Shifty eyes and an ingratiating smile. Background: blurred Korean horse-racing betting hall."),
    Asset("assets/backgrounds/racetrack_betting_hall.png", "background", "Interior of a Korean horse racing track betting hall. Large screen showing horse statistics and odds. Long queue counters with betting terminals. Gamblers studying racing forms. Worn linoleum floor, harsh fluorescent lighting. Yellowed fluorescent light, grey walls, green racing form papers."),
    Asset("assets/backgrounds/racetrack_track_view.png", "background", "View of a Korean horse racing track from the grandstand just before a race. Sandy oval track, horses with jockeys at the starting gate far away. Grey overcast sky. Sparse winter crowd blurred. Muted grey-green track and dark stands."),
    Asset("assets/backgrounds/holdem_club_interior.png", "background", "Dim underground Korean poker room. Single poker table under a hanging lamp, the only bright spot. Green felt, poker chips stacked, cards dealt. Shadowy figures with obscured faces. Cigarette smoke haze. Dark wood walls, exposed brick. Very dark palette, single lamp warm glow, noir."),
    Asset("assets/backgrounds/scalping_trading_room.png", "background", "Private home trading setup for rapid stock scalping. Multiple monitors showing real-time candlestick charts, orderbooks, tickers. Headset, energy drink can, sticky notes on monitor bezels. Night outside the window. Cool monitor blue, small warm lamp accent."),
    Asset("assets/backgrounds/pc_bang_interior.png", "background", "Interior of a Korean PC bang at night. Rows of gaming setups in individual booths. Restrained purple and blue LED strip lighting under desks. Silhouettes of players hunched over keyboards. Dark purple-blue neon palette, individual screen glows, grounded realism."),
    Asset("assets/backgrounds/aruba_delivery_street.png", "background", "Seoul street at night from the perspective of a delivery rider. Smartphone mounted on handlebars showing a delivery app map with no readable text. Blurred apartment buildings and streetlights ahead. Cold, lonely urgency of gig work at 11pm. Sodium streetlight orange, app screen blue-white."),
    Asset("assets/backgrounds/gangnam_station_exit.png", "background", "Gangnam Station exit number 11, daytime. Famous Gangnam intersection, luxury cars, business towers, advertising screens. Crowds of office workers and young professionals. Street-level perspective looking up. Wealth gap visible in clothing and posture. Cool grey daylight, restrained splashes of brand color."),
    Asset("assets/backgrounds/goshiwon_room.png", "background", "Interior of a Korean goshiwon single room at night. Single bed, tiny desk with laptop and overloaded power strip, small window with neon bleeding through thin curtains. Walls very close, oppressive and claustrophobic but lived-in. Instant noodles cup, phone charger, notebooks. Amber desk lamp glow, cool neon through curtains."),
    Asset("assets/backgrounds/oneroom_apartment.png", "background", "Interior of a Korean one-room apartment, late evening. Small kitchen merged with living area, single bed frame, modest desk, curtains half-open showing Seoul buildings across the street. Slightly more space than goshiwon. Warm ceiling lamp, humble improvement."),
    Asset("assets/backgrounds/gangnam_apartment.png", "background", "Interior of an upscale Gangnam apartment living room at night. Large sofa, clean modern furniture, floor-to-ceiling windows with Seoul skyline. Tasteful and cold, minimal lived-in quality, feels like a showroom. Single floor lamp on."),
    Asset("assets/backgrounds/seoul_rainy_street.png", "background", "Seoul alleyway at night in the rain. Wet asphalt reflecting neon and streetlights. Pojangmacha tent glowing amber in background. Rain streaks. Lone back-view figure or empty street. Navy and amber palette, rain highlights in cool blue."),
    Asset("assets/backgrounds/office_desk.png", "background", "Korean office desk late at night, long after everyone left. Monitor glow illuminating documents and coffee cups. City lights through floor-to-ceiling window. Empty chairs at other desks. Loneliness of mandatory overtime."),
    Asset("assets/backgrounds/seoul_subway.png", "background", "Late-night Seoul metro car interior. Empty orange plastic seats, fluorescent strip lighting, advertisements without readable text, tunnel darkness through window. One or two distant silhouettes. Cold fluorescent white and grey, orange seat accents."),
    Asset("assets/backgrounds/convenience_store_night.png", "background", "Korean convenience store interior at 2am. Refrigerator aisles glowing white-blue. Triangle kimbap, cup ramen, energy drinks. Drowsy part-time worker silhouette at counter. Rain on window. Cold fluorescent light, dark outside."),
    Asset("assets/backgrounds/cafe_seoul.png", "background", "Small Seoul cafe interior, late afternoon. Two-person wooden table by window, one Americano, empty chair. Rain-streaked window with blurred Seoul alley and umbrellas. Warm amber cafe light against grey-blue outside. Cozy but quietly lonely."),
    Asset("assets/backgrounds/investment_phone.png", "background", "Close-up of a smartphone on a cramped desk showing a stock candlestick chart with red and green candles, no readable text. Cold coffee cup nearby. Dark room, phone screen is the only significant light. Hand hovering over screen. 3am anxiety."),
    Asset("assets/backgrounds/hospital_corridor.png", "background", "Long corridor of a Korean general hospital at night. Fluorescent lights stretching far along white walls. Nurse silhouette far away. IV stand and empty wheelchair visible. Cold white and charcoal palette."),
    Asset("assets/backgrounds/late_night_room.png", "background", "Goshiwon at 4am. Laptop screen only light, blue glow on ceiling and walls. Empty instant noodle cups. Job search site on screen with no readable text. Deep blue tones, laptop screen glow, exhausted atmosphere."),
    Asset("assets/backgrounds/hometown_train_station.png", "background", "Small provincial Korean train station platform, early morning. KTX or mugunghwa train on track. Mountains in background, autumn or winter. A few waiting passengers with luggage silhouettes. Muted ochre and grey, cold morning light."),
    Asset("assets/backgrounds/rooftop_daytime.png", "background", "Rooftop of an old Seoul villa building under overcast grey sky. Water tank, laundry rack with clothes hanging. Dense mid-rise Seoul cityscape in distance under hazy air. Muted grey, warm ochre and dusty rooftop tones."),
    Asset("assets/backgrounds/gangnam_night_street.png", "background", "Gangnam Station exit at night in the rain. Neon signs reflecting on wet sidewalks. Crowds with umbrellas, luxury brand storefronts. Back-view lone figure among the crowd feeling like an outsider. Dark navy, neon highlights, glamorous and alienating."),
    Asset("assets/backgrounds/penthouse_view.png", "background", "Floor-to-ceiling window of a Gangnam high-rise penthouse at night. Full Seoul skyline below. Minimal luxury interior, lone silhouette standing with back to viewer. Bittersweet triumph. Warm interior light against cold city lights."),
    Asset("assets/backgrounds/burnout_hospital_room.png", "background", "Hospital patient room. Single bed, IV drip bag, white curtain partition, pale daylight through small window showing grey Seoul rooftops. Phone face-down on bedside table. Everything has stopped. Cold white, pale grey."),
    Asset("assets/backgrounds/family_living_room.png", "background", "Korean family living room in a provincial town. Old sofa, large TV showing indistinct drama or news, family photos on wall, low wooden table with tea cups. Warm but dated, the home the protagonist left behind. Warm TV glow, evening light."),
    Asset("assets/backgrounds/military_training_ground.png", "background", "Korean military training ground, overcast afternoon. Rows of barracks in background, parade ground with flagpole. Sparse and austere. Muted olive, grey, brown palette."),
    Asset("assets/backgrounds/trading_screen_night.png", "background", "Dark room dominated by multiple monitors showing stock market charts, crypto data, candlestick graphs, no readable text. Screens are only light source. Red and green numbers cascade abstractly. Messy desk with notes and empty coffee cups. Day trading at midnight."),
    Asset("assets/ui/card_back.png", "ui_square", "Playing card back design. Dark navy background with subtle geometric Korean traditional pattern inspired by dancheong, restrained and not ornate. Thin gold border. Simple, elegant, slightly underground aesthetic. Card centered on dark neutral background."),
    Asset("assets/ui/poker_chip_icon.png", "ui_square", "Single poker chip icon, top-down view. Dark red and gold color scheme. Simple clean graphic, crisp edges. Centered on neutral dark background, icon illustration style."),
    Asset("assets/ui/horse_silhouette.png", "ui_wide", "Eight distinct thoroughbred horse silhouettes in a single row on a plain light background. Side view. Each horse slightly different build: leaner, stockier, different head and tail positions. Clean black silhouettes, flat 2D illustration, evenly spaced."),
]

# Steam capsules are locally composed from the approved identity-locked master
# by tools/KeyArtExport.tscn. They must never be regenerated as unrelated art.


OUTPUT_SIZES = {
    "portrait": (512, 768),
    "background": (1280, 800),
    "ui_square": (1024, 1024),
    "ui_wide": (1024, 128),
    "keyart": (1792, 1024),
}

GPT_IMAGE_SIZES = {
    "portrait": "1024x1536",
    "background": "1536x1024",
    "ui_square": "1024x1024",
    "ui_wide": "1536x1024",
    "keyart": "1536x1024",
}

DALL_E_3_SIZES = {
    "portrait": "1024x1792",
    "background": "1792x1024",
    "ui_square": "1024x1024",
    "ui_wide": "1792x1024",
    "keyart": "1792x1024",
}


def build_prompt(asset: Asset) -> str:
    category_rule = ""
    if asset.category == "portrait":
        category_rule = "\n\nPortrait rendering rule: unmistakable anime / Korean webtoon visual-novel character portrait. Clean expressive linework, larger expressive eyes, simplified facial planes, smooth cel-shaded skin, painted hair shapes, sharp silhouette, moody rim light. Do not make a photorealistic portrait, real actor, DSLR photo, or semi-real fashion shoot."
    elif asset.category == "background":
        category_rule = "\n\nBackground rendering rule: anime visual-novel background painting. Clean perspective, line-supported architecture, cel-shaded forms with soft painted atmosphere, readable shapes, negative space for UI overlays. Do not make a raw photo, 3D render screenshot, or photorealistic interior."
    return f"{STYLE_SUMMARY}\n\nMaster Style Guide:\n{MASTER_STYLE_GUIDE}{category_rule}\n\nAsset request:\n{asset.prompt}"


def is_gpt_image_model(model: str) -> bool:
    return model.startswith("gpt-image") or model == "chatgpt-image-latest"


def api_size_for(asset: Asset, model: str) -> str:
    if model == "dall-e-3":
        return DALL_E_3_SIZES[asset.category]
    return GPT_IMAGE_SIZES[asset.category]


def default_quality_for(model: str) -> str:
    if model == "dall-e-3":
        return "standard"
    return "high"


def image_bytes_from_response_data(image) -> bytes:
    if isinstance(image, dict):
        b64_json = image.get("b64_json")
        url = image.get("url")
    else:
        b64_json = getattr(image, "b64_json", None)
        url = getattr(image, "url", None)

    if b64_json:
        return base64.b64decode(b64_json)
    if not url:
        raise RuntimeError("Image response did not include b64_json or url")

    import requests

    download = requests.get(url, timeout=120)
    download.raise_for_status()
    return download.content


def generate_image_with_sdk(client, asset: Asset, model: str, quality: str) -> bytes:
    kwargs = {
        "model": model,
        "prompt": build_prompt(asset),
        "size": api_size_for(asset, model),
        "quality": quality,
        "n": 1,
    }
    response = client.images.generate(**kwargs)
    return image_bytes_from_response_data(response.data[0])


def generate_image_with_requests(api_key: str, asset: Asset, model: str, quality: str) -> bytes:
    import requests

    payload = {
        "model": model,
        "prompt": build_prompt(asset),
        "size": api_size_for(asset, model),
        "quality": quality,
        "n": 1,
    }
    response = requests.post(
        "https://api.openai.com/v1/images/generations",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        json=payload,
        timeout=300,
    )
    response.raise_for_status()
    data = response.json()["data"][0]
    return image_bytes_from_response_data(data)


def resize_with_pillow(source: Path, dest: Path, size: tuple[int, int]) -> bool:
    try:
        from PIL import Image
    except ImportError:
        return False

    with Image.open(source) as image:
        image = image.convert("RGBA")
        target_w, target_h = size
        source_w, source_h = image.size
        scale = max(target_w / source_w, target_h / source_h)
        resized = image.resize((round(source_w * scale), round(source_h * scale)), Image.LANCZOS)
        left = max(0, (resized.width - target_w) // 2)
        top = max(0, (resized.height - target_h) // 2)
        cropped = resized.crop((left, top, left + target_w, top + target_h))
        cropped.save(dest)
    return True


def resize_with_sips(source: Path, dest: Path, size: tuple[int, int]) -> bool:
    if sys.platform != "darwin":
        return False
    target_w, target_h = size
    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp = Path(tmp_dir) / source.name
        tmp.write_bytes(source.read_bytes())
        # First resample so both dimensions cover the target, then center-crop.
        result = subprocess.run(
            ["sips", "--resampleHeightWidthMax", str(max(target_w, target_h) * 2), str(tmp)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        if result.returncode != 0:
            return False
        result = subprocess.run(
            ["sips", "--cropToHeightWidth", str(target_h), str(target_w), str(tmp)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        if result.returncode != 0:
            return False
        dest.write_bytes(tmp.read_bytes())
    return True


def save_output(raw: bytes, dest: Path, size: tuple[int, int]) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as handle:
        temp_path = Path(handle.name)
        handle.write(raw)

    try:
        if resize_with_pillow(temp_path, dest, size):
            return
        if resize_with_sips(temp_path, dest, size):
            return
        dest.write_bytes(temp_path.read_bytes())
        print(f"  Warning: saved native API size; install Pillow for exact {size[0]}x{size[1]} resizing.")
    finally:
        temp_path.unlink(missing_ok=True)


def write_asset_index(generated: Iterable[str], skipped: Iterable[str], failed: Iterable[tuple[str, str]]) -> None:
    index_path = Path("assets/ASSET_INDEX.md")
    existing = index_path.read_text(encoding="utf-8") if index_path.exists() else "# Gangnam Dream Asset Index\n"
    marker = "\n## Generation Checklist"
    base = existing.split(marker)[0].rstrip()
    today = dt.date.today().isoformat()
    lines = [
        base,
        "",
        "## Generation Checklist",
        "",
        f"Updated on {today} by `tools/generate_assets.py`.",
        "",
        "### Generated",
    ]
    generated_list = list(generated)
    skipped_list = list(skipped)
    failed_list = list(failed)
    lines += [f"- [x] `{path}`" for path in generated_list] or ["- None"]
    lines += ["", "### Skipped Existing"]
    lines += [f"- [ ] `{path}`" for path in skipped_list] or ["- None"]
    lines += ["", "### Failed"]
    lines += [f"- [ ] `{path}` — {reason}" for path, reason in failed_list] or ["- None"]
    lines += [""]
    index_path.write_text("\n".join(lines), encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate Gangnam Dream art assets.")
    parser.add_argument("--model", default=os.environ.get("OPENAI_IMAGE_MODEL", "gpt-image-2"))
    parser.add_argument("--quality", default=None, help="Defaults to high for GPT Image, standard for DALL-E 3.")
    parser.add_argument("--force", action="store_true", help="Regenerate files that already exist.")
    parser.add_argument("--dry-run", action="store_true", help="Print planned work without calling the API.")
    parser.add_argument("--limit", type=int, default=None, help="Generate at most N assets, useful for smoke tests.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    quality = args.quality or default_quality_for(args.model)
    worklist = ASSETS[: args.limit] if args.limit else ASSETS

    generated: list[str] = []
    skipped: list[str] = []
    failed: list[tuple[str, str]] = []

    if args.dry_run:
        for index, asset in enumerate(worklist, start=1):
            status = "skip" if Path(asset.path).exists() and not args.force else "generate"
            print(f"{index:02d}. {status}: {asset.path} ({api_size_for(asset, args.model)} -> {OUTPUT_SIZES[asset.category][0]}x{OUTPUT_SIZES[asset.category][1]})")
        return 0

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("Error: OPENAI_API_KEY is not set. No images were generated.")
        return 2

    client = None
    try:
        from openai import OpenAI
    except ImportError:
        print("Warning: Python package 'openai' is not installed; falling back to requests transport.")
    else:
        client = OpenAI(api_key=api_key)
    total = len(worklist)

    for index, asset in enumerate(worklist, start=1):
        dest = Path(asset.path)
        if dest.exists() and not args.force:
            print(f"Skipping [{index}/{total}]: {asset.path} already exists")
            skipped.append(asset.path)
            continue

        print(f"Generating [{index}/{total}]: {asset.path}...")
        try:
            if client is not None:
                raw = generate_image_with_sdk(client, asset, args.model, quality)
            else:
                raw = generate_image_with_requests(api_key, asset, args.model, quality)
            save_output(raw, dest, OUTPUT_SIZES[asset.category])
            generated.append(asset.path)
        except Exception as exc:  # noqa: BLE001 - continue through API and IO failures.
            reason = f"{type(exc).__name__}: {exc}"
            print(f"  Warning: failed to generate {asset.path}: {reason}")
            failed.append((asset.path, reason))
            continue

    write_asset_index(generated, skipped, failed)
    print(f"Done. Generated {len(generated)}, skipped {len(skipped)}, failed {len(failed)}.")
    return 0 if not failed else 1


if __name__ == "__main__":
    raise SystemExit(main())
