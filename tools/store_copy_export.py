#!/usr/bin/env python3
"""Extract local store and Content Survey drafts; never translate or publish."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/STEAM_PAGE.md"
LABELS = ("한국어", "English", "日本語", "简体中文", "繁體中文")
LOCALES = ("ko", "en", "ja", "zh-CN", "zh-TW")
ABOUT = ("4.", "5.", "5.1.", "5.2.", "5.3.")
SHORT_LIMIT = 300


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def section(text: str, level: int, prefix: str) -> str:
    headings = list(re.finditer(r"^(#{1,6}) (.+)$", text, re.M))
    matches = [(n, h) for n, h in enumerate(headings)
               if len(h[1]) == level and h[2].startswith(prefix)]
    if len(matches) != 1:
        raise ValueError(f"Expected one section: {prefix}")
    n, h = matches[0]
    end = next((v.start() for v in headings[n + 1:] if len(v[1]) <= level), len(text))
    return text[h.end():end]


def one_block(text: str) -> str:
    blocks = re.findall(r"^```text\n(.*?)\n```[ \t]*$", text, re.M | re.S)
    if len(blocks) != 1 or text.count("```") != 2:
        raise ValueError("Expected one closed text block")
    return blocks[0]


def extract(source: bytes) -> dict[str, str]:
    text = source.decode("utf-8")
    short = section(section(text, 2, "3. "), 3, "A. ")
    labels = list(re.finditer(r"^(.+):\n", short, re.M))
    if tuple(m[1] for m in labels) != LABELS:
        raise ValueError("Short-description language labels/order changed")
    notices = section(text, 3, "AI 보조 번역 고지")
    rows = re.findall(r"^\| ([^|]+) \| ([^|]+) \|$", notices, re.M)
    if tuple(k for k, _ in rows) != ("언어",) + LABELS:
        raise ValueError("Translation-notice table changed")
    files = {}
    for n, locale in enumerate(LOCALES):
        end = labels[n + 1].start() if n + 1 < len(labels) else len(short)
        values = {
            "short_description.txt": one_block(short[labels[n].end():end]),
            "about_this_game.bbcode.txt": one_block(section(text, 2, ABOUT[n] + " About This Game - ")),
            "ai_translation_notice.txt": rows[n + 1][1],
        }
        for filename, value in values.items():
            if not value.strip() or "\x00" in value or "```" in value:
                raise ValueError(f"Empty/invalid text: {locale}/{filename}")
            if locale == "en" and re.search(r"[가-힣]", value):
                raise ValueError(f"Korean in English field: {filename}")
            if filename == "short_description.txt" and (
                "\n" in value or "\r" in value or len(value) > SHORT_LIMIT
            ):
                raise ValueError(f"Short description must be one line within {SHORT_LIMIT} characters: {locale}")
            if filename.startswith("about"):
                tags = re.findall(r"\[(/?)([^\]]+)\]", value)
                stack = []
                for closing, tag in tags:
                    if tag not in ("h2", "i"):
                        raise ValueError(f"Unexpected BBCode: {tag}")
                    if closing:
                        if not stack or stack.pop() != tag:
                            raise ValueError("Unbalanced BBCode")
                    else:
                        stack.append(tag)
                if stack:
                    raise ValueError("Unclosed BBCode")
            files[f"{locale}/{filename}"] = value + "\n"
    return files


def extract_survey(source: bytes) -> dict[str, str]:
    text = source.decode("utf-8")
    survey = section(text, 3, "Steam Content Survey - 현재 5언어 초안")
    headings = tuple(re.findall(r"^#### ([^\n]+)$", survey, re.M))
    if headings != LOCALES:
        raise ValueError("Content Survey language sections changed")
    files = {}
    for locale in LOCALES:
        value = one_block(section(survey, 4, locale))
        if not value.strip() or "\x00" in value or (
            locale == "en" and re.search(r"[가-힣]", value)
        ):
            raise ValueError(f"Empty/invalid Content Survey draft: {locale}")
        files[f"survey/{locale}/ai_content_survey_draft.txt"] = value + "\n"
    return files


def extract_tags(source: bytes) -> str:
    text = source.decode("utf-8")
    rows = re.findall(r"^(\d+)\. ([A-Za-z][A-Za-z -]+)$", section(text, 2, "6. "), re.M)
    if [number for number, _ in rows] != list(map(str, range(1, 9))) or (
        len({tag for _, tag in rows}) != 8
    ):
        raise ValueError("Expected eight unique, ordered Steam tag proposals")
    return "".join(f"{number}. {tag}\n" for number, tag in rows)


def export(parent: Path, source: Path = SOURCE) -> Path:
    raw = source.read_bytes()
    # Validate all surfaces before creating an output directory.
    files = extract(raw)
    survey_files = extract_survey(raw)
    tags = extract_tags(raw)
    if not parent.is_absolute() or parent.resolve() != parent or not parent.is_dir():
        raise ValueError("Output parent must be an existing absolute non-symlink directory")
    if parent == ROOT or ROOT in parent.parents:
        raise ValueError("Keep release outputs outside the repository")
    out = Path(tempfile.mkdtemp(prefix="steam-copy-", dir=parent))
    def write_fields(values: dict[str, str]) -> list[dict]:
        entries = []
        for name, value in values.items():
            path = out / name
            path.parent.mkdir(parents=True, exist_ok=True)
            data = value.encode("utf-8")
            with path.open("xb") as handle:
                handle.write(data)
            entries.append({"file": name, "bytes": len(data), "characters": len(value.rstrip("\n")),
                            "sha256": sha(data)})
        return entries

    entries = write_fields(files)
    survey_entries = write_fields(survey_files)
    tag_entry, = write_fields({"steam_tags.txt": tags})
    (out / "source.md").write_bytes(raw)
    (out / "README.txt").write_text(
        "상점 문구 인계 / Store copy handoff\n\n"
        "ko / en / ja / zh-CN / zh-TW: 대가 중심 A안 짧은 설명, About BBCode, AI 번역 고지.\n"
        "각 파일은 source.md의 해당 필드에서 추출했습니다. 기존 11-03 묶음은 역사본입니다.\n"
        "AI 번역 고지는 상점의 적절한 위치에 별도로 반영해야 합니다.\n"
        "survey/의 5개 초안은 콘텐츠 설문용이며 상점 소개가 아닙니다.\n"
        "steam_tags.txt는 공통 제안 순서입니다. Drama의 실제 등록 가능 여부는 미확인입니다.\n"
        "source.md는 근거 보관용이며 상점에 통째로 붙여 넣지 마세요.\n"
        "이 묶음은 초안 인계입니다. 게시·설문 제출·5언어 게임 완성·원어민 검수를 뜻하지 않습니다.\n"
        "Draft handoff only: not published, submitted, runtime-verified or native-reader approved.\n",
        encoding="utf-8")
    manifest = {"schema_version": 1, "scope": "existing_store_drafts_only",
                "source": "docs/STEAM_PAGE.md", "source_sha256": sha(raw), "files": entries,
                "survey_drafts": survey_entries, "tag_proposal": tag_entry,
                "unverified": ["steam_publication", "retail_five_language_runtime", "native_reader_review"]}
    (out / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out-parent", type=Path)
    args = parser.parse_args()
    if args.out_parent is None:
        raw = SOURCE.read_bytes()
        files = extract(raw)
        survey = extract_survey(raw)
        tags = extract_tags(raw)
        print(f"STORE_COPY_SOURCE_OK locales=5 fields={len(files)} survey={len(survey)} "
              f"tags={len(tags.splitlines())} translation=0 publication=0")
    else:
        print(f"STORE_COPY_EXPORT_OK dir={export(args.out_parent)}")


if __name__ == "__main__":
    main()
