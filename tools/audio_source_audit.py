#!/usr/bin/env python3
"""Verify that every shippable audio file has one reproducible project-owned source."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
AUDIO = ROOT / "assets" / "audio"

SOURCE_GROUPS = {
    "tools/generate_audio_assets.py": set("""
bgm_apartment.ogg bgm_crisis.ogg bgm_ending.ogg bgm_gosiwon.ogg
bgm_main.ogg bgm_menu.ogg bgm_victory.ogg
sfx_buy.wav sfx_casino_bet.wav sfx_casino_card.wav sfx_casino_coin.wav
sfx_casino_jackpot.wav sfx_casino_lose.wav sfx_casino_reel.wav
sfx_casino_spin.wav sfx_casino_win.wav sfx_click.wav sfx_event_new.wav
sfx_game_over.wav sfx_housing_up.wav sfx_money_big.wav sfx_money_gain.wav
sfx_money_loss.wav sfx_month.wav sfx_sell.wav sfx_stat_down.wav
sfx_stat_up.wav sfx_success.wav
""".split()),
    "tools/generate_audio_p1_assets.py": set("""
amb_cafe_room.wav amb_casino_floor.wav amb_cherry_blossom.wav
amb_company_dinner.wav amb_convenience_store.wav amb_fine_dust_city.wav
amb_goshiwon_room.wav amb_gym_room.wav amb_hagwon_street.wav
amb_hangang_riverside.wav amb_heatwave_city.wav amb_highway_traffic.wav
amb_jjimjilbang.wav amb_library_room.wav amb_military_gate.wav
amb_office_room.wav amb_open_chat_room.wav amb_pc_bang.wav
amb_public_office.wav amb_racetrack_crowd.wav amb_saju_cafe.wav
amb_school_hall.wav amb_seoul_rain.wav amb_seoul_street.wav
amb_subway_platform.wav sfx_civil_defense_siren.wav
sfx_ending_stinger_bad.wav sfx_ending_stinger_good.wav
sfx_ending_stinger_legend.wav sfx_monsoon_rain.wav
""".split()),
    "tools/generate_gangnam_ui_sfx.py": {
        "sfx_choice_made.wav",
        "sfx_close.wav",
        "sfx_open_modal.wav",
        "sfx_result_human.wav",
        "sfx_result_ledger.wav",
        "sfx_tab_open.wav",
    },
}


def main() -> int:
    actual = {path.name for path in AUDIO.iterdir() if path.suffix.lower() in {".wav", ".ogg"}}
    owners: dict[str, list[str]] = {}
    errors: list[str] = []
    for source, assets in SOURCE_GROUPS.items():
        if not (ROOT / source).is_file():
            errors.append(f"missing source script: {source}")
        for asset in assets:
            owners.setdefault(asset, []).append(source)
    missing = sorted(actual - owners.keys())
    stale = sorted(owners.keys() - actual)
    duplicate = sorted(asset for asset, sources in owners.items() if len(sources) != 1)
    if missing:
        errors.append("audio without source: " + ", ".join(missing))
    if stale:
        errors.append("source ledger references missing audio: " + ", ".join(stale))
    if duplicate:
        errors.append("audio has multiple source owners: " + ", ".join(duplicate))
    if errors:
        for error in errors:
            print("AUDIO_SOURCE_AUDIT_FAIL", error)
        return 1
    print(
        "AUDIO_SOURCE_AUDIT_OK "
        f"assets={len(actual)} bgm={sum(name.startswith('bgm_') for name in actual)} "
        f"ambience={sum(name.startswith('amb_') for name in actual)} "
        f"sfx={sum(name.startswith('sfx_') for name in actual)} external_samples=0"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
