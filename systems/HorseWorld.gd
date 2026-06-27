extends RefCounted
class_name HorseWorld
## 경마 '세계' 레이어 — 영속 명마 로스터 + 과거전적 + 정보상 팁(진짜/가짜).
## HorseRace(순수 레이스 수학) 위에 '학습되는 세계'를 얹는다:
##  - 말은 영속 정체성(클래스·선호거리·선호마장·주행스타일·기수)을 갖고 재등장.
##  - 매 경주 결과가 각 말의 전적(history)에 누적 → 플레이어가 폼을 '기억'으로 읽음.
##  - 정보상 팁: 한 마리를 지목. 절반은 진짜(저평가 노림수), 절반은 함정(작전).
##    안목(지력)이 높으면 신뢰도 단서가 진실과 잘 맞아 = 정보 비대칭이 스킬.
## 상태는 GameState.flags["horse_world"]에 직렬화 → 씬 리로드·세이브 견딤.

const HR := preload("res://systems/HorseRace.gd")
const ROSTER_SIZE := 14
const HIST_KEEP := 6

static func name_entry_pool() -> Array:
	return [
		{"id": 0, "name": LocaleManager.ui("번개", "Lightning")},
		{"id": 1, "name": LocaleManager.ui("질풍", "Gale")},
		{"id": 2, "name": LocaleManager.ui("흑운", "Black Cloud")},
		{"id": 3, "name": LocaleManager.ui("천리마", "Cheollima")},
		{"id": 4, "name": LocaleManager.ui("불꽃", "Spark")},
		{"id": 5, "name": LocaleManager.ui("새벽별", "Morning Star")},
		{"id": 6, "name": LocaleManager.ui("강철", "Ironclad")},
		{"id": 7, "name": LocaleManager.ui("행운아", "Lucky One")},
		{"id": 8, "name": LocaleManager.ui("폭풍", "Storm")},
		{"id": 9, "name": LocaleManager.ui("은하수", "Milky Way")},
		{"id": 10, "name": LocaleManager.ui("대박이", "Jackpot")},
		{"id": 11, "name": LocaleManager.ui("무쇠", "Cast Iron")},
		{"id": 12, "name": LocaleManager.ui("칼바람", "Knife Wind")},
		{"id": 13, "name": LocaleManager.ui("승리호", "Victory")},
		{"id": 14, "name": LocaleManager.ui("바람돌이", "Windrunner")},
		{"id": 15, "name": LocaleManager.ui("검은별", "Black Star")},
		{"id": 16, "name": LocaleManager.ui("적토마", "Red Hare")},
		{"id": 17, "name": LocaleManager.ui("청룡", "Blue Dragon")},
	]

static func track_name(idx: int) -> String:
	match idx:
		0: return LocaleManager.ui("건조", "Dry")
		1: return LocaleManager.ui("양호", "Good")
		_: return LocaleManager.ui("다습", "Wet")

static func style_name(idx: int) -> String:
	return LocaleManager.ui("선행", "Front-runner") if idx == 0 else LocaleManager.ui("추입", "Closer")

static func display_name(horse: Dictionary) -> String:
	if horse.has("name_id"):
		for entry in name_entry_pool():
			if int(entry["id"]) == int(horse["name_id"]):
				return str(entry["name"])
	return str(horse.get("name", "?"))

# ── 로스터 보장 (최초 1회 영속 명마 생성) ───────────────────────
static func ensure(world: Dictionary, rng: RandomNumberGenerator) -> void:
	if world.has("roster") and not (world["roster"] as Array).is_empty():
		return
	var names: Array = name_entry_pool()
	for i in range(names.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var t = names[i]; names[i] = names[j]; names[j] = t
	var roster: Array = []
	for i in range(ROSTER_SIZE):
		var entry: Dictionary = names[i]
		roster.append({
			"id": i,
			"name_id": int(entry["id"]),
			"name": str(entry["name"]),
			"cls": rng.randf_range(0.70, 1.70),          # 영속 클래스(진짜 실력 기반)
			"dist_pref": [1200, 1400, 1600, 1800, 2000][rng.randi() % 5],
			"cond_pref": rng.randi() % 3,                  # 선호 마장 (TRACKS 인덱스)
			"style": rng.randi() % 2,                       # 0 선행 / 1 추입
			"jockey": rng.randf_range(0.90, 1.15),
			"history": [],                                  # [{turn,dist,track,pos,n}]
			"starts": 0, "wins": 0,
		})
	world["roster"] = roster

# ── 오늘의 출주표 생성 ──────────────────────────────────────────
## 로스터에서 n마리 추첨 → 이번 경주 거리/마장에 맞춰 영속 정체성을 폼으로 환산.
## 반환 race는 HorseRace 정산/시뮬과 호환(horses[]에 base/dist_apt/cond_apt/jockey/
## effective/odds/sig_* 포함) + 각 horse에 rid/style/history/recent 부가.
static func make_card(world: Dictionary, rng: RandomNumberGenerator, info_level: float) -> Dictionary:
	ensure(world, rng)
	var roster: Array = world["roster"]
	var distance: int = [1200, 1400, 1600, 1800, 2000][rng.randi() % 5]
	var track_i: int = rng.randi() % 3
	var track: String = track_name(track_i)
	var n: int = rng.randi_range(5, 7)

	# 로스터에서 무작위 n마리
	var pool: Array = roster.duplicate()
	for i in range(pool.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var t = pool[i]; pool[i] = pool[j]; pool[j] = t
	var runners: Array = pool.slice(0, n)

	var horses: Array = []
	for r in runners:
		var dist_fit: float = clampf(1.0 - abs(float(distance) - float(r["dist_pref"])) / 1600.0, 0.0, 1.0)
		var dist_apt: float = 0.82 + 0.40 * dist_fit
		var cd: int = int(r["cond_pref"])
		var diff: int = abs(cd - track_i)
		var cond_fit: float = 1.0 if diff == 0 else (0.5 if diff == 1 else 0.2)
		var cond_apt: float = 0.86 + 0.32 * cond_fit
		# 주행스타일 × 마장 상호작용 (다습=추입 유리, 건조=선행 유리)
		if track_i == 2 and int(r["style"]) == 1: cond_apt *= 1.05
		elif track_i == 0 and int(r["style"]) == 0: cond_apt *= 1.04
		var jockey: float = clampf(float(r["jockey"]) * rng.randf_range(0.98, 1.02), 0.85, 1.18)
		var base: float = float(r["cls"])                       # 관측 가능 클래스(전적·★)
		var today_form: float = rng.randf_range(0.86, 1.14)     # 숨은 당일 컨디션
		var effective: float = base * dist_apt * cond_apt * jockey * today_form
		horses.append({
			"name": display_name(r), "name_id": int(r.get("name_id", -1)), "rid": int(r["id"]), "style": int(r["style"]),
			"dist_pref": int(r["dist_pref"]), "cond_pref": int(r["cond_pref"]),
			"base": base, "dist_apt": dist_apt, "cond_apt": cond_apt, "jockey": jockey,
			"effective": effective,
			"history": (r["history"] as Array).duplicate(),
			"recent": _recent_str(r["history"]),
			"record": LocaleManager.ui("%d전 %d승", "%d starts %d wins") % [int(r["starts"]), int(r["wins"])],
		})

	HR._compute_signals(horses, info_level, rng)
	HR._compute_odds(horses, rng)

	# 숨은 호조 (live one): 공개 배당·★엔 안 잡히는 진짜 컨디션 급등. 정보상 '진짜 팁'이
	# 가리키는 대상. 인기마(배당<4) 말고 중하위에서 골라 '저평가 대박마'가 되게 한다.
	# → 가시정보만으론 절대 못 찾고, 진짜 팁(=내부정보)만이 짚어준다 = 드라마가 알파.
	var live: int = -1
	if rng.randf() < 0.5:
		var cand: Array = []
		for i in range(horses.size()):
			if float(horses[i]["odds"]) >= 4.0:
				cand.append(i)
		if cand.is_empty():
			for i in range(horses.size()): cand.append(i)
		live = int(cand[rng.randi() % cand.size()])
		horses[live]["effective"] = float(horses[live]["effective"]) * 1.70
	return {"distance": distance, "track": track, "track_i": track_i, "horses": horses, "live": live}

## 최근 전적 문자열 (예: "1-3-2", 최신이 왼쪽)
static func _recent_str(history: Array) -> String:
	if history.is_empty():
		return LocaleManager.ui("신마", "Debut")
	var parts: Array = []
	for k in range(min(history.size(), 5)):
		parts.append(str(int(history[k]["pos"])))
	return "-".join(parts)

# ── 경주 결과를 로스터 전적에 기록 ──────────────────────────────
static func record(world: Dictionary, race: Dictionary, finish: Array, turn: int) -> void:
	var roster: Array = world["roster"]
	var by_id: Dictionary = {}
	for r in roster:
		by_id[int(r["id"])] = r
	for pos in range(finish.size()):
		var h: Dictionary = finish[pos]
		var rid: int = int(h["rid"])
		if not by_id.has(rid): continue
		var r: Dictionary = by_id[rid]
		var hist: Array = r["history"]
		hist.push_front({"turn": turn, "dist": int(race["distance"]),
			"track": str(race["track"]), "pos": pos + 1, "n": finish.size()})
		while hist.size() > HIST_KEEP:
			hist.pop_back()
		r["starts"] = int(r["starts"]) + 1
		if pos == 0:
			r["wins"] = int(r["wins"]) + 1

# ── 정보상 팁 (진짜/가짜) ───────────────────────────────────────
## 한 마리를 지목. is_true면 진짜 저평가(밸류), 아니면 함정(작전세력 띄우기).
## cred(신뢰도 단서)는 지력이 높을수록 진실과 잘 맞는다 = 정보 간파 스킬.
static func gen_tip(race: Dictionary, rng: RandomNumberGenerator, info_level: float) -> Dictionary:
	var horses: Array = race["horses"]
	var live: int = int(race.get("live", -1))
	# 진짜 팁은 'live one'(숨은 호조마)을 가리킨다. live가 있어도 정보상이 항상 알진 않음(0.7).
	# live가 없으면 팁은 전부 함정. → 진짜 팁을 따르면 +EV, 함정은 -EV.
	var is_true: bool = live >= 0 and rng.randf() < 0.70
	var target: int
	if is_true:
		target = live
	else:
		target = _trap_pick(horses, rng)
		if target == live:
			target = (live + 1) % horses.size()
	# 신뢰도 단서: 안목(지력)이 진실을 드러내는 정도. 안목<40이면 edge=0 → 순수 노이즈라
	# 진짜/가짜 구분 불가(속는다). 안목이 높을수록 신뢰도가 진실과 정렬 = 정보 비대칭이 스킬.
	var edge: float = clampf((info_level - 40.0) / 55.0, 0.0, 1.0)
	var truth: float = 1.0 if is_true else 0.0
	var cred: float = clampf(0.5 + (truth - 0.5) * edge + rng.randf_range(-0.30, 0.30), 0.0, 1.0)
	var nm: String = display_name(horses[target])
	var claims_true: Array = [
		LocaleManager.ui("%s, 새벽 조교에서 시계가 미쳤다더라. 오늘 터진다.", "%s clocked absurdly fast at dawn training. This is the one."),
		LocaleManager.ui("%s 마방에 돈 좀 만지는 사람들이 붙었어. 조용히 사 둬.", "People with real money are circling %s. Buy quietly."),
		LocaleManager.ui("%s 컨디션 정점이래. 배당 좋을 때 잡아.", "%s is peaking today. Grab the odds while they last."),
	]
	var claims_fake: Array = [
		LocaleManager.ui("%s 무조건이야. 내 말 믿어, 전 재산 걸어도 돼.", "%s is a lock. Trust me, you could put everything on it."),
		LocaleManager.ui("%s에 큰손이 들어왔대. 따라가면 대박.", "A big player is moving on %s. Follow it and cash big."),
		LocaleManager.ui("%s 오늘 작정했다더라. 한 방에 인생 역전.", "%s is going all out today. One hit could change your life."),
	]
	var pool: Array = claims_true if is_true else claims_fake
	var claim: String = (pool[rng.randi() % pool.size()] as String) % nm
	var price: int = 3000
	return {"target": target, "is_true": is_true, "cred": cred, "price": price,
		"claim": claim, "name": nm}

static func _most_underpriced(horses: Array) -> int:
	var s: float = 0.0
	for h in horses: s += float(h["effective"])
	var best: float = -1.0; var bi: int = 0
	for i in range(horses.size()):
		var ratio: float = (float(horses[i]["effective"]) / s) * float(horses[i]["odds"])
		if ratio > best: best = ratio; bi = i
	return bi

static func _trap_pick(horses: Array, rng: RandomNumberGenerator) -> int:
	# 인기는 있으나 실제 가치 낮은(고평가) 말 = 그럴듯한 함정
	var s: float = 0.0
	for h in horses: s += float(h["effective"])
	var worst: float = 9e9; var wi: int = 0
	for i in range(horses.size()):
		var ratio: float = (float(horses[i]["effective"]) / s) * float(horses[i]["odds"])
		# 너무 인기 없는 말은 함정으로 안 그럴듯 → 배당 12 이하만 후보
		if float(horses[i]["odds"]) <= 12.0 and ratio < worst:
			worst = ratio; wi = i
	return wi
