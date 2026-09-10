# ORDER-232 — 기록 불러오기 UI24키 번역 증거

상태: 수용·회귀 완료, 정확 C2 비저자 단위 최종 판정 전.
본문/데이터만의 내부 판정이며 실제 component·화면·원어민 관찰은 없다. 본편 HOLD다.

## 신원·범위

- 선언 기준: `0c81af28dc5abf1267ff2697d7334c193475fb62`.
- 선언/STATUS 뒤 initial: `14f3828f35ba7a191adacd424b6dd64b4f67b12e`.
- 본문 C1: `ab4b630c2b77efde9c1e49a7151bc68739914d73` / tree `03cf3d15f883f2e67c90560003bf6d0f4e239a07`.
- 선택: UI24 source키×3=72수용. 기존JA24 검수·2정밀화/22유지, CN/TW 각각 직접 신규24.
- 누적: 37,942→38,014(JA12,670/CN·TW각12,672), b91→92, 내부 메타9 불변.
  언어별 사건11,578/1694root·엔딩234·catalog834 불변, UI24/26/26이다.
  비보호 shipping 사건 텍스트 결손0은 실제 도달·전체 UI·표시 완료를 뜻하지 않는다.
- 소유: UI3 선택만, portable72, 선언된 운영 문서. 코드4·KR/EN·런타임·save·설정·
  사용자 이름·폰트·project·기존 공개 UI121·인간 원형·보호1901파일 변경0.
  JA의 비선택2877개와 기존 탭 들여쓰기도 원형 보존했다. CN/TW 기존124개 보존.

## 직접 저작·비저자 전량 검수

Plato JA→Rawls 검수, Rawls CN→Poincare 검수, Poincare TW→Plato 검수.
각24 실제KO/현재값·호출문맥 대조, 필수0/선택0. ROOT도 세 언어24문구를 직접 대조했다.
자가L1은 각24 최초1회/오류0이다. 자동 PASS를 언어 품질 승인으로 대체하지 않았다.

- 일본어 `続ける時間`을 `再開する時点`으로 고쳐 앞으로 플레이할 기간과 저장 시점의 혼동을 없앴다.
- 일본어 `別のテスト版に分離された記録`을 `別のテスト版の独立した記録`으로 고쳐
  다른 판본으로 옮긴 기록이 아니라 그 판본에 속한 분리 기록임을 명확히 했다.
- 空欄/空/空白은 저장 슬롯과 사람 상태의 공용 빈 상태를 유지한다. 저장 전용어로 좁히지 않는다.
- 과거24주 데모/V2/정식판은 저장 출처다. 현재 공개 M01~M06의 범위·버전을 새로 선언하지 않는다.
- 경고/열기 불가/열기 가능과 원인의 방향, 슬롯1–5/6–10, 총2페이지, printf5개/템플릿3개,
  챕터→주차→이미 포맷된 원화 순서를 보존했다. 실제 삭제·로드 입력은 하지 않았다.
- StartMenu `_save_compatibility_note:758`, `_open_load_overlay:784`, `_rebuild_slots:1632`,
  `_confirm_delete:1686`가 소비한다. MainGame `_people_pressure_state:10837`의 빈 상태와
  `_populate_save_load_page:20177` 슬롯, `LocaleManager.ui/ui_format` 공유 의미를 대조했다.

## 보존·교환·회귀

initial JAprevious24는 기존값, CN/TW48은 null이다. C1 final export/check/import는
각 언어24행과 current target에 결속했다. `--locale` 명시, check/import6결과 모두
`changed_files=0`/`full_status=INCOMPLETE`/`human_gate=OPEN`이다. 최종 L2 records와
본문/currenttarget/독립 proof SHA/언어집합3/수량72를 응답·portable 수용에 결속했다.
기존 portable37,942/b91/meta9는 새72/batch1을 역제거하면 전체 raw가 동일하다.

전체 수용 L1은1회/38,014/오류0, 70.959초, 입력742 전후 동일.
명시 차선12개(고유11명령)는1회 PASS, 66.146초, 입력747 전후 동일.
self250/8.412초, source52, JA88, ZH12407, 공개5언어UI121 패리티를 확인했다.
감사 ERROR0/WARNING0, context/queue PASS. Godot·full audit·240주·실제 렌더 재실행0.
기존 ZH font readiness `blocked`는 별도 정적 소비자 수리 대상이며 이번에 해제하지 않았다.
아래 source 문서의 결과 기록 후에도 모든 코드/원문/target 검사 입력은 같음을 별도 해시로 확인한다.

## 실패·보강 기록

- initial seal helper가 사전조사의 `{id:{source_sha256}}` 대신 배열을 해시해 실패했다.
  원본24 source는 동일했고 payload 구조만 바로잡아 봉인했다. 실패 원형을 보존했다.
- JA 전체 JSON 재직렬화 사전 확인에서 비선택5행의 기존 탭 들여쓰기를 발견했다.
  전체 재직렬화는 실행하지 않고 선택2줄의 raw 역치환으로 보존했다.
- CN 최초 L1은24/진단0 관측. 반환 표시 한도로 raw 일부가 잘려, proof는 완전한 첫 stdout이
  아니라 관측된 결과와 동일 핀의 사후 재구성 자료임을 명시한다. 재L1은0이다.
  이후 추가 쉼표 앞 LF1만 제거해 JSON 형식을 맞췄고 값/records는 동일하다.
- Rawls JA L2 증거 조립의 긴 Unicode stdin행 parse실패를 보존하고 짧은 인접 문자열로 조립했다.
  제품/의미/L1 실행 변화0이다. 테스트 기대나 검사기 완화는 없었다.
- 비저자 helper 검토에서 L2→current 결속과 언어집합 누락을 보강했다. C1 뒤 교환 단계의
  사적 helper 변경이며 제품 코드4는 불변이다. 언어집합 assert는 응답 생성 후 추가됐으나
  생성 당시 실제3언어/72 manifest는 독립 확인했고, portable는 추가 후 실행했다.

## 확정한24문구

| KO key | JA | zh-CN | zh-TW |
|---|---|---|---|
| 자동저장 | 自動保存 | 自动保存 | 自動儲存 |
| 슬롯 %d | スロット %d | 存档位 %d | 存檔欄位 %d |
| 정식판 | 製品版 | 正式版 | 正式版 |
| 24주 데모 | 24週間デモ | 24周演示版 | 24週試玩版 |
| V2 테스트 | V2テスト | V2测试 | V2 測試版 |
| 이전 버전 | 以前のバージョン | 旧版本 | 舊版本 |
| 다른 빌드에서 저장됨 | 別のビルドで保存されています | 在其他构建版本中保存 | 由其他組建版本儲存 |
| 데모 기록 · 정식판에서 이어갈 수 있음 | デモの記録・製品版で続きからプレイできます | 演示版存档 · 可在正式版中继续 | 試玩版紀錄 · 可在正式版繼續 |
| 이전 저장 형식 · 호환 모드 | 旧セーブ形式・互換モード | 旧存档格式 · 兼容模式 | 舊版存檔格式 · 相容模式 |
| 더 최신 버전의 저장 파일이라 열 수 없음 | より新しいバージョンのセーブデータのため開けません | 此存档来自更新的版本，无法打开 | 這是較新版本的存檔，無法開啟 |
| 24주 데모에서는 이 기록을 열 수 없음 | この記録は24週間デモでは開けません | 无法在24周演示版中打开此存档 | 24週試玩版無法開啟此紀錄 |
| 다른 테스트판의 분리된 기록 | 別のテスト版の独立した記録 | 来自其他测试版的独立存档 | 其他測試版的獨立紀錄 |
| 호환되지 않거나 손상된 기록 | 互換性がないか破損した記録 | 存档不兼容或已损坏 | 不相容或已損毀的紀錄 |
| 기록 불러오기 | 記録を読み込む | 读取存档 | 讀取紀錄 |
| 이어갈 시간을 선택하세요. | 再開する時点を選んでください。 | 请选择要延续的时光。 | 請選擇要從哪個時刻繼續。 |
| ‹  슬롯 1–5 | ‹  スロット1～5 | ‹  存档位 1–5 | ‹  存檔欄位 1–5 |
| 슬롯 6–10  › | スロット6～10  › | 存档位 6–10  › | 存檔欄位 6–10  › |
| 뒤로 | 戻る | 返回 | 返回 |
| 비어 있음 | 空欄 | 空 | 空白 |
| 챕터 %d · %d주차  ·  %s | チャプター%d・第%d週・%s | 第%d章 · 第%d周  ·  %s | 第%d章 · 第%d週  ·  %s |
| 취소 | キャンセル | 取消 | 取消 |
| 페이지 %d / 2 | ページ %d / 2 | 第%d页 / 2 | 第%d頁 / 共2頁 |
| 삭제 확인 | 削除確認 | 确认删除？ | 確認刪除 |
| 저장 삭제 | セーブデータ削除 | 删除存档 | 刪除存檔 |

## 증거 지문

사적 실행/대조 자료는 아래 경로·SHA로 결속한다. 저장소의 최종 값은 위 표와 제품 파일이다.

| .git/full-game-localization/ 아래 파일 | bytes | SHA256 |
|---|---:|---|
| order232-initial-export-proof.json | 3586 | 19bd09c97929a299f79b2715d7ec76957cbd6b0a85bb2dfa484ff8714c848ef1 |
| order232-initial-seal-initial-failed.json | 373 | 22abbb33390d6dd5a5af0c370f73036e388de153ef580d2ba78c75830b08df80 |
| order232-initial-seal.json | 484378 | 0101e0f937e81348d893df160f04511ca0ce077287896e515276c2380c333f37 |
| order232-ja-author.json | 28781 | f5e15e2f18bb1f4a735e86f5356722f7b70f102735696abe627e205045d7e349 |
| order232-cn-author.json | 28323 | 3ee2824b5f1ccd063f998c2ddd22902b9895d7f11f1272450b7fff44c4e72eb3 |
| order232-tw-author.json | 43628 | bfb1497d3d342b7af5a1c9f94e448d1755bd3d3c56e76ff685dde66abf0e111a |
| order232-ja-first-l1.json | 25046 | 8cecc4d1d3e132f06161101a2a5e45fb518148b8be9c083e01e7c0251ffe1816 |
| order232-cn-first-l1.json | 38920 | b7b0acf8c7ed791a4e5f46354f8870db8def6eaf41b1eaf70dba11905b646c49 |
| order232-tw-first-l1.json | 34778 | 368bd313d13de62a84aa4bf4bb45c1b5d3d642263827aa88ad48a75c81336b5d |
| order232-ja-independent-l2.json | 19123 | ffc7512ad5ddc769b76c530561c7462d50bcd0afd99495c36eb66ca0db294b6a |
| order232-cn-independent-l2.json | 25570 | 792b7a1268d6897d368a6105b408c43dbdd2806e8e3d138aff535d8998e2476d |
| order232-tw-independent-l2.json | 25428 | a880722ea2f6f4573ae1abd0ad200ed562e1fb80ee00dbaf47df2c8a29996c56 |
| order232-final-body-preacceptance.json | 27460 | 3ae5ff8c1fe43f60d792bc437b34437d6686fe080208d04bdfad7e9da980666a |
| order232-independent-preacceptance.json | 1421 | 33e2cab6bdb37f654d21016d669e383b001a2e55715a1bbe23e1a70b9661a069 |
| order232-independent-helper-static-final.json | 8510 | c0763965a9d44c7acb67373d1827cb0f849bc847f67c5afd9cd604c10efef581 |
| order232-final-source-response.json | 1690 | 11c4aa19ff766706a1f902abe46b67c16537030fb6c90f09da1e83936a5d4ad2 |
| order232-official-export-final.json | 3577 | 73b6d3d01b113d251b68e190c3d8c79f93782a75766c48570a50cc114a95a95d |
| order232-official-check-final.json | 1767 | e7b4f8caded8d86ebe4a5d41678cf6932aea520b9fe697ebc89fe273280c3c55 |
| order232-official-import-final.json | 1834 | 6aa6cff0c4beaa2f3d336c4a3f529660c8fc93fe2e807ef98cb908ac01717ce5 |
| order232-portable-acceptance.json | 1208 | 38ea90848760cab16ad5f8f47d1efab05fd83966aa44b93d0a1da0127d1dc4d4 |
| order232-independent-receipts.json | 21247 | 6e34a7957a0f55e29d8f7f9aa4d123ed23a843b6918ac5e9660e9fe5f4a2fdab |
| order232-all-accepted-l1-final.json | 85517 | d40ce080538338245eb6a4d730fdc9356ae019718f3cfd7464a02515f5614fa2 |
| order232-named-qa-final.json | 173490 | 981e943ed4420282bc74c559b38adabe580b02ebc81f6e2ed1a1c4e8b411d9af |
| order232-next-ui-archive-preflight.json | 26311 | 4d0b7b9a18ad74cd94a4073bedc223d958940e8bbf04019faa26b24b670ca2c9 |

## 다음·판정 경계

기록/회상 갤러리20판단단위·27leaf(문맥ID3 포함)의 사전조사만 마쳤다. 기존JA27 검수와
CN/TW신규54의 잠재81수용은 아직0이며 이 단위에 합산하지 않는다. JA 명장면→면요리 오역과
미발견 비밀의 부정 반전2건을 다음 별도 선언에서 고친다. 동적 제목/실제 replay는 별도 소비자다.
출시 데모 사용자 GO·인간45OPEN 원형·본편HOLD를 유지한다. UI·보호/author-only·표시 소비자·
실제 화면·원어민·정상속도 본편은 아직 미완료다. 자동 검사는 재미·깊이·문체 판정이 아니다.
승격: 지속 현지화/판정 규칙은 기존 I18N_INFRASTRUCTURE/WORK_UNIT 정본을 따른다.
이번24키·소유파일·교환/마감 지시는 일회성이다.
