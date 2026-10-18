#!/usr/bin/env python3
"""Static and rendered-output gates for the Gangnam Dream store trailers."""

from __future__ import annotations

import argparse
import json
import os
import re
import struct
import subprocess
import sys
import tempfile
from pathlib import Path


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
TIMELINE = HERE / "timeline.json"
LANGUAGES = ("ko", "en")
EDIT_LENGTHS = ("30", "60")
STYLES = {"Hook", "EndTitle", "EndBody"}


def fail(message: str) -> None:
    raise RuntimeError(message)


def load_timeline() -> dict:
    with TIMELINE.open(encoding="utf-8") as handle:
        return json.load(handle)


def png_size(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        header = handle.read(24)
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        fail(f"not a PNG: {path}")
    return struct.unpack(">II", header[16:24])


def source_path(data: dict, captures: Path | None, frame: str) -> Path:
    if frame == "@keyart":
        return ROOT / data["keyart"]
    if captures is None:
        return Path(frame)
    return captures / frame


def check_static(data: dict, captures: Path | None = None) -> None:
    video = data.get("video", {})
    if (video.get("width"), video.get("height"), video.get("fps")) != (1920, 1080, 60):
        fail("trailer master contract must remain 1920x1080 at 60 fps")
    for asset_key in ("keyart", "music"):
        asset = ROOT / str(data.get(asset_key, ""))
        if not asset.is_file():
            fail(f"missing trailer {asset_key}: {asset}")

    edits = data.get("edits", {})
    if tuple(sorted(edits.keys())) != EDIT_LENGTHS:
        fail("timeline must define exactly the 30 and 60 second edits")
    used_frames: set[str] = set()
    for edit_key in EDIT_LENGTHS:
        edit = edits[edit_key]
        target = float(edit["duration"])
        cuts = edit.get("cuts", [])
        actual = sum(float(cut["duration"]) for cut in cuts)
        if abs(actual - target) > 0.001:
            fail(f"{edit_key}s cut durations total {actual:.3f}, expected {target:.3f}")
        if not cuts or cuts[-1].get("frame") != "@keyart":
            fail(f"{edit_key}s edit must end on the canonical key art")
        for cut in cuts:
            frame = str(cut.get("frame", ""))
            duration = float(cut.get("duration", 0.0))
            if duration <= 0.0:
                fail(f"{edit_key}s edit has a non-positive cut: {frame}")
            if frame != "@keyart" and not re.fullmatch(r"trailer_\d{2}_[a-z0-9_]+\.png", frame):
                fail(f"invalid capture name in {edit_key}s edit: {frame}")
            used_frames.add(frame)
            if captures is not None:
                path = source_path(data, captures, frame)
                if not path.is_file():
                    fail(f"missing captured frame: {path}")
                if png_size(path) != (1920, 1080):
                    fail(f"capture is not 1920x1080: {path} -> {png_size(path)}")

        last_start = -1.0
        for caption in edit.get("captions", []):
            start = float(caption.get("start", -1.0))
            end = float(caption.get("end", -1.0))
            if start < last_start or start < 0.0 or end <= start or end > target:
                fail(f"invalid caption timing in {edit_key}s edit: {caption}")
            last_start = start
            if caption.get("style") not in STYLES:
                fail(f"unknown caption style in {edit_key}s edit: {caption.get('style')}")
            for lang in LANGUAGES:
                if not str(caption.get(lang, "")).strip():
                    fail(f"missing {lang} caption in {edit_key}s edit at {start}")

        audio = edit.get("audio", {})
        for band in ("gray", "dark", "silence"):
            span = audio.get(band, [])
            if len(span) != 2 or not (0.0 <= float(span[0]) < float(span[1]) <= target):
                fail(f"invalid {band} audio span in {edit_key}s edit")
        for cue in audio.get("cues", []):
            cue_path = ROOT / str(cue.get("path", ""))
            cue_at = float(cue.get("at", -1.0))
            if not cue_path.is_file() or not (0.0 <= cue_at < target):
                fail(f"invalid audio cue in {edit_key}s edit: {cue}")

    expected = {f"trailer_{index:02d}_" for index in range(1, 23)}
    observed = {frame[:11] for frame in used_frames if frame != "@keyart"}
    if observed != expected:
        fail(f"capture contract mismatch: missing={sorted(expected - observed)} extra={sorted(observed - expected)}")


def probe_video(video: Path, ffmpeg: Path, expected_seconds: float) -> None:
    if not video.is_file() or video.stat().st_size < 1_000_000:
        fail(f"rendered trailer is missing or implausibly small: {video}")
    result = subprocess.run(
        [str(ffmpeg), "-hide_banner", "-i", str(video)],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    metadata = result.stderr
    duration_match = re.search(r"Duration: (\d+):(\d+):(\d+(?:\.\d+)?)", metadata)
    if not duration_match:
        fail(f"could not read duration from {video}")
    hours, minutes, seconds = duration_match.groups()
    duration = int(hours) * 3600 + int(minutes) * 60 + float(seconds)
    if abs(duration - expected_seconds) > 0.12:
        fail(f"{video.name} duration {duration:.3f}s, expected {expected_seconds:.3f}s")
    if not re.search(r"Video: h264.*1920x1080.*60 fps", metadata):
        fail(f"{video.name} is not H.264 1920x1080 at 60 fps")
    if not re.search(r"Audio: aac.*48000 Hz.*stereo", metadata):
        fail(f"{video.name} is missing the 48 kHz stereo AAC mix")


def capture_self_test() -> None:
    """Mocked process/PNG-header I/O only: never run Godot or claim rendered frames."""
    fake_source = r'''#!/usr/bin/env python3
import json, os, struct, sys, time
from pathlib import Path
argv = sys.argv
assert argv[argv.index('--script')+1] == 'res://tools/StoryNameplateBootstrap.gd'
assert argv[argv.index('--scene')+1] == 'res://tools/ScreenshotQA.tscn'
assert argv[argv.index('--resolution')+1] == '1920x1080'
assert '--qa=trailer' in argv
lang = next(a.split('=',1)[1] for a in argv if a.startswith('--lang='))
assert lang == os.environ['MOCK_TRAILER_LANG']
out = Path(os.environ['GANGNAM_QA_OUT'])
assert out == Path(os.environ['MOCK_TRAILER_OUT'])
root = Path(argv[argv.index('--path')+1])
mode = os.environ.get('MOCK_TRAILER_CASE', 'ok')
if mode == 'timeout': time.sleep(3)
namespace = os.environ['STORY_NAMEPLATE_QA_NAMESPACE']
assert namespace.startswith('GangnamDream_StoryNameplateQA_') and len(namespace.rsplit('_',1)[-1]) == 32
if sys.platform == 'darwin': parent = Path.home() / 'Library/Application Support'
elif os.name == 'nt': parent = Path(os.environ['APPDATA'])
else: parent = Path(os.environ.get('XDG_DATA_HOME', str(Path.home()/'.local/share')))
pre = 'STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=' + str(parent/namespace)
done = 'SCREENSHOT_QA_DONE scope=trailer lang=' + lang + ' dir=' + str(out)
data = json.loads((root/'tools/trailer/timeline.json').read_bytes())
names = sorted({c['frame'] for e in data['edits'].values() for c in e['cuts'] if c['frame'] != '@keyart'})
for i, name in enumerate(names):
 if mode == 'missing_frame' and i == 0: continue
 width = 1 if mode == 'bad_size' and i == 0 else 1920
 (out/name).write_bytes(b'\x89PNG\r\n\x1a\n'+b'\x00\x00\x00\rIHDR'+struct.pack('>II',width,1080))
if mode == 'extra_frame': (out/'trailer_99_stale.png').write_bytes(b'stale')
if mode == 'symlink_frame':
 (out/names[0]).unlink(); (out/names[0]).symlink_to(out/names[1])
if mode != 'no_log': Path(argv[argv.index('--log-file')+1]).write_text('SCRIPT ERROR: mocked\n' if mode == 'log_error' else 'mock only\n')
if mode == 'invalid_log': Path(argv[argv.index('--log-file')+1]).write_bytes(b'\xff')
if mode != 'no_pre': print(pre if mode != 'wrong_pre' else pre+'wrong')
if mode == 'duplicate_pre': print(pre)
if mode == 'stdout_error': print('ERROR: mocked after zero exit')
if mode == 'stderr_error': print('Parse Error: mocked',file=sys.stderr)
if mode == 'leak': print('WARNING: ObjectDB instances leaked at exit')
if mode == 'warning': print('WARNING: retained mock warning')
if mode != 'no_done': print(done if mode != 'wrong_locale' else done.replace('lang='+lang,'lang=other'))
if mode == 'duplicate_done': print(done)
if mode == 'nonzero': sys.exit(7)
'''
    modes = ('ok', 'warning', 'no_pre', 'wrong_pre', 'duplicate_pre', 'no_done',
             'wrong_locale', 'duplicate_done', 'stdout_error', 'stderr_error',
             'log_error', 'leak', 'no_log', 'nonzero', 'missing_frame', 'extra_frame',
             'bad_size', 'symlink_frame', 'timeout', 'invalid_log')
    cases = 0
    with tempfile.TemporaryDirectory(prefix='gd-trailer-contract-') as raw:
        base = Path(raw).resolve()
        fake = base/'mock-engine'
        fake.write_text(fake_source, encoding='utf-8')
        fake.chmod(0o700)
        wrapper = ROOT/'tools/trailer/capture_frames.sh'
        env = os.environ.copy()
        for key in ('STORY_NAMEPLATE_QA_NAMESPACE', 'GANGNAM_QA_OUT',
                    'STORY_DEMO_QA_BOOTSTRAP_NAME', 'STORY_DEMO_ALLOW_ISOLATED_QA'):
            env.pop(key, None)
        env['GODOT'] = str(fake)
        namespaces = set()
        for index, mode in enumerate(modes):
            lang = 'en' if index % 2 else 'ko'
            output = base/mode
            child = dict(env, MOCK_TRAILER_CASE=mode, MOCK_TRAILER_LANG=lang, MOCK_TRAILER_OUT=str(output))
            argv = ['bash',str(wrapper),lang,str(output)]
            if mode == 'timeout': argv += ['--timeout', '1']
            result = subprocess.run(argv,env=child,capture_output=True,text=True,timeout=20)
            if not (output/'capture-result.json').is_file():
                fail('mock failed before receipt: '+mode+' '+result.stdout+result.stderr)
            record = json.loads((output/'capture-result.json').read_bytes())
            should_pass = mode in ('ok', 'warning')
            if (result.returncode == 0) != should_pass or (record['status'] == 'passed') != should_pass:
                fail('mock capture status mismatch: '+mode+' '+result.stdout+result.stderr)
            if mode == 'timeout':
                if record['engine_exit'] in (None, 0): fail('timeout outcome not retained')
            elif record['engine_exit'] != (7 if mode == 'nonzero' else 0):
                fail('raw engine outcome changed: '+mode)
            if should_pass and len(record['frames']) != 22:
                fail('mock accepted roster not 22')
            if mode == 'warning' and not record['warning_lines']:
                fail('warning was discarded')
            namespaces.add(record['expected_user_dir'])
            cases += 1
        if len(namespaces) != len(modes):
            fail('namespace reused between mocked cases')
        old = base/'existing'
        old.mkdir(); sentinel=old/'trailer_01_kept.png'; sentinel.write_bytes(b'keep old artifact')
        for arg, extra in [('existing',{}), ('new-override',{'GANGNAM_QA_OUT':str(base/'foreign')})]:
            result = subprocess.run(['bash',str(wrapper),'ko',str(base/arg)],env=dict(env,**extra),capture_output=True,timeout=10)
            if result.returncode == 0 or sentinel.read_bytes() != b'keep old artifact':
                fail('fresh-path/override refusal failed')
            cases += 1
        bad=base/'bad-language'
        result=subprocess.run(['bash',str(wrapper),'ja',str(bad)],env=env,capture_output=True,timeout=10)
        if result.returncode == 0 or bad.exists(): fail('unsupported capture language admitted')
        cases += 1
        link=base/'link'; link.symlink_to(old,target_is_directory=True)
        result=subprocess.run(['bash',str(wrapper),'en',str(link/'child')],env=env,capture_output=True,timeout=10)
        if result.returncode == 0 or (old/'child').exists(): fail('symlink ancestor admitted')
        cases += 1
        broken = base/'broken-engine'; broken.write_text('not an executable format'); broken.chmod(0o700)
        output = base/'launch-failure'
        result=subprocess.run(['bash',str(wrapper),'ko',str(output)],env=dict(env,GODOT=str(broken)),capture_output=True,timeout=10)
        record=json.loads((output/'capture-result.json').read_bytes())
        if result.returncode == 0 or record['engine_exit'] is not None or not record['errors']:
            fail('launch failure outcome not retained')
        cases += 1
    print(f'TRAILER_CAPTURE_SELF_TEST_OK mocked_cases={cases} real_engine=0 rendered_claim=0')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--captures", type=Path)
    parser.add_argument("--video", type=Path)
    parser.add_argument("--ffmpeg", type=Path)
    parser.add_argument("--seconds", type=float)
    parser.add_argument("--capture-self-test", action="store_true")
    args = parser.parse_args()
    try:
        if args.capture_self_test:
            capture_self_test()
            return 0
        data = load_timeline()
        check_static(data, args.captures)
        if args.video is not None:
            if args.ffmpeg is None or args.seconds is None:
                fail("--video requires --ffmpeg and --seconds")
            probe_video(args.video, args.ffmpeg, args.seconds)
    except (OSError, ValueError, KeyError, RuntimeError, json.JSONDecodeError) as exc:
        print(f"TRAILER_CHECK_FAIL {exc}", file=sys.stderr)
        return 1
    suffix = f" captures={args.captures}" if args.captures else ""
    if args.video:
        suffix += f" video={args.video}"
    print(f"TRAILER_CHECK_OK edits=2 languages=2 frames=22{suffix}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
