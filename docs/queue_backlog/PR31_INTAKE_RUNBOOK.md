# PR #31 들이기 작업표 (2026-10-02 Claude 작성)

> Codex 복귀(2026-10-05) 첫날용. 부모는 [CODEX_RETURN_PLAN_2026-09-30.md](CODEX_RETURN_PLAN_2026-09-30.md)다.
> 이 표는 "어떤 커밋을 어떤 단위로, 어떤 순서로 들이고, 들인 뒤 무엇을 다시 계산하는가"만 다룬다.
> 실행 순서의 정본은 여전히 `docs/CODEX_QUEUE.md`다.

## 결론

1. **커밋을 하나씩 골라 들이지 않는다.** 문장 수리 블록(B4)은 391 영수증(`9db4a6e5`)과
   352 초안(`b0efea56`) 위에 쌓였고, 번역 수용원장(`content/meta/full_game_localization.json`)이
   커밋마다 누적된다. 중간 커밋만 고르면 원장이 충돌하거나 영수증이 원문과 어긋난다.
2. **들이는 단위는 네 블록이다.** B1 문서 → B2 391 영수증 → B3 352 초안 → B4 문장 수리.
   폰트 수리(`ab6f52fe`)는 `scenes/MainGame.gd`의 다른 위치라 독립이다(B2 옆에서 함께 들여도 된다).
3. **B3을 거부하면 B4의 세 장면을 손으로 다시 적용해야 한다.** 352 초안과 Claude 수리가 같은
   장면을 고쳤다: `arc_minseo_03_arrival`, `arc_minseo_03b_not_arrived`(`content/events/arc_new_characters.json`),
   `arc_father_legacy`(`content/events/arc_year3_drama.json`). 그 외 B4 장면은 352와 겹치지 않는다.
4. **392(main 원장 복구)를 먼저 하면 B2·B4의 원장과 충돌한다.** 392가 원장을 고치기 전에
   이 PR의 원장 변경을 먼저 보고, 392는 그 위에서 다시 계산하는 순서가 덜 아프다(아래 "권장 순서").

## 의존 관계

```
main 9fb7ff21
 └─ b0efea56  ORDER-352 5장 초안 (KO/EN/JA/zh 16파일, 원장 영수증 없음)
     └─ 9db4a6e5 / 2efa189f  ORDER-391 중국어 패드 안내 영수증 (원장만, 2efa189f는 중복)
         └─ ab6f52fe  패드 안내 normal_font (MainGame.gd 4줄)
             └─ 62d9494c … 89cb4450  문서 21커밋 (docs/만)
                 └─ 3643da2b … 446eab5d  문장 수리 13커밋 (콘텐츠·원장·등급 목록, MainGame.gd 6줄)
```

## 블록별 들이기

| 블록 | 커밋 | 바꾸는 것 | 충돌 위험 | 들인 뒤 다시 계산 |
|---|---|---|---|---|
| B1 문서 | `62d9494c`~`89cb4450`(21개)과 B4 안의 문서 변경 | `docs/`만 | `docs/WORK_LOG.md`(40KB 예산), `docs/CODEX_QUEUE.md`가 아닌 backlog 파일들 | `context_manifest_check`, `queue_consistency_check` |
| B2 391 영수증 | `9db4a6e5`(`2efa189f`는 같은 내용) | 원장 `accepted`·`accepted_sha256` | 392와 같은 파일 | ORDER-392 절 그대로 |
| B3 352 초안 | `b0efea56` | 5장 장면 7곳(민서 두 장면, 이름 경계, 아버지 회상 등) 5언어 | **원장 영수증이 없다.** 들이면 해당 잎의 source 지문이 원장과 어긋난다 | ORDER-352 절: 영수증·successor·`order309/313` history 등록 |
| B4 문장 수리 | `3643da2b`~`446eab5d`(13개) | 엔딩·사건 문장 5언어, 원장 영수증, `release_content_inventory.json` 지문, `MainGame.gd` `_resolved_ending_description` 6줄 | 원장, 등급 목록, 위 세 장면 | 아래 "B4 뒤 처리" |

### B4 뒤 처리 (반드시 함께)

- **`CHAPTER1_INVENTORY_HISTORY`**: `chapter1_core_loop_v2_causal_ledger_check.py --inventory-history-self-test`가
  `content/meta/release_content_inventory.json` 원문 바이트를 ORDER-363 전이로 고정한다. B4가 이 파일을
  9번 바꿨다(엔딩 corpus 지문, sexuality·fear·alcohol·gambling·violence 축). ORDER-363 전이에 새 상태를
  등록하거나, 들이는 방식에 맞춰 한 번에 다시 산출한다. Claude는 검사 도구를 바꾸지 않았다.
- **ORDER-390 MainGame 원문 승인**: `ab6f52fe`(4줄)와 `3643da2b`(6줄, 살아 있는 아버지에게 `empty_house`
  사망 변형을 쓰지 않게 하는 분기)를 승인 이력에 넣는다.
- **352가 남긴 원장 어긋남 3잎**: `events:arc_father_legacy:/description`과
  `/description_memory_if_known/chapter5_general_debt_memory_reconnect_0·_1`. B3이 KO를 바꾸고 영수증을
  남기지 않아 JA/zh 영수증의 source 지문이 맞지 않는다. Claude는 이 잎을 건드리지 않았다. B3 영수증
  작업 때 함께 닫는다.
- **zh-CN 파일의 큰 diff**: `full_game_localization.py import`가 zh-CN 오버레이를 정규 형식으로 다시 쓴
  결과다. 문장 변경은 원장 영수증이 가리키는 잎뿐이다.

## 권장 순서

1. B1 문서를 먼저 들인다(충돌 없음, 이후 판단 근거).
2. B2·폰트·B3·B4를 **하나의 병합 커밋**으로 들인다(브랜치를 병합하되 문서 외 커밋은 이 범위만).
   main이 그사이 바뀌지 않았다면 충돌은 없다(2026-10-02 기준 main `9fb7ff21`, PR mergeable).
3. 그 위에서 392를 수행한다. 392가 원장을 다시 계산할 때 B2·B3·B4 잎이 함께 들어가 있어야
   391·352·문장 수리 영수증을 한 번에 맞출 수 있다.
4. B4 뒤 처리 세 가지를 같은 오더 안에서 닫는다.
5. 7k(지연 변형 author_only, 데모 고정 파일 안의 4건)는 그다음이다.

이 순서가 CODEX_RETURN_PLAN의 "392 먼저"와 다른 이유: 392를 먼저 하면 main 원장이 바뀐 뒤
PR 원장과 충돌하고, 2,700줄 원장 diff를 손으로 합쳐야 한다. 들인 뒤 다시 계산하는 편이 싸다.
다만 B3(352 초안)을 이번에 받지 않기로 하면 2번이 불가능하므로 CODEX_RETURN_PLAN 순서를 따른다.

## 검사 실패 귀속

(측정 중 — 아래 표를 채운다)
