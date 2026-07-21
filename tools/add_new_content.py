#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
새 콘텐츠 추가:
1. arc_midgame.json: 34세 독립 씬 3개
2. life_events.json: health 이벤트 10개 + comedy 이벤트 10개
3. content/events/arc_hyunsu.json: 현수 아크 6개 이벤트 (신규 파일)
4. callback_events_28.json: 어머니 이벤트 3개
"""
import json, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ──────────────────────────────────────────────────────────
# 1. ARC_MIDGAME — 34세 독립 씬 3개 추가
# ──────────────────────────────────────────────────────────
arc34_events = [
  {
    "id": "arc_34_two_years_in",
    "title": "2년째",
    "category": "story",
    "rarity": "story",
    "weight": 0,
    "hidden": True,
    "portrait": "minjun_tired",
    "background": "goshiwon_room",
    "conditions": { "min_turn": 9999 },
    "cooldown": 9999,
    "description": (
      "서울에 온 지 2년이 됐다.\n\n"
      "지하철 노선을 외웠다. 어느 편의점이 싸고 어느 국밥집이 국물을 많이 주는지 안다.\n"
      "고시원 원장 아줌마가 생일에 미역국을 줬다. 받았다. 먹었다.\n\n"
      "{name}은 생각했다 — 이제 서울 사람인가.\n\n"
      "아닌 것 같기도 했다. 서울은 아직 낯선 도시였다.\n"
      "근데 고향도 이제 낯설다.\n"
      "그 사이 어딘가에 있는 기분이었다."
    ),
    "description_orthodox": (
      "서울에 온 지 2년이 됐다.\n\n"
      "{name}은 체크리스트를 떠올렸다 — 이 2년 동안 뭘 했나.\n"
      "직장. 저축액. 투자 경험. 인맥. 스펙.\n\n"
      "부족하다. 아직 부족하다.\n"
      "하지만 2년 전의 {name}보다는 나은 위치에 있다. 그건 확실하다."
    ),
    "description_unorthodox": (
      "서울에 온 지 2년이 됐다.\n\n"
      "{name}은 생각했다 — 처음 왔을 때와 지금, 뭐가 달라졌나.\n\n"
      "겁이 좀 줄었다. 서울이 그냥 큰 도시라는 걸 알았다.\n"
      "큰 도시에는 큰 기회도 있고 큰 함정도 있다.\n"
      "아직 큰 기회를 못 잡았지만, 큰 함정도 안 빠졌다.\n"
      "지금으로선 그게 성과였다."
    ),
    "choices": [
      {
        "text": "여기까지 온 게 맞다",
        "effects": { "mental": 3, "route_orthodox": 1 },
        "flags": ["arc_34_two_years_seen"],
        "result_text": "맞는 것 같았다. 어쨌든 버텼다. 그게 지금은 전부였다."
      },
      {
        "text": "아직 시작도 못 했다",
        "effects": { "mental": -1, "intelligence": 2, "route_unorthodox": 1 },
        "flags": ["arc_34_two_years_seen"],
        "result_text": "조급함이 에너지가 되는 날이 있다.\n오늘이 그런 날이기를 바랐다."
      }
    ]
  },
  {
    "id": "arc_34_parents_visit",
    "title": "부모님이 서울에 오는 날",
    "category": "family",
    "rarity": "story",
    "weight": 0,
    "hidden": True,
    "portrait": "father",
    "background": "goshiwon_room",
    "conditions": { "min_turn": 9999 },
    "cooldown": 9999,
    "description": (
      "아버지가 서울에 온다고 했다. 어머니랑 같이.\n\n"
      "오랜만이었다. {name}은 고시원 방을 한 번 둘러봤다.\n"
      "6평. 침대. 책상. 옷걸이. 창문은 벽이 보인다.\n\n"
      "부모님이 이 방을 보면 뭐라고 할까.\n"
      "{name}은 생각했다 — 아무 말도 안 할 것 같다.\n"
      "아무 말도 안 하는 게 더 무거울 수 있다."
    ),
    "description_low_mental": (
      "아버지가 서울에 온다고 했다. 어머니랑 같이.\n\n"
      "{name}은 폰을 내려놨다.\n\n"
      "이 방을 보여줘야 한다. 6평. 벽이 보이는 창문.\n"
      "괜찮다고 말하면 아버지는 믿겠지만 어머니 얼굴이 떠올랐다.\n\n"
      "오지 말라고 할 수는 없었다."
    ),
    "choices": [
      {
        "text": "방 근처 식당에서 밥을 산다 — 방은 안 보여준다",
        "effects": { "money": -80000, "mental": 4, "social_skill": 1 },
        "flags": ["arc_34_parents_visited", "hid_room_from_parents"],
        "result_text": (
          "삼겹살집. 부모님은 많이 드셨다.\n"
          "아버지는 방 얘기를 꺼내지 않았다. 어머니도.\n\n"
          "방으로 돌아와서 {name}은 창문을 열었다. 벽이 보였다.\n"
          "부모님은 몰라도 된다. 아직은."
        )
      },
      {
        "text": "방을 보여준다 — 숨길 게 없다",
        "effects": { "mental": 2, "reputation": 2 },
        "flags": ["arc_34_parents_visited", "showed_room_to_parents"],
        "result_text": (
          "방에 들어선 어머니가 잠깐 멈췄다.\n"
          "아무 말도 안 했다. 뭔가 닦기 시작했다.\n\n"
          "아버지는 창문을 봤다.\n"
          '"...이 동네 괜찮냐."\n\n'
          "괜찮다고 했다.\n"
          "아버지는 고개를 끄덕였다. 믿는 것 같았다."
        )
      }
    ]
  },
  {
    "id": "arc_34_routine_trap",
    "title": "루틴의 덫",
    "category": "story",
    "rarity": "story",
    "weight": 0,
    "hidden": True,
    "portrait": "minjun_neutral",
    "background": "goshiwon_room",
    "conditions": { "min_turn": 9999 },
    "cooldown": 9999,
    "description": (
      "어느 날 {name}은 자신이 매일 같은 걸 하고 있다는 걸 깨달았다.\n\n"
      "같은 시간에 일어났다. 같은 편의점에서 같은 삼각김밥을 샀다.\n"
      "같은 지하철 칸. 같은 자리.\n\n"
      "루틴이 생긴 것이었다.\n\n"
      "루틴은 좋은 것이다 — 사람들이 말한다.\n"
      "근데 {name}은 생각했다 — 이 루틴이 목적지로 가는 루틴인가, 아니면 제자리를 도는 루틴인가."
    ),
    "description_orthodox": (
      "어느 날 {name}은 자신이 매일 같은 걸 하고 있다는 걸 깨달았다.\n\n"
      "같은 루틴. 같은 시간. 같은 동선.\n\n"
      "{name}은 메모장을 열었다 — 이 루틴이 실제로 목표에 기여하는가.\n"
      "항목별로 체크했다. 일부는 Yes. 일부는 No.\n\n"
      "No 항목을 바꾸면 된다. 루틴은 도구다 — 목적이 아니라."
    ),
    "description_unorthodox": (
      "어느 날 {name}은 자신이 매일 같은 걸 하고 있다는 걸 깨달았다.\n\n"
      "루틴. 서울에서 루틴이 생겼다.\n\n"
      "{name}은 생각했다 — 루틴이 편안하다. 그게 경고 신호일 수 있다.\n"
      "편안함은 성장의 반대말인 경우가 많다.\n\n"
      "뭔가를 바꿔야 한다. 뭔지는 아직 모르겠지만."
    ),
    "choices": [
      {
        "text": "루틴을 유지한다 — 안정이 기반이다",
        "effects": { "mental": 2, "health": 1, "route_orthodox": 1 },
        "flags": ["arc_34_routine_seen", "kept_routine"],
        "result_text": (
          "루틴을 바꾸지 않았다.\n\n"
          "대신 루틴 안에서 작은 것을 하나 더했다.\n"
          "매일 15분. 그게 처음엔 작아 보였다."
        )
      },
      {
        "text": "루틴을 깬다 — 다른 길을 찾아야 한다",
        "effects": { "mental": -1, "luck": 2, "route_unorthodox": 1 },
        "flags": ["arc_34_routine_seen", "broke_routine"],
        "result_text": (
          "익숙한 것들을 의도적으로 바꿨다.\n\n"
          "처음 며칠은 불편했다. 그 다음엔 조금 다른 게 보이기 시작했다.\n"
          "루틴을 깨면 원래 안 보이던 것들이 보인다."
        )
      }
    ]
  }
]

midgame_path = os.path.join(ROOT, "content", "events", "arc_midgame.json")
midgame = json.load(open(midgame_path, encoding="utf-8"))
existing_ids = {e["id"] for e in midgame}
added_arc34 = 0
for ev in arc34_events:
    if ev["id"] not in existing_ids:
        midgame.append(ev)
        added_arc34 += 1
with open(midgame_path, "w", encoding="utf-8") as f:
    json.dump(midgame, f, ensure_ascii=False, indent=2)
print(f"arc_midgame.json: {added_arc34}개 추가 ({len(midgame)} 합계)")

# ──────────────────────────────────────────────────────────
# 2. LIFE_EVENTS — health(10) + comedy(10) 이벤트 추가
# ──────────────────────────────────────────────────────────
life_path = os.path.join(ROOT, "content", "events", "life_events.json")
life = json.load(open(life_path, encoding="utf-8"))
life_ids = {e["id"] for e in life}

new_events = [

# ── HEALTH 이벤트 10개 ──
{
  "id": "health_sleep_debt",
  "title": "수면 부채",
  "category": "health",
  "rarity": "common",
  "weight": 1.2,
  "conditions": {},
  "cooldown": 6,
  "description": (
    "밤새 뭔가를 했다. 잠을 못 잤다.\n\n"
    "아침에 일어나니 머리가 무거웠다.\n"
    "이 느낌이 3일째 계속되고 있었다."
  ),
  "choices": [
    {
      "text": "오늘은 무조건 일찍 잔다",
      "effects": { "health": 4, "mental": 3 },
      "result_text": "7시간. 오랜만이었다.\n다음 날 머리가 달랐다. 이게 정상 상태였구나."
    },
    {
      "text": "커피로 버틴다 — 할 게 있다",
      "effects": { "health": -4, "mental": -2, "intelligence": 1 },
      "result_text": "커피 두 잔. 버텼다. 일은 됐다.\n하지만 몸은 기억하고 있었다."
    }
  ]
},
{
  "id": "health_exercise_choice",
  "title": "운동할까 말까",
  "category": "health",
  "rarity": "common",
  "weight": 1.0,
  "conditions": {},
  "cooldown": 5,
  "description": (
    "헬스장 앞까지 왔다.\n\n"
    "들어갈까 말까. 피곤했다.\n"
    "근데 이 핑계로 안 간 게 이번이 몇 번째인지 모르겠다."
  ),
  "choices": [
    {
      "text": "들어간다",
      "effects": { "health": 5, "mental": 4 },
      "result_text": "30분. 처음 10분이 제일 힘들었다.\n나오면서 생각했다 — 역시 오길 잘했다."
    },
    {
      "text": "오늘은 쉰다",
      "effects": { "mental": 1 },
      "result_text": "집에 왔다. 누웠다.\n다음번엔 간다고 생각했다. 항상 그랬다."
    }
  ]
},
{
  "id": "health_meal_skip",
  "title": "또 끼니를 건너뛰었다",
  "category": "health",
  "rarity": "common",
  "weight": 1.1,
  "conditions": {},
  "cooldown": 4,
  "description": (
    "바빠서 밥을 못 먹었다.\n\n"
    "아니 정확히는, 안 먹은 거다. 귀찮았다.\n"
    "배가 고팠다. 근데 뭔가를 먹으러 나가기가 귀찮았다.\n\n"
    "이 달만 이미 세 번 이상이었다."
  ),
  "choices": [
    {
      "text": "나가서 뭔가 먹는다",
      "effects": { "health": 3, "money": -8000 },
      "result_text": "편의점 삼각김밥과 우유. 8천 원.\n먹고 나니 좀 살 것 같았다."
    },
    {
      "text": "그냥 잔다",
      "effects": { "health": -3, "mental": -2 },
      "result_text": "내일 아침에 먹기로 했다.\n몸이 조금 더 가벼워진 것 같기도 하고, 아닌 것 같기도 했다."
    }
  ]
},
{
  "id": "health_back_pain",
  "title": "허리",
  "category": "health",
  "rarity": "uncommon",
  "weight": 0.8,
  "conditions": {},
  "cooldown": 8,
  "description": (
    "허리가 아팠다.\n\n"
    "처음엔 좀 이상하다 싶었는데 이제 아침마다 뻣뻣했다.\n"
    "고시원 침대 매트리스가 문제인가. 자세가 문제인가. 나이가 문제인가.\n\n"
    "33살인데."
  ),
  "choices": [
    {
      "text": "병원에 간다",
      "effects": { "health": 8, "money": -50000 },
      "result_text": "정형외과. 엑스레이. 5만 원.\n근육 긴장이라고 했다. 스트레칭하라고 했다.\n5만 원짜리 조언이었지만 마음이 놓였다."
    },
    {
      "text": "그냥 참는다 — 바빠서",
      "effects": { "health": -5 },
      "result_text": "참았다.\n다음 달에는 더 나빠져 있었다."
    },
    {
      "text": "스트레칭이라도 한다",
      "effects": { "health": 3 },
      "result_text": "유튜브에서 허리 스트레칭을 찾아봤다.\n10분. 조금 나아진 것 같았다."
    }
  ]
},
{
  "id": "health_cold",
  "title": "감기",
  "category": "health",
  "rarity": "common",
  "weight": 1.2,
  "conditions": {},
  "cooldown": 6,
  "description": (
    "목이 간질간질하더니 콧물이 났다.\n\n"
    "감기였다.\n\n"
    "아프면 안 되는 타이밍이었다. 언제나 그랬다."
  ),
  "choices": [
    {
      "text": "약 사고 푹 쉰다",
      "effects": { "health": 6, "mental": 2, "money": -15000 },
      "result_text": "종합감기약. 하루 쉬었다.\n다음 날 70%는 회복됐다. 일찍 잡길 잘했다."
    },
    {
      "text": "버티면서 계속한다",
      "effects": { "health": -8, "mental": -3 },
      "result_text": "버텼다. 일주일이 걸렸다.\n그 사이 더 많은 게 무너졌다."
    }
  ]
},
{
  "id": "health_checkup_reminder",
  "title": "검진 문자",
  "category": "health",
  "rarity": "uncommon",
  "weight": 0.7,
  "conditions": {},
  "cooldown": 12,
  "description": (
    "국가건강검진 안내 문자가 왔다.\n\n"
    "올해 대상자였다. 무료.\n\n"
    "{name}은 문자를 봤다가 넘겼다. 귀찮았다.\n"
    "근데 마지막으로 검진 받은 게 언제였는지 기억이 안 났다."
  ),
  "choices": [
    {
      "text": "예약한다",
      "effects": { "health": 12, "mental": 3 },
      "result_text": "병원 예약. 혈액검사. 흉부 엑스레이.\n이상 없음이라는 말을 들었을 때 생각보다 안도가 컸다.\n몸 걱정을 안 하고 있었다고 생각했는데, 사실 하고 있었던 것 같다."
    },
    {
      "text": "나중에",
      "effects": {},
      "result_text": "나중에라고 생각했다.\n나중에는 올 것이다. 언제인지는 모른다."
    }
  ]
},
{
  "id": "health_eye_strain",
  "title": "눈이 빠질 것 같다",
  "category": "health",
  "rarity": "common",
  "weight": 1.0,
  "conditions": {},
  "cooldown": 5,
  "description": (
    "폰을 오래 봤더니 눈이 따가웠다.\n\n"
    "스크린 타임 알림이 떴다. 하루 7시간 48분.\n\n"
    "어쩌다 이렇게 됐나. 딱히 뭘 한 것도 없는데."
  ),
  "choices": [
    {
      "text": "오늘은 폰을 빨리 끈다",
      "effects": { "health": 3, "mental": 4 },
      "result_text": "밤 열 시에 폰을 끄고 책을 읽었다.\n처음 10분은 손이 폰을 찾았다.\n30분 후엔 그냥 읽고 있었다."
    },
    {
      "text": "조금 더 한다",
      "effects": { "health": -3, "mental": -2 },
      "result_text": "한다고 했지만 딱히 유익한 건 없었다.\n자려고 누웠는데 눈이 계속 깜빡였다."
    }
  ]
},
{
  "id": "health_tension_headache",
  "title": "편두통",
  "category": "health",
  "rarity": "common",
  "weight": 1.1,
  "conditions": { "max_mental": 50 },
  "cooldown": 6,
  "description": (
    "머리 한쪽이 지끈거렸다.\n\n"
    "스트레스성 편두통. 한 달에 한두 번은 온다.\n\n"
    "{name}은 진통제 위치를 알았다. 가방 안쪽 주머니."
  ),
  "choices": [
    {
      "text": "약 먹고 잠깐 눕는다",
      "effects": { "health": 4, "mental": 2 },
      "result_text": "20분 누웠다. 일어났더니 좀 나아졌다.\n몸이 쉬라고 말하는 방식이었다."
    },
    {
      "text": "그냥 버틴다",
      "effects": { "health": -4, "mental": -3 },
      "result_text": "버텼다. 두 시간 후에 더 심해졌다."
    }
  ]
},
{
  "id": "health_diet_choice",
  "title": "뭘 먹을까",
  "category": "health",
  "rarity": "common",
  "weight": 0.9,
  "conditions": {},
  "cooldown": 5,
  "description": (
    "점심 시간. {name}은 밖에 나왔다.\n\n"
    "왼쪽엔 국밥 7,000원. 오른쪽엔 편의점 도시락 4,500원.\n"
    "직진하면 24시 치킨 반반 17,000원.\n\n"
    "서울에서 밥 한 끼가 이렇게 복잡할 줄 몰랐다."
  ),
  "choices": [
    {
      "text": "국밥 — 몸을 챙긴다",
      "effects": { "health": 4, "mental": 2, "money": -7000 },
      "result_text": "뜨거운 국밥 한 그릇.\n몸이 좀 따뜻해졌다. 7,000원의 가치가 있었다."
    },
    {
      "text": "편의점 도시락 — 아끼자",
      "effects": { "health": -1, "money": -4500 },
      "result_text": "4,500원. 먹었다. 허전했다.\n배는 차는데 만족은 없는 식사."
    }
  ]
},
{
  "id": "health_mental_burnout_signal",
  "title": "신호",
  "category": "health",
  "rarity": "uncommon",
  "weight": 0.8,
  "conditions": { "max_mental": 40 },
  "cooldown": 8,
  "description": (
    "아무것도 하기 싫은 날이었다.\n\n"
    "해야 하는 건 있었다. 근데 몸이 안 움직였다.\n"
    "이불 밖이 너무 멀었다.\n\n"
    "{name}은 생각했다 — 이게 번아웃인가."
  ),
  "choices": [
    {
      "text": "오늘 하루는 쉰다 — 진짜로",
      "effects": { "mental": 8, "health": 3 },
      "result_text": "이불 속에서 하루를 보냈다.\n죄책감이 들었다가, 좀 지나니 괜찮아졌다.\n내일은 다를 것 같았다."
    },
    {
      "text": "억지로 일어난다",
      "effects": { "mental": -4, "intelligence": 1 },
      "result_text": "일어났다. 뭔가를 했다.\n몸은 움직였지만 머리가 없었다.\n효율이 반도 안 됐다."
    }
  ]
},

# ── COMEDY 이벤트 10개 ──
{
  "id": "comedy_lunch_menu",
  "title": "점심 메뉴 결정 20분",
  "category": "comedy",
  "rarity": "common",
  "weight": 1.3,
  "conditions": { "has_job": True },
  "cooldown": 5,
  "description": (
    "\"오늘 뭐 먹을까요?\"\n\n"
    "이 질문이 나온 지 20분이 됐다.\n\n"
    "치킨? 어제 먹었다. 국밥? 질렸다. 파스타? 누가 비싸다고 했다.\n"
    "중국집? 탕수육 소스 찍먹 부먹으로 10분이 날아갈 것 같았다.\n\n"
    "{name}은 배가 고팠다. 점심 시간은 줄어들고 있었다."
  ),
  "choices": [
    {
      "text": "아무 데나 정해버린다",
      "effects": { "mental": 2, "social_skill": 1 },
      "result_text": "\"저 편의점 가겠습니다.\"\n5분 만에 먹었다. 회의 시간 안에 왔다.\n리더십이란 결국 결정하는 것이다."
    },
    {
      "text": "계속 의논한다",
      "effects": { "mental": -1 },
      "result_text": "결국 국밥집에서 밥 먹고 5분 지각했다.\n팀장이 봤다. 팀장도 늦었기 때문에 아무 말 없었다."
    }
  ]
},
{
  "id": "comedy_elevator_awkward",
  "title": "엘리베이터 2층",
  "category": "comedy",
  "rarity": "common",
  "weight": 1.2,
  "conditions": { "has_job": True },
  "cooldown": 6,
  "description": (
    "엘리베이터에 혼자 탔다.\n\n"
    "2층 버튼을 눌렀다.\n\n"
    "문이 닫히는 순간 계단으로 갔으면 빨랐을 거란 걸 깨달았다.\n"
    "이미 닫혔다.\n\n"
    "{name}은 앞을 봤다. 숫자가 1에서 2로 바뀌는 걸 기다렸다."
  ),
  "choices": [
    {
      "text": "그냥 탄다 — 이미 탔으니까",
      "effects": { "mental": 1 },
      "result_text": "2층. 문이 열렸다.\n아무도 없었다. 다행이었다."
    },
    {
      "text": "다음엔 계단을 쓴다 (다짐)",
      "effects": { "health": 1 },
      "result_text": "다짐했다.\n다음 날도 엘리베이터를 탔다."
    }
  ]
},
{
  "id": "comedy_office_printer",
  "title": "프린터와의 전쟁",
  "category": "comedy",
  "rarity": "common",
  "weight": 1.1,
  "conditions": { "has_job": True },
  "cooldown": 6,
  "description": (
    "프린터가 안 됐다.\n\n"
    "전원 켜짐. 연결됨. 근데 안 됨.\n\n"
    "껐다 켰다. 드라이버 재설치. USB로 연결. 와이파이로 다시.\n"
    "30분이 지났다.\n\n"
    "옆 자리 대리가 왔다. 버튼 하나 눌렀다. 됐다."
  ),
  "choices": [
    {
      "text": "감사합니다 (진심으로)",
      "effects": { "social_skill": 1, "mental": 1 },
      "result_text": "대리가 씩 웃고 갔다.\n{name}은 그 버튼을 메모해뒀다."
    },
    {
      "text": "왜 되는 거죠 (진심으로)",
      "effects": { "intelligence": 1 },
      "result_text": '"그냥요." 대리가 갔다.\n{name}은 10분 더 고민했다. 여전히 모르겠다.'
    }
  ]
},
{
  "id": "comedy_convenience_1plus1",
  "title": "1+1의 함정",
  "category": "comedy",
  "rarity": "common",
  "weight": 1.4,
  "conditions": {},
  "cooldown": 4,
  "description": (
    "편의점에 갔다.\n\n"
    "삼각김밥 하나 사러 들어갔는데\n"
    "1+1 행사를 발견했다.\n\n"
    "과자. 음료. 아이스크림. 컵라면.\n\n"
    "계산대에 서니 5개를 들고 있었다.\n"
    "원래 3,500원인데 11,000원이 찍혔다."
  ),
  "choices": [
    {
      "text": "그냥 다 산다 — 1+1은 거부할 수 없다",
      "effects": { "mental": 3, "money": -11000 },
      "result_text": "사야 한다. 1+1은 사야 한다.\n집에 와서 냉장고를 열었다. 이미 같은 게 두 개 있었다."
    },
    {
      "text": "원래 살 것만 산다",
      "effects": { "money": -3500, "mental": -1 },
      "result_text": "3,500원만 냈다.\n나오면서 1+1이 계속 생각났다.\n잘한 건지 모르겠다."
    }
  ]
},
{
  "id": "comedy_subway_seat",
  "title": "빈자리",
  "category": "comedy",
  "rarity": "common",
  "weight": 1.2,
  "conditions": {},
  "cooldown": 5,
  "description": (
    "지하철에 빈자리가 있었다.\n\n"
    "{name}과 옆 사람이 동시에 봤다.\n\n"
    "0.5초의 눈빛 교환."
  ),
  "choices": [
    {
      "text": "앉는다",
      "effects": { "mental": 2 },
      "result_text": "앉았다. 상대방도 그 옆에 앉았다.\n둘 다 폰을 꺼냈다. 서울."
    },
    {
      "text": "양보한다",
      "effects": { "social_skill": 1, "mental": 1 },
      "result_text": "손짓했다. 상대방이 앉았다. 고개를 끄덕였다.\n{name}은 손잡이를 잡고 섰다.\n나쁘지 않은 기분이었다."
    }
  ]
},
{
  "id": "comedy_group_chat",
  "title": "단체 카톡",
  "category": "comedy",
  "rarity": "common",
  "weight": 1.3,
  "conditions": { "has_job": True },
  "cooldown": 5,
  "description": (
    "회사 단체 카톡방에 메시지가 200개 쌓였다.\n\n"
    "점심 시간에 확인해보니 팀장이 아침 9시에 올린 공지 하나에 대한 반응들이었다.\n\n"
    "\"감사합니다\" \"확인했습니다\" \"알겠습니다\"\n\n"
    "198개.\n\n"
    "{name}은 자기도 보내야 하는지 생각했다."
  ),
  "choices": [
    {
      "text": "\"확인했습니다\" 보낸다",
      "effects": { "social_skill": 1 },
      "result_text": "보냈다. 199번째 확인했습니다였다.\n팀장이 이모티콘으로 답했다."
    },
    {
      "text": "안 보낸다 — 이미 200개잖아",
      "effects": { "mental": 1 },
      "result_text": "안 보냈다.\n아무도 몰랐다. 아마도."
    }
  ]
},
{
  "id": "comedy_cafe_seat_war",
  "title": "카페 자리 전쟁",
  "category": "comedy",
  "rarity": "common",
  "weight": 1.1,
  "conditions": {},
  "cooldown": 5,
  "description": (
    "카페에 들어갔다.\n\n"
    "자리가 없었다. 15개 테이블 중 12개에 사람이 없고 짐만 있었다.\n\n"
    "짐들은 주인을 기다리고 있었다.\n"
    "아마도."
  ),
  "choices": [
    {
      "text": "짐 있는 자리 옆에 앉아서 기다린다",
      "effects": { "mental": -1, "intelligence": 1 },
      "result_text": "30분 기다렸다. 주인이 왔다. 화장실 다녀왔다고 했다.\n30분짜리 화장실이었다."
    },
    {
      "text": "다른 카페로 간다",
      "effects": { "money": -1000 },
      "result_text": "다른 카페로 갔다. 거기도 비슷했다.\n하지만 창가 자리를 잡았다. 잘했다고 생각했다."
    }
  ]
},
{
  "id": "comedy_wrong_floor",
  "title": "잘못 내렸다",
  "category": "comedy",
  "rarity": "common",
  "weight": 1.0,
  "conditions": {},
  "cooldown": 7,
  "description": (
    "지하철에서 졸다가 잘못 내렸다.\n\n"
    "눈을 떴을 때 문이 닫히고 있었다.\n\n"
    "역 이름이 달랐다. 두 정거장 지나쳤다."
  ),
  "choices": [
    {
      "text": "웃으면서 다음 열차 기다린다",
      "effects": { "mental": 2 },
      "result_text": "6분 기다렸다. 별거 아니었다.\n이런 날도 있다."
    },
    {
      "text": "자신에게 화가 난다",
      "effects": { "mental": -2 },
      "result_text": "6분을 손해봤다고 생각했다.\n나중에 그 6분이 생각나진 않았다."
    }
  ]
},
{
  "id": "comedy_autocorrect",
  "title": "자동완성의 배신",
  "category": "comedy",
  "rarity": "common",
  "weight": 1.2,
  "conditions": {},
  "cooldown": 6,
  "description": (
    "카톡을 보내고 나서 다시 봤다.\n\n"
    "\"내일 미팅 가능하신가요\"가\n"
    "\"내일 마팅 가능하신가요\"로 보내졌다.\n\n"
    "상대방이 이미 읽었다."
  ),
  "choices": [
    {
      "text": "바로 정정 메시지를 보낸다",
      "effects": { "social_skill": 1 },
      "result_text": '"*미팅이요 ㅠ"\n상대방이 ㅋㅋ 하고 답했다.\n인간적으로 보였을 수도 있다.'
    },
    {
      "text": "그냥 넘어간다 — 맥락상 안다",
      "effects": { "mental": 1 },
      "result_text": "아무 말 안 했다.\n상대방도 아무 말 안 했다.\n미팅은 잡혔다."
    }
  ]
},
{
  "id": "comedy_umchinah",
  "title": "엄친아의 등장",
  "category": "comedy",
  "rarity": "uncommon",
  "weight": 0.9,
  "conditions": {},
  "cooldown": 8,
  "description": (
    "어머니한테서 전화가 왔다.\n\n"
    "\"옆집 민수 알지? 이번에 대기업 붙었대. 결혼도 한다더라.\"\n\n"
    "{name}은 민수를 기억했다. 고3 때 반에서 꼴등이었다.\n\n"
    "\"그래요, 잘됐네요.\"\n\n"
    "어머니는 잠깐 멈췄다."
  ),
  "choices": [
    {
      "text": "\"나도 잘 되고 있어요\"",
      "effects": { "mental": 1, "social_skill": 1 },
      "result_text": '"그래, 그래야지."\n어머니가 전화를 끊었다.\n{name}은 뭔가 잘 되고 있는 건지 생각해봤다.'
    },
    {
      "text": "\"...네\" (침묵)",
      "effects": { "mental": -2 },
      "result_text": "전화를 끊었다.\n민수가 꼴등이었던 게 맞나 다시 생각해봤다. 맞는 것 같았다.\n근데 지금은 관계없다."
    }
  ]
},
]

added_life = 0
for ev in new_events:
    if ev["id"] not in life_ids:
        life.append(ev)
        life_ids.add(ev["id"])
        added_life += 1

with open(life_path, "w", encoding="utf-8") as f:
    json.dump(life, f, ensure_ascii=False, indent=2)
print(f"life_events.json: {added_life}개 추가 ({len(life)} 합계)")

# ──────────────────────────────────────────────────────────
# 3. 현수 아크 이벤트 (신규 파일)
# ──────────────────────────────────────────────────────────
hyunsu_events = [
  {
    "id": "hyunsu_study_together",
    "title": "같이 공부하는 사람",
    "category": "relationship",
    "rarity": "uncommon",
    "weight": 0.8,
    "conditions": { "flag": "met_hyunsu" },
    "cooldown": 10,
    "portrait": "hyunsu",
    "background": "goshiwon_room",
    "description": (
      "고시원 주방에서 현수를 또 만났다.\n\n"
      "이번에도 라면이었다. 새벽 두 시.\n\n"
      "\"형은 뭐 해요? 원서 준비해요?\"\n\n"
      "9급 공시 4년째라고 했다. 올해가 마지막이라고.\n"
      "표정은 지쳤지만 포기한 것 같진 않았다."
    ),
    "choices": [
      {
        "text": "응원한다",
        "effects": { "social_skill": 1, "mental": 1 },
        "flags": ["hyunsu_encouraged"],
        "result_text": (
          '"올해는 될 거야."\n\n'
          "현수가 씩 웃었다. 진짜 웃음 같았다.\n"
          '"형도 잘 될 거예요."\n\n'
          "{name}은 그 말이 생각보다 오래 남았다."
        )
      },
      {
        "text": "4년이면 오래됐다고 한다",
        "effects": { "social_skill": 1 },
        "flags": ["hyunsu_talked_candidly"],
        "result_text": (
          '"오래됐죠. 근데 지금 그만두면 더 오래 후회할 것 같아서요."\n\n'
          "{name}은 그 말을 이해했다.\n"
          "다른 길로 가는 것과 이 길을 계속 가는 것 — 어느 쪽이 맞는지는 나중에 안다."
        )
      }
    ]
  },
  {
    "id": "hyunsu_exam_day",
    "title": "시험 날",
    "category": "relationship",
    "rarity": "uncommon",
    "weight": 0,
    "hidden": True,
    "conditions": { "flag": "met_hyunsu", "min_turn": 24 },
    "cooldown": 9999,
    "portrait": "hyunsu",
    "background": "goshiwon_room",
    "description": (
      "현수가 새벽 다섯 시에 나갔다.\n\n"
      "{name}은 문 소리에 잠깐 깼다가 다시 눈을 감았다.\n\n"
      "오늘이 시험 날이었다. 9급 행정직."
    ),
    "choices": [
      {
        "text": "나중에 결과를 물어본다",
        "effects": { "social_skill": 1 },
        "flags": ["hyunsu_exam_day_seen"],
        "result_text": (
          "저녁에 현수가 돌아왔다.\n"
          "\"어땠어?\"\n\n"
          "현수는 잠깐 멈췄다가 대답했다.\n"
          "\"잘 본 것 같아요. 아마도.\"\n\n"
          "아마도. 그 단어가 많은 걸 담고 있었다."
        )
      },
      {
        "text": "아무 말 안 한다 — 건드리지 않는 게 낫다",
        "effects": {},
        "flags": ["hyunsu_exam_day_seen"],
        "result_text": (
          "현수는 저녁에 조용히 들어왔다.\n"
          "{name}은 마주쳤을 때 눈빛으로만 물었다.\n"
          "현수는 고개를 살짝 끄덕였다. 괜찮다는 신호였다."
        )
      }
    ]
  },
  {
    "id": "hyunsu_result_pass",
    "title": "현수, 붙었다",
    "category": "relationship",
    "rarity": "rare",
    "weight": 0,
    "hidden": True,
    "conditions": { "flag": "hyunsu_exam_day_seen" },
    "cooldown": 9999,
    "portrait": "hyunsu",
    "background": "goshiwon_room",
    "description": (
      "현수가 문을 두드렸다.\n\n"
      "\"형, 붙었어요.\"\n\n"
      "조용히 말했다. 소리를 지르거나 하지 않았다.\n"
      "4년의 무게가 느껴지는 목소리였다."
    ),
    "choices": [
      {
        "text": "축하한다",
        "effects": { "mental": 3, "social_skill": 1 },
        "flags": ["hyunsu_passed", "hyunsu_relationship_close"],
        "result_text": (
          '"야, 진짜? 잘됐다."\n\n'
          "현수가 웃었다. 그때 처음으로 환하게 웃는 걸 봤다.\n\n"
          "{name}은 자기 일처럼 기분이 좋았다.\n"
          "남의 성공이 기쁠 때 — 그게 진짜 관계라는 신호인지도 모른다."
        )
      }
    ]
  },
  {
    "id": "hyunsu_result_fail",
    "title": "현수, 떨어졌다",
    "category": "relationship",
    "rarity": "uncommon",
    "weight": 0,
    "hidden": True,
    "conditions": { "flag": "hyunsu_exam_day_seen", "no_flag": "hyunsu_passed" },
    "cooldown": 9999,
    "portrait": "hyunsu",
    "background": "goshiwon_room",
    "description": (
      "현수가 사흘째 방에만 있었다.\n\n"
      "밥 먹는 소리가 안 들렸다.\n\n"
      "{name}은 문 앞에 섰다. 두드려야 하나."
    ),
    "choices": [
      {
        "text": "문을 두드린다",
        "effects": { "social_skill": 2, "mental": 1 },
        "flags": ["hyunsu_failed", "hyunsu_comforted"],
        "result_text": (
          "한참 후에 문이 열렸다.\n\n"
          "현수 눈이 부었다.\n\n"
          "말을 많이 하지 않았다. 편의점에서 음료 두 개 사다 줬다.\n"
          "그걸로 충분했다. 때로는 그게 전부다."
        )
      },
      {
        "text": "건드리지 않는다 — 혼자 있고 싶을 것 같다",
        "effects": { "intelligence": 1 },
        "flags": ["hyunsu_failed"],
        "result_text": (
          "나흘째 되던 날 현수가 나왔다.\n\n"
          "아무 말 없이 세수를 했다.\n"
          "{name}과 눈이 마주쳤다. 현수가 작게 고개를 끄덕였다.\n\n"
          "괜찮다는 건지, 아직 모르겠다는 건지."
        )
      }
    ]
  },
  {
    "id": "hyunsu_pivot",
    "title": "현수, 다른 길",
    "category": "relationship",
    "rarity": "uncommon",
    "weight": 0,
    "hidden": True,
    "conditions": { "flag": "hyunsu_failed", "min_turn": 30 },
    "cooldown": 9999,
    "portrait": "hyunsu",
    "background": "goshiwon_room",
    "description": (
      "현수가 이사한다고 했다.\n\n"
      "공시를 그만두고 취업 준비를 한다고.\n"
      "전공이 회계학이었다. 회계사 공부를 다시 시작한다고.\n\n"
      "\"더 멀지도 않고 더 가깝지도 않아요. 그냥 다른 길이에요.\"\n\n"
      "{name}은 그 말을 오래 생각했다."
    ),
    "choices": [
      {
        "text": "잘될 거라고 한다",
        "effects": { "social_skill": 1, "mental": 2 },
        "flags": ["hyunsu_pivoted"],
        "result_text": (
          '"잘 될 거야."\n\n'
          "현수가 웃었다. 이번엔 좀 더 단단한 웃음이었다.\n\n"
          "다른 길을 선택하는 것과 포기하는 것은 다르다.\n"
          "{name}은 그걸 현수한테서 배웠다."
        )
      }
    ]
  },
  {
    "id": "hyunsu_reunion_later",
    "title": "현수에게서 연락이 왔다",
    "category": "relationship",
    "rarity": "rare",
    "weight": 0,
    "hidden": True,
    "conditions": { "flag": "hyunsu_pivoted", "min_turn": 60 },
    "cooldown": 9999,
    "portrait": "hyunsu",
    "background": "office_building",
    "description": (
      "카톡이 왔다. 현수였다.\n\n"
      "\"형, 저 회계법인 취직했어요.\"\n\n"
      "사진이 왔다. 정장. 명함.\n\n"
      "{name}은 사진을 한참 봤다."
    ),
    "choices": [
      {
        "text": "축하 메시지를 보낸다",
        "effects": { "mental": 4, "social_skill": 1 },
        "flags": ["hyunsu_reconnected"],
        "result_text": (
          '"야 진짜? 잘됐다!!"\n\n'
          '"형 덕분이에요. 그때 문 두드려줘서."\n\n'
          "{name}은 폰을 내려놓았다.\n\n"
          "서울에서 5년. 이런 연락이 오는 날도 있다."
        )
      }
    ]
  }
]

hyunsu_path = os.path.join(ROOT, "content", "events", "arc_hyunsu.json")
with open(hyunsu_path, "w", encoding="utf-8") as f:
    json.dump(hyunsu_events, f, ensure_ascii=False, indent=2)
print(f"arc_hyunsu.json: {len(hyunsu_events)}개 생성")

# ──────────────────────────────────────────────────────────
# 4. 어머니 이벤트 (callback_events_28.json 신규)
# ──────────────────────────────────────────────────────────
mother_events = [
  {
    "id": "mother_call_compare",
    "title": "어머니 전화",
    "category": "family",
    "rarity": "common",
    "weight": 0.8,
    "conditions": { "min_turn": 8 },
    "cooldown": 12,
    "portrait": "mother",
    "background": "family_home",
    "description": (
      "어머니한테서 전화가 왔다.\n\n"
      "\"밥은 먹냐. 잘 자냐.\"\n\n"
      "그리고 잠깐의 침묵 후에,\n"
      "\"수원 정 씨 딸 있잖아. 공무원 됐대. 결혼도 한다더라.\"\n\n"
      "{name}은 정 씨 딸을 모른다. 아마 어머니도 잘 모를 것이다."
    ),
    "choices": [
      {
        "text": "\"그래요, 잘됐네요\"",
        "effects": { "mental": 1 },
        "result_text": (
          '"그래, 잘됐지."\n'
          "어머니 목소리가 조금 멀어졌다.\n\n"
          "\"...잘 지내야 해.\"\n\n"
          "{name}은 전화를 끊고 천장을 봤다.\n"
          "어머니가 걱정한다는 건 안다. 표현 방식이 그럴 뿐."
        )
      },
      {
        "text": "\"저도 잘 되고 있어요\"",
        "effects": { "mental": 2, "social_skill": 1 },
        "result_text": (
          '"그래?" 어머니 목소리가 조금 밝아졌다.\n\n'
          '"뭘 하는 건데?"\n\n'
          "설명했다. 길게. 어머니가 끝까지 들었다.\n"
          "\"그래, 열심히 해라.\"\n\n"
          "그 한 마디가 생각보다 오래 남았다."
        )
      }
    ]
  },
  {
    "id": "mother_seoul_visit",
    "title": "어머니가 서울에 왔다",
    "category": "family",
    "rarity": "uncommon",
    "weight": 0,
    "hidden": True,
    "conditions": { "flag": "arc_34_parents_visited", "min_turn": 30 },
    "cooldown": 9999,
    "portrait": "mother",
    "background": "goshiwon_room",
    "description": (
      "어머니가 혼자 서울에 왔다.\n\n"
      "아버지는 일이 있다고 했다. 어머니만 왔다.\n\n"
      "고시원 방을 다시 봤다. 저번과 같았다. 달라진 건 없었다.\n\n"
      "어머니가 청소를 시작했다. 아무 말 없이."
    ),
    "choices": [
      {
        "text": "같이 청소한다",
        "effects": { "mental": 5, "health": 2 },
        "flags": ["mother_visited_alone"],
        "result_text": (
          "두 시간 동안 청소했다.\n\n"
          "거의 말이 없었다.\n\n"
          "끝나고 어머니가 뭔가를 남겨두고 갔다.\n"
          "반찬이었다. 냉장고에 넣으라고.\n\n"
          "{name}은 한참 그 반찬통을 봤다."
        )
      },
      {
        "text": "밖에 나가서 밥을 먹자고 한다",
        "effects": { "mental": 3, "money": -40000 },
        "flags": ["mother_visited_alone"],
        "result_text": (
          "삼겹살집. 어머니는 고기를 구워줬다.\n\n"
          "\"맛있게 먹어라.\"\n\n"
          "{name}은 먹었다. 오랜만에 집밥 같은 게 먹고 싶었는데\n"
          "삼겹살이 그것과 가까운 것 같았다."
        )
      }
    ]
  },
  {
    "id": "mother_reconcile_moment",
    "title": "어머니와 한 마디",
    "category": "family",
    "rarity": "rare",
    "weight": 0,
    "hidden": True,
    "conditions": { "flag": "mother_visited_alone", "min_turn": 100 },
    "cooldown": 9999,
    "portrait": "mother",
    "background": "hangang_night",
    "description": (
      "전화를 받았다. 어머니.\n\n"
      "\"아들, 나 요즘 꿈에 니가 자꾸 나오더라.\"\n\n"
      "이런 말을 처음 했다.\n\n"
      "{name}은 잠깐 멈췄다."
    ),
    "choices": [
      {
        "text": "\"엄마, 나 잘 하고 있어\"",
        "effects": { "mental": 6, "social_skill": 1 },
        "flags": ["mother_reconciled"],
        "result_text": (
          "어머니가 조용했다.\n\n"
          '"그래, 믿는다."\n\n'
          "그 한 마디.\n\n"
          "{name}은 전화를 끊고 나서 눈이 조금 따가웠다.\n"
          "피곤해서일 것이다."
        )
      },
      {
        "text": "\"엄마도 잘 지내?\"",
        "effects": { "mental": 4 },
        "flags": ["mother_reconnected"],
        "result_text": (
          '"나야 뭐, 그럭저럭."\n\n'
          "어머니 목소리가 평소보다 부드러웠다.\n\n"
          "오래 통화했다. 별 내용은 없었다.\n"
          "근데 필요한 통화였다."
        )
      }
    ]
  }
]

cb28_path = os.path.join(ROOT, "content", "events", "callback_events_28.json")
with open(cb28_path, "w", encoding="utf-8") as f:
    json.dump(mother_events, f, ensure_ascii=False, indent=2)
print(f"callback_events_28.json: {len(mother_events)}개 생성")

print("\n모든 콘텐츠 추가 완료.")
