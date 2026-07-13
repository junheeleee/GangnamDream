#!/usr/bin/env python3
"""Build one localized 1080p60 store trailer from real in-game captures."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

import trailer_check


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
TIMELINE = HERE / "timeline.json"
FONT_DIR = ROOT / "assets/fonts"


def ass_time(seconds: float) -> str:
    centiseconds = round(seconds * 100)
    hours, remainder = divmod(centiseconds, 360_000)
    minutes, remainder = divmod(remainder, 6_000)
    secs, cents = divmod(remainder, 100)
    return f"{hours}:{minutes:02d}:{secs:02d}.{cents:02d}"


def srt_time(seconds: float) -> str:
    milliseconds = round(seconds * 1000)
    hours, remainder = divmod(milliseconds, 3_600_000)
    minutes, remainder = divmod(remainder, 60_000)
    secs, millis = divmod(remainder, 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"


def ass_escape(text: str) -> str:
    return text.replace("\n", r"\N").replace("{", r"\{").replace("}", r"\}")


def write_subtitles(edit: dict, lang: str, ass_path: Path, srt_path: Path) -> None:
    header = """[Script Info]
ScriptType: v4.00+
PlayResX: 1920
PlayResY: 1080
WrapStyle: 2
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name,Fontname,Fontsize,PrimaryColour,SecondaryColour,OutlineColour,BackColour,Bold,Italic,Underline,StrikeOut,ScaleX,ScaleY,Spacing,Angle,BorderStyle,Outline,Shadow,Alignment,MarginL,MarginR,MarginV,Encoding
Style: Hook,Pretendard SemiBold,54,&H00F4F4F4,&H00FFFFFF,&H00111111,&H78000000,-1,0,0,0,100,100,0,0,3,1.4,0,2,120,120,74,1
Style: EndTitle,Pretendard Bold,78,&H00FFFFFF,&H00FFFFFF,&H00101010,&H00000000,-1,0,0,0,100,100,0,0,1,2.2,0,4,112,80,160,1
Style: EndBody,Pretendard SemiBold,36,&H00F2C66D,&H00FFFFFF,&H00101010,&H00000000,-1,0,0,0,100,100,0,0,1,1.5,0,1,116,80,126,1

[Events]
Format: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text
"""
    ass_lines = [header.rstrip()]
    srt_lines: list[str] = []
    for index, caption in enumerate(edit["captions"], start=1):
        text = str(caption[lang])
        ass_lines.append(
            "Dialogue: 0,{start},{end},{style},,0,0,0,,{text}".format(
                start=ass_time(float(caption["start"])),
                end=ass_time(float(caption["end"])),
                style=caption["style"],
                text=ass_escape(text),
            )
        )
        srt_lines.extend(
            [
                str(index),
                f"{srt_time(float(caption['start']))} --> {srt_time(float(caption['end']))}",
                text.replace(r"\N", "\n"),
                "",
            ]
        )
    ass_path.write_text("\n".join(ass_lines) + "\n", encoding="utf-8")
    srt_path.write_text("\n".join(srt_lines), encoding="utf-8")


def resolve_frame(data: dict, captures: Path, frame: str) -> Path:
    if frame == "@keyart":
        return ROOT / data["keyart"]
    return captures / frame


def build_filter(
    data: dict,
    edit: dict,
    ass_path: Path,
    fonts_dir: Path,
    music_index: int,
    cue_indices: list[int],
) -> str:
    width = int(data["video"]["width"])
    height = int(data["video"]["height"])
    fps = int(data["video"]["fps"])
    filters: list[str] = []
    concat_inputs: list[str] = []
    for index, cut in enumerate(edit["cuts"]):
        duration = float(cut["duration"])
        filters.append(
            f"[{index}:v]scale={width}:{height}:force_original_aspect_ratio=increase,"
            f"crop={width}:{height},setsar=1,fps={fps},trim=duration={duration:.3f},"
            f"setpts=PTS-STARTPTS[v{index}]"
        )
        concat_inputs.append(f"[v{index}]")
    ass_value = str(ass_path).replace("'", r"\'")
    fonts_value = str(fonts_dir).replace("'", r"\'")
    filters.append(
        "{inputs}concat=n={count}:v=1:a=0,"
        "fade=t=in:st=0:d=0.18,fade=t=out:st={out_start:.3f}:d=0.28,"
        "subtitles=filename='{ass}':fontsdir='{fonts}',format=yuv420p[vout]".format(
            inputs="".join(concat_inputs),
            count=len(concat_inputs),
            out_start=float(edit["duration"]) - 0.28,
            ass=ass_value,
            fonts=fonts_value,
        )
    )

    audio = edit["audio"]
    gray_start, gray_end = (float(value) for value in audio["gray"])
    dark_start, dark_end = (float(value) for value in audio["dark"])
    silence_start, silence_end = (float(value) for value in audio["silence"])
    filters.append(
        f"[{music_index}:a]atrim=duration={float(edit['duration']):.3f},asetpts=PTS-STARTPTS,"
        "volume=0.52,"
        f"lowpass=f=6000:enable='between(t,{gray_start:.3f},{gray_end:.3f})',"
        f"lowpass=f=1700:enable='between(t,{dark_start:.3f},{dark_end:.3f})',"
        f"volume=0:enable='between(t,{silence_start:.3f},{silence_end:.3f})',"
        f"afade=t=in:st=0:d=0.35,afade=t=out:st={float(edit['duration']) - 0.35:.3f}:d=0.35[bgm]"
    )
    mix_inputs = ["[bgm]"]
    for cue_number, (cue, input_index) in enumerate(zip(audio["cues"], cue_indices)):
        delay_ms = round(float(cue["at"]) * 1000)
        volume = float(cue.get("volume", 0.5))
        filters.append(
            f"[{input_index}:a]atrim=start=0:end=4,asetpts=PTS-STARTPTS,"
            f"volume={volume:.3f},adelay={delay_ms}:all=1[cue{cue_number}]"
        )
        mix_inputs.append(f"[cue{cue_number}]")
    filters.append(
        "{inputs}amix=inputs={count}:duration=first:normalize=0:dropout_transition=0,"
        "loudnorm=I=-16:TP=-1.5:LRA=8,aresample=48000[aout]".format(
            inputs="".join(mix_inputs), count=len(mix_inputs)
        )
    )
    return ";\n".join(filters) + "\n"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def export_qa_frames(ffmpeg: Path, video: Path, duration: float, qa_dir: Path) -> None:
    qa_dir.mkdir(parents=True, exist_ok=True)
    for index, fraction in enumerate((0.08, 0.34, 0.58, 0.82, 0.95), start=1):
        at = max(0.0, min(duration - 0.1, duration * fraction))
        target = qa_dir / f"{video.stem}_{index:02d}_{at:05.2f}s.png"
        subprocess.run(
            [
                str(ffmpeg), "-y", "-hide_banner", "-loglevel", "error",
                "-ss", f"{at:.3f}", "-i", str(video), "-frames:v", "1", str(target),
            ],
            check=True,
        )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--seconds", choices=("30", "60"), required=True)
    parser.add_argument("--lang", choices=trailer_check.LANGUAGES, required=True)
    parser.add_argument("--captures", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--ffmpeg", type=Path, required=True)
    args = parser.parse_args()

    data = trailer_check.load_timeline()
    captures = args.captures.resolve()
    output = args.output.resolve()
    ffmpeg = args.ffmpeg.resolve()
    edit = data["edits"][args.seconds]
    trailer_check.check_static(data, captures)
    if not ffmpeg.is_file():
        raise SystemExit(f"ffmpeg not found: {ffmpeg}")

    output.parent.mkdir(parents=True, exist_ok=True)
    work_dir = output.parent / "work"
    work_dir.mkdir(parents=True, exist_ok=True)
    fonts_dir = work_dir / "fonts"
    if fonts_dir.exists():
        shutil.rmtree(fonts_dir)
    fonts_dir.mkdir(parents=True, exist_ok=True)
    for font in FONT_DIR.glob("Pretendard-*.ttf"):
        shutil.copy2(font, fonts_dir / font.name)
    ass_path = work_dir / f"{output.stem}.ass"
    srt_path = output.with_suffix(".srt")
    write_subtitles(edit, args.lang, ass_path, srt_path)

    command = [str(ffmpeg), "-y", "-hide_banner", "-loglevel", "warning"]
    for cut in edit["cuts"]:
        frame = resolve_frame(data, captures, str(cut["frame"]))
        command.extend(
            ["-loop", "1", "-framerate", str(data["video"]["fps"]), "-t", str(cut["duration"]), "-i", str(frame)]
        )
    music_index = len(edit["cuts"])
    command.extend(["-stream_loop", "-1", "-i", str(ROOT / data["music"])])
    cue_indices: list[int] = []
    for cue in edit["audio"]["cues"]:
        cue_indices.append(len(edit["cuts"]) + 1 + len(cue_indices))
        command.extend(["-i", str(ROOT / cue["path"])])

    filter_graph = build_filter(data, edit, ass_path, fonts_dir, music_index, cue_indices)
    filter_path = work_dir / f"{output.stem}.filter.txt"
    filter_path.write_text(filter_graph, encoding="utf-8")
    command.extend(
        [
            "-filter_complex", filter_graph,
            "-map", "[vout]", "-map", "[aout]",
            "-c:v", "libx264", "-preset", os.environ.get("TRAILER_PRESET", "fast"),
            "-crf", os.environ.get("TRAILER_CRF", "18"),
            "-profile:v", "high", "-level:v", "4.2", "-pix_fmt", "yuv420p",
            "-r", str(data["video"]["fps"]),
            "-c:a", "aac", "-b:a", "192k", "-ar", "48000", "-ac", "2",
            "-movflags", "+faststart", "-t", str(edit["duration"]), str(output),
        ]
    )
    print(f"TRAILER_RENDER_START seconds={args.seconds} lang={args.lang} output={output}")
    subprocess.run(command, check=True)
    trailer_check.probe_video(output, ffmpeg, float(edit["duration"]))
    export_qa_frames(ffmpeg, output, float(edit["duration"]), output.parent / "qa")
    manifest = {
        "file": output.name,
        "seconds": int(args.seconds),
        "language": args.lang,
        "resolution": "1920x1080",
        "fps": 60,
        "audio": "AAC 48kHz stereo, -16 LUFS target",
        "sha256": sha256(output),
        "bytes": output.stat().st_size,
        "timeline_version": data["version"],
    }
    output.with_suffix(".json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"TRAILER_RENDER_OK seconds={args.seconds} lang={args.lang} "
        f"bytes={output.stat().st_size} sha256={manifest['sha256']}"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, KeyError, ValueError, subprocess.CalledProcessError) as exc:
        print(f"TRAILER_RENDER_FAIL {exc}", file=sys.stderr)
        raise SystemExit(1)
