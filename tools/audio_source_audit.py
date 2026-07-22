#!/usr/bin/env python3
"""Verify audio provenance and the release-facing WAV loudness envelope."""

import array
import math
import wave
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
amb_family_home.wav amb_goshiwon_room.wav amb_gym_room.wav amb_hagwon_street.wav
amb_hangang_riverside.wav amb_heatwave_city.wav amb_highway_traffic.wav
amb_jjimjilbang.wav amb_library_room.wav amb_military_gate.wav
amb_office_room.wav amb_open_chat_room.wav amb_pc_bang.wav
amb_oneroom_room.wav amb_apartment_room.wav amb_summer_night.wav
amb_winter_wind.wav
amb_public_office.wav amb_racetrack_crowd.wav amb_saju_cafe.wav
amb_school_hall.wav amb_seoul_rain.wav amb_seoul_street.wav
amb_rain_room.wav
amb_subway_platform.wav sfx_civil_defense_siren.wav
sfx_ending_stinger_bad.wav sfx_ending_stinger_good.wav
sfx_ending_stinger_legend.wav sfx_monsoon_rain.wav
amb_wedding_hall.wav amb_hospital_room.wav amb_seaside.wav
amb_amusement_park.wav amb_car_interior.wav amb_night_bus.wav
amb_train_interior.wav sfx_wedding_applause.wav sfx_wedding_cheer.wav
sfx_distant_fireworks.wav bgm_wedding_processional.ogg bgm_intimate.ogg
bgm_reckoning.ogg bgm_grief.ogg bgm_wonder.ogg
bgm_casino_floor.ogg bgm_casino_table.ogg
sfx_card_shuffle.wav sfx_card_deal.wav sfx_card_flip.wav
sfx_chip_place.wav sfx_chip_collect.wav sfx_dice_cup_shake.wav
sfx_dice_roll.wav sfx_roulette_wheel.wav sfx_roulette_ball.wav
sfx_roulette_land.wav sfx_slot_start.wav sfx_slot_reel_stop.wav
sfx_big_wheel_tick.wav sfx_race_gate.wav sfx_horse_gallop.wav
sfx_race_crowd_rise.wav sfx_race_finish.wav
amb_human_thin_wall.wav amb_human_street.wav
amb_human_public_interior.wav amb_human_cafe.wav
amb_human_casino.wav amb_human_racetrack.wav amb_human_wedding.wav
amb_human_transit.wav amb_human_leisure.wav
bgm_family.ogg bgm_survival.ogg bgm_hyunsu.ogg bgm_ambition.ogg
bgm_daeun.ogg bgm_jiyeon.ogg
sfx_phone_vibrate.wav sfx_phone_notification.wav sfx_paper_handle.wav
sfx_document_stamp.wav sfx_door_latch.wav sfx_footsteps_hall.wav
sfx_register_scan.wav sfx_keyboard_short.wav sfx_cup_set.wav
sfx_bicycle_impact.wav sfx_traffic_pass.wav sfx_kettle_pour.wav
sfx_bus_arrival.wav sfx_queue_chime.wav
""".split()),
    "tools/generate_gangnam_ui_sfx.py": {
        "sfx_choice_made.wav",
        "sfx_close.wav",
        "sfx_open_modal.wav",
        "sfx_result_human.wav",
        "sfx_result_ledger.wav",
        "sfx_tab_open.wav",
    },
    "tools/generate_launch_audio.py": {
        "sfx_publisher_sting.wav",
    },
}

DEMO_LONG_BEDS = set("""
amb_goshiwon_room.wav amb_family_home.wav amb_seoul_rain.wav
amb_hangang_riverside.wav amb_office_room.wav amb_seoul_street.wav
amb_cafe_room.wav amb_convenience_store.wav amb_public_office.wav
amb_winter_wind.wav
""".split())

HUMAN_BEDS = set("""
amb_human_thin_wall.wav amb_human_street.wav amb_human_public_interior.wav
amb_human_cafe.wav amb_human_casino.wav amb_human_racetrack.wav
amb_human_wedding.wav amb_human_transit.wav amb_human_leisure.wav
""".split())

STORY_FOLEY = set("""
sfx_phone_vibrate.wav sfx_phone_notification.wav sfx_paper_handle.wav
sfx_document_stamp.wav sfx_door_latch.wav sfx_footsteps_hall.wav
sfx_register_scan.wav sfx_keyboard_short.wav sfx_cup_set.wav
sfx_bicycle_impact.wav sfx_traffic_pass.wav sfx_kettle_pour.wav
sfx_bus_arrival.wav sfx_queue_chime.wav
""".split())


def wav_metrics(path: Path) -> tuple[float, float, float]:
    with wave.open(str(path), "rb") as handle:
        channels = handle.getnchannels()
        sample_width = handle.getsampwidth()
        frame_rate = handle.getframerate()
        frames = handle.getnframes()
        payload = handle.readframes(frames)
    if channels not in {1, 2} or sample_width != 2 or frame_rate <= 0 or frames <= 0:
        raise ValueError(
            f"unsupported WAV format channels={channels} width={sample_width} "
            f"rate={frame_rate} frames={frames}"
        )
    samples = array.array("h")
    samples.frombytes(payload)
    if not samples:
        raise ValueError("empty WAV payload")
    energy = sum(float(sample) * float(sample) for sample in samples) / len(samples)
    rms = math.sqrt(energy) / 32768.0
    peak = max(abs(sample) for sample in samples) / 32768.0
    rms_db = 20.0 * math.log10(max(rms, 1.0e-12))
    return frames / frame_rate, rms_db, peak


def check_release_wavs(errors: list[str]) -> None:
    for name in sorted(DEMO_LONG_BEDS | HUMAN_BEDS | STORY_FOLEY):
        path = AUDIO / name
        if not path.is_file():
            continue
        try:
            duration, rms_db, peak = wav_metrics(path)
        except (ValueError, wave.Error) as exc:
            errors.append(f"{name}: cannot inspect WAV: {exc}")
            continue
        if name in DEMO_LONG_BEDS:
            if duration < 18.0:
                errors.append(f"{name}: demo ambience {duration:.2f}s < 18.0s")
            if not -40.0 <= rms_db <= -24.0:
                errors.append(f"{name}: demo ambience RMS {rms_db:.1f}dB outside -40..-24")
        elif name in HUMAN_BEDS:
            if duration < 16.0:
                errors.append(f"{name}: human ambience {duration:.2f}s < 16.0s")
            if not -43.0 <= rms_db <= -29.0:
                errors.append(f"{name}: human ambience RMS {rms_db:.1f}dB outside -43..-29")
        else:
            if not 0.18 <= duration <= 3.2:
                errors.append(f"{name}: story foley duration {duration:.2f}s outside 0.18..3.2s")
            if not -34.0 <= rms_db <= -14.0:
                errors.append(f"{name}: story foley RMS {rms_db:.1f}dB outside -34..-14")
        if peak >= 0.999:
            errors.append(f"{name}: clipped peak {peak:.4f}")


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
    check_release_wavs(errors)
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
