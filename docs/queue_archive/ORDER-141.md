# Archived Queue Spec: ORDER-141

> Canonical status and execution order are indexed in `docs/CODEX_QUEUE.md`.

#### [x] ORDER-141 [P0·패키지 무결성] 실종된 과거 BUILD `.2`를 복구했다고 위조하지 못하게 보호한다

**착수 선언 (2026-08-31, Codex):** 현재 story demo builder는 반려된
BUILD `2026.08.24.2` 아카이브의 ZIP·manifest·checksum 세 파일이 디스크에
있어야만 새 빌드를 시작한다. 그러나 원래 ZIP은 현재 저장소와 연결 디스크에
없고, 동일 source와 Godot로 만든 one-shot ZIP도 역사 hash와 일치하지 않는다.
이 오더는 복구를 가장하지 않고 실종 사실·역사 기대값·재빌드 불일치를 추적 가능한
손실 영수증으로 고정해, 새 패키지가 그 부재 상태를 보호할 수 있게 한다.

**완료 (2026-08-31, Codex):** 구현
`cb06744c80d9575014868cd48d05b24b0814f022` / tree
`51eb6afb6489b28740e8e913583f435a54fb8626`에서 exact 역사 manifest와 checksum,
재빌드 불일치, `archive_restored=false`·`candidate_eligible=false`를 tracked
bundle로 고정했다. 실제 상태는 `missing_with_loss_receipt`, evidence digest
`4563dc38fd75f11ad6441df83d9698c960318d86430e33f3facb58f41040c691`다.
실물·부재 정상 상태와 가짜·부분·symlink·strict type·selected-source·protected-row
변조 204건이 통과했고 독립 post-review P0/P1/P2는 0이다. 자동 검사는 사람
플레이를 닫지 않았고 main은 HOLD다.

## 깊이 3문

1. 이 수리를 빼면 새 데모 패키지는 존재하지 않는 과거 ZIP 때문에 영구 중단되거나,
   누군가 임의 파일을 넣어 보호 게이트를 통과시키는 둘 중 하나가 된다.
2. 복구한 manifest만으로 아카이브를 복원했다고 쓰면 실제 389,505,944-byte ZIP과
   app/PCK/launcher가 없는 사실을 숨긴다. `archive_restored=false`와
   `candidate_eligible=false`를 불변으로 검증한다.
3. 과거 후보 손실을 인정한다고 보호 검사를 삭제하면 다음 빌드가 증거를 덮어쓸 수
   있다. builder 시작·종료의 동일한 canonical missing 상태와 tracked loss bundle을
   모두 검사한다.

## 한 배치 20단위

1. 역사 source `e9aff5f06c2e3ec3708426156074674a56a4c3f6`을 고정한다.
2. 역사 tree `ad4d88a6aed68a79074f6f8e3204bf0474f6dbc4`를 고정한다.
3. 실종 ZIP hash `626196d6a74f50373ddc3e6d0cb8b3a502f052d4436f308361d8b82d3ab45a75`를 고정한다.
4. 실종 ZIP size `389505944`를 고정한다.
5. 복구 manifest 9,238 bytes / SHA-256 `87f3491f7e526762203a83eb4ed25bbbba79981f7dc3ec812d49cdd955db1194`를 tracked evidence로 둔다.
6. checksum 파일의 exact 한 줄과 자체 SHA/size를 검증한다.
7. 역사 app tree `c21d5ba71c5516465849cc7596d48ed430a4fc903eeeb7033340d36e5afb6a85`를 고정한다.
8. 역사 launcher `291d39bfa8f6014b40745012e725eb1a398076d223ea89e1caa2d8804495c7c7`을 고정한다.
9. 역사 PCK `04e3e67e1591df5984f804f299edcba0c95eb6e8281362d253c134df0d64b7d8`를 고정한다.
10. one-shot 재빌드 ZIP/app/launcher/PCK의 불일치 hash를 손실 영수증에 기록한다.
11. 손실 영수증은 `archive_restored=false`, `candidate_eligible=false`만 허용한다.
12. 물리 아카이브가 있으면 ZIP·manifest·checksum 세 파일을 exact 역사값으로 검증한다.
13. 물리 아카이브가 없으면 완전한 tracked evidence bundle만 canonical missing 상태를 허용한다.
14. manifest만 있거나 ZIP만 있는 부분 상태와 symlink는 실패시킨다.
15. 가짜 ZIP, 변경 hash/size, 비exact manifest/checksum을 self-test가 거부한다.
16. `archive_restored=true` 또는 `candidate_eligible=true` 변조를 거부한다.
17. builder 전후 보호 행은 같은 kind·state·evidence hash를 유지해야 한다.
18. 새 build manifest는 과거 ZIP을 포함했다고 쓰지 않고 `missing_with_loss_receipt`로 표시한다.
19. 과거 BUILD `.2` 자체는 현재·미래 RC 후보로 영구 비적격이다.
20. story·번역·밸런스·사람 게이트를 바꾸지 않고 표적·전체 감사를 통과시킨다.

## 정확한 파일 소유권

**선언·마감:** `docs/CODEX_QUEUE.md`, 이 사양, `CLAUDE.md`,
`docs/WORK_LOG.md`, `docs/BUILD_PIPELINE.md`,
`docs/queue_archive/CODEX_QUEUE_2026-08.md`, 생성본 `docs/STATUS.md`.

**builder·검사:** `tools/build_story_demo_macos.sh`,
`tools/story_demo_package_audit.py`, `tools/audit_scope.json`.

**tracked loss evidence:**
`tools/evidence/order124_build_2026.08.24.2/MANIFEST.json`,
`tools/evidence/order124_build_2026.08.24.2/MANIFEST.sha256`,
`tools/evidence/order124_build_2026.08.24.2/LOSS_RECEIPT.json`.

위 파일 밖의 제품·원고·번역·런타임·자산·export 설정·human gate는 수정하지 않는다.
특히 실제 `build/order124/archive/2026.08.24.2`에 가짜 파일·symlink를 만들지 않고,
`project.godot`, `export_presets.cfg`, `docs/human_gates.json`은 읽기 전용이다.

## 완료 증거

```bash
python3 tools/story_demo_package_audit.py --self-test
python3 tools/story_demo_package_audit.py
python3 tools/audit_select.py -- tools/build_story_demo_macos.sh tools/story_demo_package_audit.py tools/audit_scope.json tools/evidence/order124_build_2026.08.24.2/MANIFEST.json tools/evidence/order124_build_2026.08.24.2/MANIFEST.sha256 tools/evidence/order124_build_2026.08.24.2/LOSS_RECEIPT.json
bash -n tools/build_story_demo_macos.sh
python3 -m json.tool tools/evidence/order124_build_2026.08.24.2/MANIFEST.json >/dev/null
python3 -m json.tool tools/evidence/order124_build_2026.08.24.2/LOSS_RECEIPT.json >/dev/null
git diff --check
```

- self-test는 valid physical archive와 valid missing evidence를 각각 통과시키고,
  부분 복구·가짜 ZIP·symlink·hash/size/boolean 변조를 모두 실패시킨다.
- actual은 현재 실종 상태를 `missing_with_loss_receipt`로만 통과시킨다.
- 자동 검사는 역사 손실과 새 빌드 비파괴성을 증명할 뿐 사람 플레이를 대체하지 않는다.

## 규범 판정

과거 후보 손실을 복구로 가장하지 않고 보호된 부재 상태로 기록하는 규칙은 계속
유효하므로 완료 시 `docs/BUILD_PIPELINE.md`의 story demo 보호 절에 승격한다.
이 사양의 역사 hash·경로·self-test 변이는 해당 손실 한 건만을 위한 일회성 판정
지시다.
