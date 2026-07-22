#!/usr/bin/env python3
"""Build release audio from licensed recordings and real-instrument samples.

This builder never creates a source waveform. It only decodes, edits, layers,
loops, and mixes recorded material. The external source libraries deliberately
stay outside the repository; the generated provenance manifest records every
source file and transform used by each shipping asset.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import random
import re
import shutil
import subprocess
import sys
import tempfile
import wave
from dataclasses import dataclass
from pathlib import Path
from typing import Any

try:
    import numpy as np
except ModuleNotFoundError:
    bundled = (
        Path.home()
        / ".cache/codex-runtimes/codex-primary-runtime/dependencies/python"
    )
    if bundled.is_dir():
        sys.path.insert(0, str(bundled))
    import numpy as np


ROOT = Path(__file__).resolve().parents[1]
AUDIO_DIR = ROOT / "assets" / "audio"
DEFAULT_SOURCE_ROOT = Path("/tmp/gangnam-audio-sources")
FFMPEG_CANDIDATES = (
    ROOT / "build/trailer-tools/imageio_ffmpeg/binaries/ffmpeg-macos-aarch64-v7.1",
    Path("/Applications/CapCut.app/Contents/Resources/ffmpeg"),
)


PACKS: dict[str, dict[str, Any]] = {
    "sonniss_gdc_2026": {
        "root": "sonniss-2026/extracted",
        "provider": "Sonniss",
        "title": "GDC 2026 Game Audio Bundle",
        "source_type": "field_recording",
        "license": "Sonniss GDC Game Audio Bundle License",
        "license_url": "https://sonniss.com/gdc-bundle-license/",
        "source_url": "https://gdc.sonniss.com/",
        "attribution_required": False,
    },
    "owlish_cc0": {
        "root": "owlish/extracted",
        "provider": "OwlishMedia",
        "title": "Owlish Media Sound Effects",
        "source_type": "field_recording",
        "license": "CC0 1.0",
        "license_url": "https://creativecommons.org/publicdomain/zero/1.0/",
        "source_url": "https://opengameart.org/content/sound-effects-pack",
        "attribution_required": False,
    },
    "kenney_casino_cc0": {
        "root": "kenney/extracted",
        "provider": "Kenney Vleugels",
        "title": "Casino Audio 1.1",
        "source_type": "object_recording",
        "license": "CC0 1.0",
        "license_url": "https://creativecommons.org/publicdomain/zero/1.0/",
        "source_url": "https://lpc.opengameart.org/content/54-casino-sound-effects-cards-dice-chips",
        "attribution_required": False,
    },
    "horse_gallop": {
        "root": "horse/extracted",
        "provider": "congusbongus and credited source recordists",
        "title": "Horse gallop on different surfaces",
        "source_type": "field_recording",
        "license": "CC BY 4.0",
        "license_url": "https://creativecommons.org/licenses/by/4.0/",
        "source_url": "https://opengameart.org/content/horse-gallop-on-different-surfaces",
        "attribution_required": True,
    },
    "salamander_piano": {
        "root": "salamander/SalamanderGrandPianoV3_44.1khz16bit/44.1khz16bit",
        "provider": "Alexander Holm",
        "title": "Salamander Grand Piano V3 (Yamaha C5)",
        "source_type": "real_instrument_sample",
        "license": "CC BY 3.0",
        "license_url": "https://creativecommons.org/licenses/by/3.0/",
        "source_url": "https://sfzlab.github.io/sfz-website/instruments/alexander-holm/salamander-grand-piano/",
        "attribution_required": True,
    },
    "unicae_keyboard_cc0": {
        "root": "keyboard/extracted",
        "provider": "unicaegames",
        "title": "Keyboard Soundpack #1",
        "source_type": "object_recording",
        "license": "CC0 1.0",
        "license_url": "https://creativecommons.org/publicdomain/zero/1.0/",
        "source_url": "https://opengameart.org/content/keyboard-soundpack-1-typing-and-single-keystrokes",
        "attribution_required": False,
    },
    "tinyworlds_siren_cc0": {
        "root": "siren",
        "provider": "TinyWorlds",
        "title": "Storm & Siren",
        "source_type": "field_recording",
        "license": "CC0 1.0",
        "license_url": "https://creativecommons.org/publicdomain/zero/1.0/",
        "source_url": "https://lpc.opengameart.org/content/storm-siren",
        "attribution_required": False,
    },
    "qubodup_crash_cc0": {
        "root": "crash",
        "provider": "qubodup",
        "title": "Crash Collision",
        "source_type": "object_recording",
        "license": "CC0 1.0",
        "license_url": "https://creativecommons.org/publicdomain/zero/1.0/",
        "source_url": "https://opengameart.org/content/crash-collision",
        "attribution_required": False,
    },
}


def _sonniss(folder: str, filename: str) -> tuple[str, str]:
    return "sonniss_gdc_2026", f"{folder}/{filename}"


SOURCES: dict[str, tuple[str, str]] = {
    "clock": ("owlish_cc0", "Ambience/loopable-ticking-clock.wav"),
    "crickets": ("owlish_cc0", "Ambience/night-crickets-ambience-on-rural-property.wav"),
    "blanket_1": ("owlish_cc0", "Cloth, Rustle/320137__owlstorm__blanket-movement-1.wav"),
    "blanket_2": ("owlish_cc0", "Cloth, Rustle/320138__owlstorm__blanket-movement-2.wav"),
    "foot_hard_1": ("owlish_cc0", "Footsteps/hard-footstep1.wav"),
    "foot_hard_2": ("owlish_cc0", "Footsteps/hard-footstep2.wav"),
    "foot_hard_3": ("owlish_cc0", "Footsteps/hard-footstep3.wav"),
    "foot_hard_4": ("owlish_cc0", "Footsteps/hard-footstep4.wav"),
    "foot_women_1": ("owlish_cc0", "Footsteps/Womens_shoes_1.wav"),
    "impact_tap": ("owlish_cc0", "Impacts/tap.wav"),
    "impact_clamour": ("owlish_cc0", "Impacts/clamour3.wav"),
    "paper_page": ("owlish_cc0", "Paper/pageturn1.wav"),
    "paper_crumple": ("owlish_cc0", "Paper/crumples1.wav"),
    "pencil": ("owlish_cc0", "Paper/pencil-scratch-1.wav"),
    "phone_vibrate": ("owlish_cc0", "Technology/Phone_vibrate.wav"),
    "phone_ring": ("owlish_cc0", "Technology/Phonering-otherend.wav"),
    "mouse_clicks": ("owlish_cc0", "Technology/mouse-clicks-scrolls.wav"),
    "water_pour": ("owlish_cc0", "Water/tap-water-1.wav"),
    "kettle": ("owlish_cc0", "Water/kettle-boil.wav"),
    "solo_clap": ("owlish_cc0", "Human/solo-clap.wav"),
    "typing": ("unicae_keyboard_cc0", "Human Typing/human_vel-004.wav"),
    "keypress": ("unicae_keyboard_cc0", "Single Keys/keypress-012.wav"),
    "casino_card_shuffle": ("kenney_casino_cc0", "Audio/card-shuffle.ogg"),
    "casino_card_place": ("kenney_casino_cc0", "Audio/card-place-2.ogg"),
    "casino_card_slide": ("kenney_casino_cc0", "Audio/card-slide-4.ogg"),
    "casino_card_fan": ("kenney_casino_cc0", "Audio/card-fan-1.ogg"),
    "casino_chip_lay": ("kenney_casino_cc0", "Audio/chip-lay-2.ogg"),
    "casino_chips": ("kenney_casino_cc0", "Audio/chips-handle-3.ogg"),
    "casino_chips_collide": ("kenney_casino_cc0", "Audio/chips-collide-2.ogg"),
    "casino_dice_shake": ("kenney_casino_cc0", "Audio/dice-shake-2.ogg"),
    "casino_dice_throw": ("kenney_casino_cc0", "Audio/dice-throw-2.ogg"),
    "horse_ground": ("horse_gallop", "ground.mp3"),
    "horse_grass": ("horse_gallop", "grass.mp3"),
    "civil_siren": ("tinyworlds_siren_cc0", "storm_3_siren.ogg"),
    "bicycle_crash": ("qubodup_crash_cc0", "qubodup-crash.ogg"),
    "paper_a4": _sonniss(
        "Cinematic Sound Design - Paper Foley",
        "A4 Printing Paper Rattle Page Turn Tail.wav",
    ),
    "paper_book": _sonniss(
        "Cinematic Sound Design - Paper Foley",
        "Encyclopedia Glossy Page Turn Muted.wav",
    ),
    "analog_click": _sonniss(
        "Epic Stock Media - Board Game - Sound Set Kit for Tabletop and Digital Games",
        "UIClick_UI Button Analog Vintage Double Click Neutral Dry Press 11_ESM_BG.wav",
    ),
    "board_reset": _sonniss(
        "Epic Stock Media - Board Game - Sound Set Kit for Tabletop and Digital Games",
        "GAMEBoard_Event Board Reset Organic Multiple Pieces Wood Small 02_ESM_BG.wav",
    ),
    "board_piece": _sonniss(
        "Epic Stock Media - Board Game - Sound Set Kit for Tabletop and Digital Games",
        "GAMEBoard_Game Play Piece Action Organic Connect Dots Fall Bounce 04_ESM_BG.wav",
    ),
    "coin_flip": _sonniss(
        "Cinematic Sound Design - Hybrid Game & UI Elements",
        "Foley Coin Flip Single Fast.wav",
    ),
    "latch": _sonniss(
        "Epic Stock Media - HD Lock And Mechanism Sound Design Kit",
        "MECHLtch_Click Deep Mechanism Latch Button Nearfield Thunk 02_ESM_HDLM.wav",
    ),
    "counting_machine": _sonniss(
        "Epic Stock Media - HD Lock And Mechanism Sound Design Kit",
        "MACHMech_Mechanism Counting Machine Interact Loose Container Short 01_ESM_HDLM.wav",
    ),
    "tape_measure": _sonniss(
        "Epic Stock Media - HD Lock And Mechanism Sound Design Kit",
        "MECHMisc_Tool Tape Measure Pull Retract Spring Slide Spin Long 07_ESM_HDLM.wav",
    ),
    "light_switch": _sonniss(
        "InMotionAudio - USA Hotel",
        "MECHClik_USALightSwitch_On05_InMotionAudio_USAHotel.wav",
    ),
    "door": _sonniss(
        "InMotionAudio - USA Hotel",
        "DOORMetl_StairWellDoor01_InMotionAudio_USAHotel.wav",
    ),
    "radio_wheel": _sonniss(
        "Sonic Bat - Vintage Radio",
        "SBvr_Mode Select Wheel 006.wav",
    ),
    "thermometer_beep": _sonniss(
        "InMotionAudio - Medical Thermometer",
        "BEEPMed_Thermometer_Beep11_InMotionAudio_MedicalThermometer.wav",
    ),
    "car_door": _sonniss(
        "SoundBits - Cars - Mad Mustang Mercury",
        "VEHDoor_Car Foley Car Door Open and Close Exterior 04 Perspective A_SNDBTS_CRS-MMM.wav",
    ),
    "traffic": _sonniss(
        "SoundBits - Pass-By - Trains, Trucks & Cars 2",
        "AMBTraf_Traffic Multiple Cars Passing By 25_SNDBTS_PB-TTC2.wav",
    ),
    "truck_pass": _sonniss(
        "SoundBits - Pass-By - Trains, Trucks & Cars 2",
        "VEHFrght_Freight Truck Pass By 22_SNDBTS_PB-TTC2.wav",
    ),
    "train_pass": _sonniss(
        "Epic Stock Media - Public Spaces - Basic Transportation Sounds",
        "TRNElec_Electric Train Passby 02 Long Subway Slow_ESM_CPS.wav",
    ),
    "car_interior_1": _sonniss(
        "InMotionAudio - Car Interior Driving Ambience",
        "VEHCar_TownDrivingAmbience06_InMotionAudio_CarInteriorDrivingAmbience.wav",
    ),
    "car_interior_2": _sonniss(
        "InMotionAudio - Car Interior Driving Ambience",
        "VEHCar_TownDrivingAmbience13_InMotionAudio_CarInteriorDrivingAmbience.wav",
    ),
    "electric_hum": _sonniss(
        "344 Audio - East Coast America Vol. 1",
        "AMBSubn_Electricity Hum, Lightbulb,  Coil Pickup 01_344 Audio_East Coast America.wav",
    ),
    "fridge_hum": _sonniss(
        "Jake Fielding - Fridge Hums Vol.2",
        "MACHAppl_Deep Fridge Hum, Buzz, Electric Tone, Deep_Jake Fielding_Fridge Hums Pt2.wav",
    ),
    "fridge_rhythm": _sonniss(
        "Jake Fielding - Fridge Hums Vol.2",
        "MACHAppl_Rhythmic Electric Fridge Hum, Buzz, Static,_Jake Fielding_Fridge Hums Pt2.wav",
    ),
    "rain_city": _sonniss(
        "The Noisery - City Rain",
        "RAINConc_Rain Medium Exterior Splatter City Traffic 6_The Noisery_City Rain.wav",
    ),
    "rain_window": _sonniss(
        "The Noisery - City Rain",
        "RAINInt_Rain Light Interior Hail Storm_The Noisery_City Rain.wav",
    ),
    "storm_city": _sonniss(
        "Sonic Bat - Stormy Night Ambience",
        "SBsna_City Block Square Storm 003.wav",
    ),
    "city_day": _sonniss(
        "Epic Stock Media - Public Spaces - Urban Life Exteriors",
        "AMBTown_City Courtyard Calm Street Distant Traffic Children Playing 03_ESM_CPS.wav",
    ),
    "city_night": _sonniss(
        "Epic Stock Media - Public Spaces - Urban Life Exteriors",
        "AMBUrbn_City Nightlife Ext Street In Reutersplatz German Walla Traffic 01_ESM_CPS.wav",
    ),
    "city_park": _sonniss(
        "Epic Stock Media - Public Spaces - Storms Lakes Parks and Rural Nature Exteriors",
        "AMBPark_Berlin City Humboldthain Park Strong Wind On Trees Foliage Traffic Wash 03_ESM_CPS.wav",
    ),
    "metro_hall": _sonniss(
        "Epic Stock Media - Public Spaces - Crowds Walla and Everyday Ambiences",
        "AMBPubl_Metro Station Entrance Hall Dings Walla Footsteps 01 Women Shopping_ESM_CPS.wav",
    ),
    "train_interior_1": _sonniss(
        "InMotionAudio - The Commute",
        "AMBTran_TrainInterior09_InMotionAudio_UKTrainInteriorAmbience.wav",
    ),
    "train_interior_2": _sonniss(
        "InMotionAudio - The Commute",
        "AMBTran_TrainInterior12_InMotionAudio_UKTrainInteriorAmbience.wav",
    ),
    "bar_walla": _sonniss(
        "Sonic Bat - Bars & Restaurants Ambience",
        "SBbra_Bar E 001.wav",
    ),
    "food_court": _sonniss(
        "Sonic Bat - Bars & Restaurants Ambience",
        "SBbra_Shopping Mall Food Court B 001.wav",
    ),
    "restaurant_walla": _sonniss(
        "Jake Fielding - British Walla and Crowd",
        "CRWDWalla_Pub Walla Atmos, Restaurant, Liverpool, Scouse,_Jake Fielding_11.wav",
    ),
    "public_crowd": _sonniss(
        "Epic Stock Media - Public Spaces - Crowds Walla and Everyday Ambiences",
        "AMBPubl_Cruise Ship Walla Distant Adults Children Laughing Screaming 4_ESM_CPS.wav",
    ),
    "sports_crowd": _sonniss(
        "Sonic Bat - Volleyball Match Ambience",
        "SBvma_Feminine League Match 017.wav",
    ),
    "sports_crowd_2": _sonniss(
        "Sonic Bat - Volleyball Match Ambience",
        "SBvma_Masculine Regional Match 005.wav",
    ),
    "pool_crowd": _sonniss(
        "Sonic Bat - Swimming Pool Ambience",
        "SBspa_Water Polo Feminine League Match Presentation 001.wav",
    ),
    "meadow": _sonniss(
        "Just Sound Effects - Highlands of Norway",
        "AMBSwmp_Meadow Pipits calling many Insects humming Wind blowing through Grass_JSE_HoN_Stereo.wav",
    ),
    "waves_soft": _sonniss(
        "Just Sound Effects - Rocky Coast of Norway",
        "WATRWave_Soft Waves Cliffs_JSE_RCoN_Stereo.wav",
    ),
    "waves_medium": _sonniss(
        "Just Sound Effects - Rocky Coast of Norway",
        "WATRWave_Medium Waves at Pebble Beach_JSE_RCoN_Stereo.wav",
    ),
    "chimney_wind": _sonniss(
        "InMotionAudio - Chimney Wind",
        "WINDInt_ChimneyWind05_InMotionAudio_ChimneyWind.wav",
    ),
    "fireworks_distant": _sonniss(
        "Sonic Bat - Fireworks Ambience",
        "SBfa_Distant Fireworks 005.wav",
    ),
    "fireworks_near": _sonniss(
        "Sonic Bat - Fireworks Ambience",
        "SBfa_Fireworks 001.wav",
    ),
    "casino_shuffler": _sonniss(
        "344 Audio - Casino Cards Vol. 1",
        "GAMECas_Automatic Shuffler, Shuffling 1_344 Audio_Casino Cards Vol 1.wav",
    ),
    "casino_deal": _sonniss(
        "344 Audio - Casino Cards Vol. 1",
        "GAMECas_Dealing 3_344 Audio_Casino Cards Vol 1.wav",
    ),
    "casino_pickup": _sonniss(
        "344 Audio - Casino Cards Vol. 1",
        "GAMECas_Pick Up Multiple Cards At Once 5_344 Audio_Casino Cards Vol 1.wav",
    ),
}


@dataclass(frozen=True)
class Layer:
    source: str
    gain_db: float = 0.0
    start: float = 0.0
    highpass: int = 35
    lowpass: int = 10500


def L(source: str, gain: float = 0.0, start: float = 0.0,
      highpass: int = 35, lowpass: int = 10500) -> Layer:
    return Layer(source, gain, start, highpass, lowpass)


AMBIENCE_RECIPES: dict[str, list[Layer]] = {
    "amb_goshiwon_room.wav": [L("fridge_hum", -3, 8, 35, 6500), L("clock", -18, 2, 80, 7000)],
    "amb_family_home.wav": [L("electric_hum", -7, 1, 35, 6500), L("clock", -16, 7, 90, 6500)],
    "amb_rain_room.wav": [L("rain_window", -2, 12, 60, 10000), L("fridge_hum", -15, 22, 35, 5000)],
    "amb_seoul_rain.wav": [L("rain_city", 0, 26, 45, 11000), L("traffic", -12, 4, 70, 6500)],
    "amb_hangang_riverside.wav": [L("waves_soft", -2, 20, 45, 9500), L("city_park", -12, 41, 80, 6500)],
    "amb_office_room.wav": [L("electric_hum", -7, 8, 40, 6500), L("typing", -18, 0, 130, 7500)],
    "amb_casino_floor.wav": [L("food_court", -4, 177, 90, 6000), L("casino_shuffler", -18, 0, 100, 8000)],
    "amb_seoul_street.wav": [L("city_night", -2, 68, 55, 6500), L("traffic", -10, 16, 80, 7000)],
    "amb_subway_platform.wav": [L("metro_hall", -1, 24, 60, 7500), L("train_pass", -10, 8, 45, 7500)],
    "amb_racetrack_crowd.wav": [L("sports_crowd", -2, 112, 70, 7000), L("horse_ground", -18, 0, 90, 6500)],
    "amb_cafe_room.wav": [L("bar_walla", -3, 94, 100, 5200)],
    "amb_pc_bang.wav": [L("electric_hum", -7, 13, 45, 6500), L("typing", -14, 0, 150, 7800)],
    "amb_gym_room.wav": [L("sports_crowd_2", -7, 82, 90, 5200), L("foot_hard_2", -18, 0, 90, 7000)],
    "amb_convenience_store.wav": [L("fridge_rhythm", -2, 15, 40, 6500), L("food_court", -18, 244, 180, 4200)],
    "amb_hagwon_street.wav": [L("city_day", -3, 73, 60, 7000), L("traffic", -13, 30, 90, 6500)],
    "amb_school_hall.wav": [L("metro_hall", -8, 42, 100, 5200), L("foot_women_1", -18, 0, 100, 7000)],
    "amb_public_office.wav": [L("metro_hall", -7, 9, 100, 5200), L("electric_hum", -15, 17, 40, 5500)],
    "amb_jjimjilbang.wav": [L("pool_crowd", -9, 123, 120, 5000), L("water_pour", -20, 0, 180, 6500)],
    "amb_cherry_blossom.wav": [L("city_park", -2, 23, 65, 8500), L("city_day", -14, 91, 100, 6000)],
    "amb_saju_cafe.wav": [L("restaurant_walla", -8, 24, 140, 4200), L("clock", -19, 3, 100, 6500)],
    "amb_military_gate.wav": [L("city_park", -7, 88, 65, 7500), L("chimney_wind", -8, 10, 70, 7000)],
    "amb_company_dinner.wav": [L("bar_walla", -2, 238, 100, 5200)],
    "amb_heatwave_city.wav": [L("city_day", -2, 119, 60, 7500), L("crickets", -17, 10, 140, 7500)],
    "amb_fine_dust_city.wav": [L("city_night", -6, 116, 70, 4800), L("traffic", -11, 39, 90, 5200)],
    "amb_highway_traffic.wav": [L("traffic", -2, 5, 55, 9000), L("car_interior_2", -10, 7, 40, 6500)],
    "amb_open_chat_room.wav": [L("electric_hum", -4, 3, 35, 5600), L("keypress", -24, 0, 150, 7500)],
    "amb_library_room.wav": [L("electric_hum", -10, 16, 35, 4800), L("paper_book", -22, 0, 140, 7000)],
    "amb_oneroom_room.wav": [L("fridge_rhythm", -5, 33, 35, 5800), L("city_night", -20, 102, 100, 4200)],
    "amb_apartment_room.wav": [L("electric_hum", -9, 19, 35, 5200), L("city_day", -21, 47, 120, 4200)],
    "amb_summer_night.wav": [L("crickets", -1, 12, 100, 9000), L("city_night", -17, 81, 100, 5000)],
    "amb_winter_wind.wav": [L("chimney_wind", -1, 6, 55, 8500), L("city_night", -20, 31, 120, 4200)],
    "amb_wedding_hall.wav": [L("sports_crowd", -8, 184, 100, 4800), L("bar_walla", -12, 321, 150, 4200)],
    "amb_hospital_room.wav": [L("electric_hum", -8, 27, 35, 5000), L("fridge_hum", -13, 41, 35, 4200)],
    "amb_seaside.wav": [L("waves_medium", -1, 16, 40, 10000), L("meadow", -18, 64, 130, 6500)],
    "amb_amusement_park.wav": [L("public_crowd", -4, 72, 100, 6200), L("city_park", -13, 39, 100, 6500)],
    "amb_car_interior.wav": [L("car_interior_1", -1, 9, 35, 8500)],
    "amb_night_bus.wav": [L("car_interior_2", -2, 19, 35, 7200), L("city_night", -20, 126, 160, 4000)],
    "amb_train_interior.wav": [L("train_interior_1", -1, 8, 35, 8500), L("train_interior_2", -11, 18, 80, 5500)],
    "amb_human_thin_wall.wav": [L("metro_hall", -4, 53, 180, 2600)],
    "amb_human_street.wav": [L("city_day", -3, 127, 160, 3600)],
    "amb_human_public_interior.wav": [L("metro_hall", -2, 31, 170, 3400)],
    "amb_human_cafe.wav": [L("restaurant_walla", -2, 46, 180, 3200)],
    "amb_human_casino.wav": [L("food_court", -2, 391, 170, 3400)],
    "amb_human_racetrack.wav": [L("sports_crowd_2", -2, 148, 120, 4200)],
    "amb_human_wedding.wav": [L("sports_crowd", -3, 214, 140, 3800)],
    "amb_human_transit.wav": [L("train_interior_2", -2, 22, 110, 3800)],
    "amb_human_leisure.wav": [L("public_crowd", -3, 98, 140, 3900)],
}


SFX_RECIPES: dict[str, dict[str, Any]] = {
    "sfx_click.wav": {"layers": [L("casino_card_place")], "max": 0.18, "db": -23},
    "sfx_close.wav": {"layers": [L("latch")], "max": 0.28, "db": -21},
    "sfx_open_modal.wav": {"layers": [L("paper_book")], "max": 0.34, "db": -24},
    "sfx_tab_open.wav": {"layers": [L("casino_card_slide")], "max": 0.22, "db": -24},
    "sfx_month.wav": {"layers": [L("paper_page")], "max": 0.75, "db": -22},
    "sfx_money_gain.wav": {"layers": [L("coin_flip")], "max": 0.52, "db": -21},
    "sfx_money_loss.wav": {"layers": [L("board_piece")], "max": 0.52, "db": -21},
    "sfx_money_big.wav": {"layers": [L("casino_chips_collide")], "max": 0.85, "db": -20},
    "sfx_buy.wav": {"layers": [L("casino_chip_lay")], "max": 0.30, "db": -22},
    "sfx_sell.wav": {"layers": [L("casino_card_slide")], "max": 0.32, "db": -22},
    "sfx_stat_up.wav": {"layers": [L("paper_page")], "max": 0.30, "db": -25},
    "sfx_stat_down.wav": {"layers": [L("paper_crumple")], "max": 0.38, "db": -24},
    "sfx_event_new.wav": {"layers": [L("pencil")], "max": 0.46, "db": -24},
    "sfx_choice_made.wav": {"layers": [L("analog_click")], "max": 0.22, "db": -23},
    "sfx_result_ledger.wav": {"layers": [L("counting_machine")], "max": 0.35, "db": -22},
    "sfx_result_human.wav": {"layers": [L("blanket_1")], "max": 0.48, "db": -26},
    "sfx_housing_up.wav": {"layers": [L("door")], "max": 1.15, "db": -21},
    "sfx_game_over.wav": {"layers": [L("car_door")], "max": 1.35, "db": -19},
    "sfx_success.wav": {"layers": [L("casino_chips")], "max": 0.72, "db": -21},
    "sfx_casino_win.wav": {"layers": [L("casino_chips_collide")], "max": 0.78, "db": -20},
    "sfx_casino_lose.wav": {"layers": [L("board_piece")], "max": 0.62, "db": -21},
    "sfx_casino_bet.wav": {"layers": [L("casino_chip_lay")], "max": 0.32, "db": -21},
    "sfx_casino_coin.wav": {"layers": [L("coin_flip")], "max": 0.36, "db": -22},
    "sfx_casino_spin.wav": {"layers": [L("radio_wheel")], "max": 0.75, "db": -21},
    "sfx_casino_card.wav": {"layers": [L("casino_card_place")], "max": 0.27, "db": -22},
    "sfx_casino_jackpot.wav": {"layers": [L("casino_chips_collide"), L("casino_chips", -5)], "max": 1.10, "db": -18},
    "sfx_casino_reel.wav": {"layers": [L("counting_machine")], "max": 0.38, "db": -22},
    "sfx_civil_defense_siren.wav": {"layers": [L("civil_siren", 0, 22)], "max": 3.0, "db": -20},
    "sfx_monsoon_rain.wav": {"layers": [L("rain_city", 0, 44)], "max": 3.0, "db": -25},
    "sfx_wedding_applause.wav": {"layers": [L("sports_crowd", 0, 18)], "max": 3.0, "min": 2.4, "db": -22},
    "sfx_wedding_cheer.wav": {"layers": [L("sports_crowd_2", 0, 186)], "max": 3.0, "min": 2.4, "db": -22},
    "sfx_distant_fireworks.wav": {"layers": [L("fireworks_distant", 0, 14)], "max": 4.0, "db": -24},
    "sfx_card_shuffle.wav": {"layers": [L("casino_card_shuffle")], "max": 1.25, "db": -20},
    "sfx_card_deal.wav": {"layers": [L("casino_deal")], "max": 0.46, "db": -21},
    "sfx_card_flip.wav": {"layers": [L("casino_card_fan")], "max": 0.42, "db": -22},
    "sfx_chip_place.wav": {"layers": [L("casino_chip_lay")], "max": 0.34, "db": -21},
    "sfx_chip_collect.wav": {"layers": [L("casino_chips")], "max": 0.85, "db": -20},
    "sfx_dice_cup_shake.wav": {"layers": [L("casino_dice_shake")], "max": 1.15, "db": -20},
    "sfx_dice_roll.wav": {"layers": [L("casino_dice_throw")], "max": 0.72, "db": -20},
    "sfx_roulette_wheel.wav": {"layers": [L("radio_wheel")], "max": 1.15, "db": -23},
    "sfx_roulette_ball.wav": {"layers": [L("casino_dice_throw")], "max": 0.30, "db": -23},
    "sfx_roulette_land.wav": {"layers": [L("casino_chip_lay")], "max": 0.30, "db": -21},
    "sfx_slot_start.wav": {"layers": [L("tape_measure")], "max": 0.75, "db": -22},
    "sfx_slot_reel_stop.wav": {"layers": [L("latch")], "max": 0.28, "db": -21},
    "sfx_big_wheel_tick.wav": {"layers": [L("light_switch")], "max": 0.22, "db": -22},
    "sfx_race_gate.wav": {"layers": [L("car_door")], "max": 0.72, "db": -19},
    "sfx_horse_gallop.wav": {"layers": [L("horse_ground")], "max": 2.4, "min": 2.2, "loop": True, "db": -20},
    "sfx_race_crowd_rise.wav": {"layers": [L("sports_crowd", 0, 132)], "max": 2.8, "db": -23},
    "sfx_race_finish.wav": {"layers": [L("sports_crowd_2", 0, 184)], "max": 3.0, "db": -21},
    "sfx_phone_vibrate.wav": {"layers": [L("phone_vibrate")], "max": 1.25, "db": -22},
    "sfx_phone_notification.wav": {"layers": [L("phone_ring")], "max": 0.75, "db": -25},
    "sfx_paper_handle.wav": {"layers": [L("paper_a4")], "max": 0.82, "db": -23},
    "sfx_document_stamp.wav": {"layers": [L("impact_tap")], "max": 0.42, "db": -21},
    "sfx_door_latch.wav": {"layers": [L("door")], "max": 1.10, "db": -22},
    "sfx_footsteps_hall.wav": {"layers": [L("foot_hard_1"), L("foot_hard_3", -3)], "max": 1.45, "db": -23},
    "sfx_register_scan.wav": {"layers": [L("thermometer_beep")], "max": 0.44, "db": -26},
    "sfx_keyboard_short.wav": {"layers": [L("typing")], "max": 1.15, "db": -24},
    "sfx_cup_set.wav": {"layers": [L("impact_tap")], "max": 0.36, "db": -24},
    "sfx_bicycle_impact.wav": {"layers": [L("bicycle_crash"), L("blanket_2", -8)], "max": 1.45, "db": -19},
    "sfx_traffic_pass.wav": {"layers": [L("traffic", 0, 7)], "max": 2.6, "db": -24},
    "sfx_kettle_pour.wav": {"layers": [L("water_pour")], "max": 2.5, "db": -24},
    "sfx_bus_arrival.wav": {"layers": [L("truck_pass")], "max": 2.8, "db": -23},
    "sfx_queue_chime.wav": {"layers": [L("thermometer_beep")], "max": 0.45, "db": -28},
}


TRACK_SPECS: dict[str, dict[str, Any]] = {
    "bgm_menu.ogg": {"bpm": 66, "pattern": "open", "progression": [["D3","A3","D4","F4"],["Bb2","F3","Bb3","D4"],["F3","C4","F4","A4"],["C3","G3","C4","E4"]], "motif": ["A4","F4","D4","E4"], "db": -24},
    "bgm_gosiwon.ogg": {"bpm": 62, "pattern": "sparse", "progression": [["A2","E3","A3","C4"],["F2","C3","F3","A3"],["C3","G3","C4","E4"],["G2","D3","G3","B3"]], "motif": ["E4","C4","B3","A3"], "db": -25},
    "bgm_main.ogg": {"bpm": 76, "pattern": "walk", "progression": [["F2","C3","F3","Ab3"],["Db2","Ab2","Db3","F3"],["Eb2","Bb2","Eb3","G3"],["C2","G2","C3","Eb3"]], "motif": ["C4","Ab3","G3","F3"], "db": -24},
    "bgm_apartment.ogg": {"bpm": 72, "pattern": "open", "progression": [["C2","G2","C3","Eb3"],["Ab2","Eb3","Ab3","C4"],["Bb2","F3","Bb3","D4"],["G2","D3","G3","B3"]], "motif": ["Eb4","D4","C4","B3"], "db": -25},
    "bgm_crisis.ogg": {"bpm": 58, "pattern": "sparse", "progression": [["D2","A2","D3","F3"],["C#2","A2","C#3","E3"],["Bb1","F2","Bb2","D3"],["A1","E2","A2","C#3"]], "motif": ["F4","E4","D4","C#4"], "db": -25},
    "bgm_ending.ogg": {"bpm": 60, "pattern": "sparse", "progression": [["A2","E3","A3","C4"],["F2","C3","F3","A3"],["D2","A2","D3","F3"],["E2","B2","E3","G#3"]], "motif": ["C5","B4","A4","G#4"], "db": -25},
    "bgm_victory.ogg": {"bpm": 68, "pattern": "open", "progression": [["C3","G3","C4","E4"],["G2","D3","G3","B3"],["A2","E3","A3","C4"],["F2","C3","F3","A3"]], "motif": ["E4","G4","A4","C5"], "loop": False, "db": -24},
    "bgm_wedding_processional.ogg": {"bpm": 64, "pattern": "procession", "progression": [["C3","G3","C4","E4"],["F2","C3","F3","A3"],["A2","E3","A3","C4"],["G2","D3","G3","B3"]], "motif": ["G4","C5","B4","E5"], "db": -23},
    "bgm_intimate.ogg": {"bpm": 56, "pattern": "sparse", "progression": [["F2","C3","F3","A3"],["C3","G3","C4","E4"],["D3","A3","D4","F4"],["Bb2","F3","Bb3","D4"]], "motif": ["A4","G4","F4","D4"], "db": -26},
    "bgm_reckoning.ogg": {"bpm": 60, "pattern": "open", "progression": [["C2","G2","C3","Eb3"],["B1","F#2","B2","D3"],["Ab1","Eb2","Ab2","C3"],["G1","D2","G2","B2"]], "motif": ["G4","F#4","Eb4","D4"], "db": -25},
    "bgm_grief.ogg": {"bpm": 52, "pattern": "sparse", "progression": [["A2","E3","A3","C4"],["C3","G3","C4","E4"],["F2","C3","F3","A3"],["E2","B2","E3","G#3"]], "motif": ["E4","C4","A3","G#3"], "db": -27},
    "bgm_wonder.ogg": {"bpm": 62, "pattern": "open", "progression": [["C3","G3","C4","E4"],["D3","A3","D4","F#4"],["F3","C4","F4","A4"],["G2","D3","G3","B3"]], "motif": ["E5","F#5","G5","D5"], "db": -25},
    "bgm_family.ogg": {"bpm": 58, "pattern": "sparse", "progression": [["C3","G3","C4","E4"],["A2","E3","A3","C4"],["F2","C3","F3","A3"],["G2","D3","G3","B3"]], "motif": ["E4","D4","C4","G3"], "loop": False, "db": -26},
    "bgm_survival.ogg": {"bpm": 70, "pattern": "walk", "progression": [["A2","E3","A3","C4"],["G2","D3","G3","B3"],["F2","C3","F3","A3"],["E2","B2","E3","G#3"]], "motif": ["A3","C4","B3","E4"], "loop": False, "db": -25},
    "bgm_hyunsu.ogg": {"bpm": 64, "pattern": "open", "progression": [["G2","D3","G3","B3"],["C3","G3","C4","E4"],["E2","B2","E3","G3"],["D3","A3","D4","F#4"]], "motif": ["B4","A4","G4","D4"], "loop": False, "db": -25},
    "bgm_ambition.ogg": {"bpm": 74, "pattern": "walk", "progression": [["E2","B2","E3","G3"],["C3","G3","C4","E4"],["G2","D3","G3","B3"],["D3","A3","D4","F#4"]], "motif": ["B3","E4","F#4","G4"], "loop": False, "db": -24},
    "bgm_daeun.ogg": {"bpm": 60, "pattern": "open", "progression": [["D3","A3","D4","F#4"],["G2","D3","G3","B3"],["B2","F#3","B3","D4"],["A2","E3","A3","C#4"]], "motif": ["F#4","A4","B4","D5"], "loop": False, "db": -26},
    "bgm_jiyeon.ogg": {"bpm": 63, "pattern": "open", "progression": [["F2","C3","F3","Ab3"],["E2","B2","E3","G#3"],["Db3","Ab3","Db4","F4"],["C3","G3","C4","E4"]], "motif": ["C5","Ab4","G#4","E4"], "loop": False, "db": -25},
    "bgm_casino_floor.ogg": {"bpm": 92, "pattern": "sparse", "progression": [["Eb2","Bb2","Eb3","G3"],["Ab2","Eb3","Ab3","C4"],["F2","C3","F3","A3"],["Bb2","F3","Bb3","D4"]], "motif": ["G4","Bb4","C5","F4"], "db": -26},
    "bgm_casino_table.ogg": {"bpm": 92, "pattern": "walk", "progression": [["Eb2","Bb2","Eb3","G3"],["Ab2","Eb3","Ab3","C4"],["F2","C3","F3","A3"],["Bb2","F3","Bb3","D4"]], "motif": ["G4","Bb4","C5","F4"], "db": -24},
}


PIANO_STINGERS: dict[str, dict[str, Any]] = {
    "sfx_ending_stinger_good.wav": {
        "events": [(0.00,"C4",8,0.33),(0.08,"G4",7,0.26),(0.18,"E5",8,0.28)],
        "duration": 2.4,
        "target_db": -20.5,
    },
    "sfx_ending_stinger_bad.wav": {
        "events": [(0.00,"A1",8,0.38),(0.14,"E2",7,0.26),(0.34,"C3",7,0.22)],
        "duration": 2.7,
        "target_db": -20.5,
    },
    "sfx_ending_stinger_legend.wav": {
        "events": [(0.00,"C3",9,0.34),(0.06,"G3",8,0.28),(0.14,"E4",8,0.27),(0.52,"C5",9,0.25)],
        "duration": 3.0,
        "target_db": -19.5,
    },
    "sfx_publisher_sting.wav": {
        "events": [(0.00,"C4",7,0.28),(0.22,"G4",7,0.24),(0.68,"C5",8,0.27)],
        "duration": 1.55,
        "target_db": -21.5,
        "stereo": True,
    },
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def find_ffmpeg() -> Path:
    env = os.environ.get("FFMPEG")
    if env and Path(env).is_file():
        return Path(env)
    found = shutil.which("ffmpeg")
    if found:
        return Path(found)
    for candidate in FFMPEG_CANDIDATES:
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return candidate
    raise RuntimeError("ffmpeg is required to decode licensed source recordings")


class Builder:
    def __init__(self, source_root: Path, ffmpeg: Path, output_root: Path) -> None:
        self.source_root = source_root
        self.ffmpeg = ffmpeg
        self.output_root = output_root
        self.temp = tempfile.TemporaryDirectory(prefix="gangnam-sample-audio-")
        self.temp_path = Path(self.temp.name)
        self.decode_cache: dict[tuple[Any, ...], np.ndarray] = {}
        self.note_cache: dict[tuple[str, int], tuple[np.ndarray, Path]] = {}
        self.provenance: dict[str, dict[str, Any]] = {}

    def close(self) -> None:
        self.temp.cleanup()

    def source_path(self, source_id: str) -> Path:
        pack_id, relative = SOURCES[source_id]
        path = self.source_root / str(PACKS[pack_id]["root"]) / relative
        if not path.is_file():
            raise FileNotFoundError(f"missing source {source_id}: {path}")
        return path

    def source_entry(self, source_id: str) -> dict[str, Any]:
        pack_id, relative = SOURCES[source_id]
        path = self.source_path(source_id)
        return {
            "pack": pack_id,
            "original_file": relative,
            "sha256": sha256(path),
            "source_type": PACKS[pack_id]["source_type"],
        }

    def decode(self, layer: Layer, duration: float | None, rate: int,
               channels: int, loop: bool = False) -> np.ndarray:
        key = (layer, duration, rate, channels, loop)
        if key in self.decode_cache:
            return self.decode_cache[key].copy()
        source = self.source_path(layer.source)
        target = self.temp_path / f"decode-{len(self.decode_cache):04d}.wav"
        cmd = [str(self.ffmpeg), "-y", "-loglevel", "error"]
        if loop:
            cmd += ["-stream_loop", "-1"]
        cmd += ["-i", str(source)]
        if layer.start > 0:
            cmd += ["-ss", f"{layer.start:.3f}"]
        if duration is not None:
            cmd += ["-t", f"{duration:.3f}"]
        filters: list[str] = []
        if layer.highpass > 0:
            filters.append(f"highpass=f={layer.highpass}")
        if layer.lowpass > 0:
            filters.append(f"lowpass=f={layer.lowpass}")
        if filters:
            cmd += ["-af", ",".join(filters)]
        cmd += ["-ac", str(channels), "-ar", str(rate), "-c:a", "pcm_s16le", str(target)]
        subprocess.run(cmd, check=True)
        audio = read_wav(target)
        audio *= db_gain(layer.gain_db)
        self.decode_cache[key] = audio
        return audio.copy()

    def write_ambience(self, name: str, layers: list[Layer]) -> None:
        human = name.startswith("amb_human_")
        duration = 18.0 if human else 22.65
        crossfade = 2.0
        rate = 22050
        frames = int((duration + crossfade) * rate)
        mix = np.zeros((frames, 2), dtype=np.float32)
        for layer in layers:
            decoded = self.decode(layer, duration + crossfade, rate, 2, loop=True)
            decoded = fit_length(decoded, frames)
            mix += decoded
        overlap = int(crossfade * rate)
        body_frames = int(duration * rate)
        body = mix[:body_frames].copy()
        ramp = np.linspace(0.0, 1.0, overlap, dtype=np.float32)[:, None]
        body[:overlap] = mix[body_frames:body_frames + overlap] * (1.0 - ramp) + mix[:overlap] * ramp
        body = normalize_rms(body, -35.0 if human else -29.0, -4.0)
        path = self.output_root / name
        write_wav(path, body, rate)
        self.record_asset(name, "sample_derived_mix", layers,
                          f"recording mix; {duration:.2f}s seamless crossfade; 22.05kHz stereo; "
                          f"RMS {'-35' if human else '-29'} dBFS")

    def write_sfx(self, name: str, recipe: dict[str, Any]) -> None:
        layers: list[Layer] = recipe["layers"]
        max_duration = float(recipe.get("max", 1.0))
        rate = 44100
        loop_sources = bool(recipe.get("loop", False))
        decoded_layers = [
            self.decode(layer, max_duration, rate, 1, loop=loop_sources)
            for layer in layers
        ]
        frames = max(max(len(layer) for layer in decoded_layers), int(0.18 * rate))
        mix = np.zeros((frames, 1), dtype=np.float32)
        for decoded in decoded_layers:
            mix[:len(decoded)] += decoded
        if not mix.size or float(np.max(np.abs(mix))) < 1.0e-5:
            raise ValueError(f"{name}: source edit is silent")
        mix = trim_silence(mix, rate, -48.0, 0.012, 0.045)
        if len(mix) > int(max_duration * rate):
            mix = mix[:int(max_duration * rate)]
        minimum = float(recipe.get("min", 0.0))
        if len(mix) < int(minimum * rate):
            raise ValueError(
                f"{name}: edited duration {len(mix) / rate:.2f}s < {minimum:.2f}s"
            )
        mix = apply_fades(mix, rate, 0.004, min(0.05, max_duration * 0.18))
        mix = normalize_rms(mix, float(recipe.get("db", -22.0)), -3.0)
        path = self.output_root / name
        write_wav(path, mix, rate)
        self.record_asset(name, "sample_derived_mix" if len(layers) > 1 else PACKS[SOURCES[layers[0].source][0]]["source_type"], layers,
                          f"recorded one-shot edit; mono 44.1kHz; max {max_duration:.2f}s; "
                          f"RMS {float(recipe.get('db', -22.0)):.1f} dBFS")

    def piano_sample(self, note: str, velocity: int) -> tuple[np.ndarray, Path]:
        key = (note, velocity)
        if key in self.note_cache:
            audio, source = self.note_cache[key]
            return audio.copy(), source
        midi = note_to_midi(note)
        sampled_midis = list(range(21, 109, 3))
        base_midi = min(sampled_midis, key=lambda value: abs(value - midi))
        base_name = midi_to_sample_name(base_midi)
        layer = max(1, min(16, velocity))
        source = self.source_root / str(PACKS["salamander_piano"]["root"]) / f"{base_name}v{layer}.wav"
        if not source.is_file():
            raise FileNotFoundError(f"missing piano source: {source}")
        target = self.temp_path / f"piano-{note.replace('#', 's')}-v{layer}.wav"
        semitones = midi - base_midi
        ratio = 2.0 ** (semitones / 12.0)
        filters = f"asetrate=44100*{ratio:.10f},aresample=44100,highpass=f=32,lowpass=f=11000"
        subprocess.run([
            str(self.ffmpeg), "-y", "-loglevel", "error", "-i", str(source),
            "-af", filters, "-ac", "2", "-ar", "44100", "-c:a", "pcm_s16le", str(target),
        ], check=True)
        audio = read_wav(target)
        self.note_cache[key] = (audio, source)
        return audio.copy(), source

    def add_piano_note(self, mix: np.ndarray, used: set[Path], note: str,
                       start: float, velocity: int, gain: float = 1.0,
                       max_seconds: float = 7.0) -> None:
        audio, source = self.piano_sample(note, velocity)
        used.add(source)
        audio = audio[:int(max_seconds * 44100)].copy()
        if len(audio) > 4410:
            fade = min(44100, len(audio) // 3)
            audio[-fade:] *= np.linspace(1.0, 0.0, fade, dtype=np.float32)[:, None]
        index = max(0, int(start * 44100))
        if index >= len(mix):
            return
        end = min(len(mix), index + len(audio))
        mix[index:end] += audio[:end - index] * gain

    def write_track(self, name: str, spec: dict[str, Any]) -> None:
        bpm = float(spec["bpm"])
        beat = 60.0 / bpm
        bar = beat * 4.0
        bars = 16
        looped = bool(spec.get("loop", True))
        core_duration = bars * bar
        duration = core_duration + 5.5
        mix = np.zeros((int(duration * 44100), 2), dtype=np.float32)
        rng = random.Random(f"gangnam-dream:{name}:sample-score-v1")
        used: set[Path] = set()
        progression: list[list[str]] = spec["progression"]
        motif: list[str] = spec["motif"]
        pattern = str(spec["pattern"])
        for bar_index in range(bars):
            chord = progression[bar_index % len(progression)]
            base = 0.08 + bar_index * bar
            soft_bar = bar_index in {0, 7, 15}
            if pattern == "sparse":
                placements = [(0.0, chord[0], 6), (1.35, chord[2], 7), (2.55, chord[1], 6), (3.18, chord[3], 7)]
            elif pattern == "walk":
                placements = [(0.0, chord[0], 7), (0.72, chord[1], 6), (1.48, chord[2], 7), (2.32, chord[1], 6), (3.08, chord[3], 7)]
            elif pattern == "procession":
                placements = [(0.0, chord[0], 8), (0.04, chord[1], 7), (0.08, chord[2], 7), (2.0, chord[1], 6), (2.04, chord[3], 7)]
            else:
                placements = [(0.0, chord[0], 7), (0.14, chord[1], 6), (1.22, chord[2], 7), (2.46, chord[3], 7), (3.18, chord[1], 6)]
            for beat_pos, note, velocity in placements:
                jitter = rng.uniform(-0.025, 0.035)
                gain = (0.22 if soft_bar else 0.29) * rng.uniform(0.90, 1.06)
                self.add_piano_note(mix, used, note, base + beat_pos * beat + jitter, velocity, gain)
            if bar_index % 4 in {1, 3}:
                for index, note in enumerate(motif):
                    self.add_piano_note(
                        mix, used, note,
                        base + (0.46 + index * 0.76) * beat + rng.uniform(-0.025, 0.025),
                        6 if index < 3 else 7,
                        0.20 * rng.uniform(0.91, 1.04),
                        5.2,
                    )
        if looped:
            core_frames = int(core_duration * 44100)
            body = mix[:core_frames].copy()
            tail = mix[core_frames:]
            wrap_frames = min(len(body), len(tail))
            body[:wrap_frames] += tail[:wrap_frames]
            seam_frames = min(int(0.04 * 44100), len(body) // 8)
            if seam_frames > 1:
                ramp = np.linspace(0.0, 1.0, seam_frames, dtype=np.float32)[:, None]
                body[-seam_frames:] = (
                    body[-seam_frames:] * (1.0 - ramp)
                    + body[:seam_frames] * ramp
                )
            mix = body
        else:
            mix = apply_fades(mix, 44100, 0.12, 3.0)
        mix = normalize_rms(mix, float(spec["db"]), -4.0)
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as handle:
            wav_path = Path(handle.name)
        try:
            write_wav(wav_path, mix, 44100)
            output = self.output_root / name
            subprocess.run([
                str(self.ffmpeg), "-y", "-loglevel", "error", "-i", str(wav_path),
                "-c:a", "libvorbis", "-q:a", "5", str(output),
            ], check=True)
        finally:
            wav_path.unlink(missing_ok=True)
        sources = [self.piano_source_entry(path) for path in sorted(used)]
        self.provenance[name] = {
            "provenance": "real_instrument_sample",
            "sources": sources,
            "transform": (
                f"original score rendered only from recorded Yamaha C5 samples; {bpm:.0f} BPM; "
                f"{bars} bars; {'seamless loop' if looped else 'one-shot'}; "
                "humanized timing and dynamics; Ogg Vorbis q5"
            ),
            "output_sha256": sha256(self.output_root / name),
        }

    def write_piano_stinger(self, name: str, events: list[tuple[float, str, int, float]],
                            duration: float, target_db: float,
                            stereo: bool = False) -> None:
        mix = np.zeros((int(duration * 44100), 2), dtype=np.float32)
        used: set[Path] = set()
        for start, note, velocity, gain in events:
            self.add_piano_note(mix, used, note, start, velocity, gain, duration - start)
        mix = apply_fades(mix, 44100, 0.012, min(0.5, duration * 0.22))
        mix = normalize_rms(mix, target_db, -3.5)
        output = mix if stereo else mix.mean(axis=1, keepdims=True)
        write_wav(self.output_root / name, output, 44100)
        self.provenance[name] = {
            "provenance": "real_instrument_sample",
            "sources": [self.piano_source_entry(path) for path in sorted(used)],
            "transform": (
                "short original cue rendered only from recorded Yamaha C5 samples; "
                f"{duration:.2f}s {'stereo' if stereo else 'mono'}"
            ),
            "output_sha256": sha256(self.output_root / name),
        }

    def piano_source_entry(self, path: Path) -> dict[str, Any]:
        root = self.source_root / str(PACKS["salamander_piano"]["root"])
        return {
            "pack": "salamander_piano",
            "original_file": str(path.relative_to(root)),
            "sha256": sha256(path),
            "source_type": "real_instrument_sample",
        }

    def record_asset(self, name: str, provenance: str, layers: list[Layer], transform: str) -> None:
        self.provenance[name] = {
            "provenance": provenance,
            "sources": [self.source_entry(layer.source) for layer in layers],
            "transform": transform,
            "output_sha256": sha256(self.output_root / name),
        }

    def write_manifest(self) -> None:
        payload = {
            "schema_version": 1,
            "policy": "recorded sources and real-instrument samples only; no generated source waveforms",
            "libraries": {
                pack_id: {key: value for key, value in data.items() if key != "root"}
                for pack_id, data in PACKS.items()
            },
            "assets": dict(sorted(self.provenance.items())),
        }
        manifest_path = self.output_root / "AUDIO_SOURCE_MANIFEST.json"
        manifest_path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


def db_gain(db: float) -> float:
    return 10.0 ** (db / 20.0)


def read_wav(path: Path) -> np.ndarray:
    with wave.open(str(path), "rb") as handle:
        channels = handle.getnchannels()
        width = handle.getsampwidth()
        frames = handle.getnframes()
        data = handle.readframes(frames)
    if width != 2:
        raise ValueError(f"expected PCM16 WAV, got width={width}: {path}")
    audio = np.frombuffer(data, dtype="<i2").astype(np.float32) / 32768.0
    return audio.reshape(-1, channels)


def write_wav(path: Path, audio: np.ndarray, rate: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    pcm = (np.clip(audio, -1.0, 1.0) * 32767.0).astype("<i2")
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(1 if pcm.ndim == 1 else pcm.shape[1])
        handle.setsampwidth(2)
        handle.setframerate(rate)
        handle.writeframes(pcm.tobytes())


def fit_length(audio: np.ndarray, frames: int) -> np.ndarray:
    if len(audio) >= frames:
        return audio[:frames]
    repeats = math.ceil(frames / max(1, len(audio)))
    return np.tile(audio, (repeats, 1))[:frames]


def normalize_rms(audio: np.ndarray, target_db: float, peak_db: float) -> np.ndarray:
    if not audio.size:
        return audio
    audio = audio - np.mean(audio, axis=0, keepdims=True)
    rms = float(np.sqrt(np.mean(np.square(audio))))
    if rms > 1.0e-9:
        audio *= db_gain(target_db) / rms
    peak = float(np.max(np.abs(audio)))
    peak_limit = db_gain(peak_db)
    if peak > peak_limit:
        audio *= peak_limit / peak
    return audio.astype(np.float32)


def trim_silence(audio: np.ndarray, rate: int, threshold_db: float,
                 pre: float, post: float) -> np.ndarray:
    if not audio.size:
        return audio
    envelope = np.max(np.abs(audio), axis=1)
    threshold = db_gain(threshold_db)
    indices = np.flatnonzero(envelope >= threshold)
    if not len(indices):
        return audio
    start = max(0, int(indices[0]) - int(pre * rate))
    end = min(len(audio), int(indices[-1]) + int(post * rate) + 1)
    return audio[start:end]


def apply_fades(audio: np.ndarray, rate: int, fade_in: float, fade_out: float) -> np.ndarray:
    result = audio.copy()
    in_frames = min(len(result), int(fade_in * rate))
    out_frames = min(len(result), int(fade_out * rate))
    if in_frames > 1:
        result[:in_frames] *= np.linspace(0.0, 1.0, in_frames, dtype=np.float32)[:, None]
    if out_frames > 1:
        result[-out_frames:] *= np.linspace(1.0, 0.0, out_frames, dtype=np.float32)[:, None]
    return result


NOTE_OFFSETS = {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3,
                "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8,
                "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11}
MIDI_NAMES = ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")


def note_to_midi(note: str) -> int:
    match = re.fullmatch(r"([A-G](?:#|b)?)(-?\d+)", note)
    if not match:
        raise ValueError(f"invalid note: {note}")
    return (int(match.group(2)) + 1) * 12 + NOTE_OFFSETS[match.group(1)]


def midi_to_sample_name(midi: int) -> str:
    name = MIDI_NAMES[midi % 12]
    octave = midi // 12 - 1
    if name not in {"A", "C", "D#", "F#"}:
        raise ValueError(f"midi {midi} is not a native Salamander sampled pitch")
    return f"{name}{octave}"


def validate_sources(source_root: Path) -> None:
    missing: list[str] = []
    for source_id, (pack_id, relative) in SOURCES.items():
        path = source_root / str(PACKS[pack_id]["root"]) / relative
        if not path.is_file():
            missing.append(f"{source_id}: {path}")
    piano_root = source_root / str(PACKS["salamander_piano"]["root"])
    if not piano_root.is_dir():
        missing.append(f"salamander_piano: {piano_root}")
    if missing:
        raise FileNotFoundError("missing licensed audio sources:\n" + "\n".join(missing))


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-root", type=Path, default=DEFAULT_SOURCE_ROOT)
    parser.add_argument("--output-root", type=Path, default=AUDIO_DIR)
    parser.add_argument("--validate-only", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    source_root = args.source_root.expanduser().resolve()
    validate_sources(source_root)
    expected_count = (
        len(AMBIENCE_RECIPES)
        + len(SFX_RECIPES)
        + len(TRACK_SPECS)
        + len(PIANO_STINGERS)
    )
    if expected_count != 134:
        raise RuntimeError(f"release audio inventory must remain 134 assets, got {expected_count}")
    if args.validate_only:
        print(
            "SAMPLE_AUDIO_SOURCES_OK "
            f"sources={len(SOURCES)} assets={expected_count} root={source_root}"
        )
        return 0
    builder = Builder(source_root, find_ffmpeg(), args.output_root.resolve())
    try:
        for name, layers in sorted(AMBIENCE_RECIPES.items()):
            print("AMBIENCE", name)
            builder.write_ambience(name, layers)
        for name, recipe in sorted(SFX_RECIPES.items()):
            print("SFX", name)
            builder.write_sfx(name, recipe)
        for name, spec in sorted(TRACK_SPECS.items()):
            print("MUSIC", name)
            builder.write_track(name, spec)
        for name, spec in sorted(PIANO_STINGERS.items()):
            print("STINGER", name)
            builder.write_piano_stinger(
                name,
                spec["events"],
                float(spec["duration"]),
                float(spec["target_db"]),
                bool(spec.get("stereo", False)),
            )
        builder.write_manifest()
    finally:
        builder.close()
    actual = sorted(path.name for path in args.output_root.iterdir() if path.suffix.lower() in {".wav", ".ogg"})
    if set(actual) != set(builder.provenance):
        missing = sorted(set(actual) - set(builder.provenance))
        stale = sorted(set(builder.provenance) - set(actual))
        print("SAMPLE_AUDIO_BUILD_FAIL inventory mismatch", "unowned=", missing, "stale=", stale)
        return 1
    print(f"SAMPLE_AUDIO_BUILD_OK assets={len(actual)} recordings_or_samples={len(builder.provenance)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
