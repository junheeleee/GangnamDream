extends Node
## RaceTrack 런타임 스모크 — 베팅종류·정보상·기록까지 실제 호출해 런타임 에러 검출.
func _ready() -> void:
	GameState.money = 2000000
	GameState.intelligence = 72
	if not (GameState.flags is Dictionary): GameState.flags = {}
	var rt = load("res://scenes/RaceTrack.gd").new()
	add_child(rt)
	rt.open()
	print("SMOKE open/betting OK")
	rt._consult_dealer()
	print("SMOKE dealer OK tip=", str(rt._tip.get("name","?")), " cred=", rt._tip.get("cred",0))
	rt._toggle_pick(0)
	rt._place_bet(10000)
	print("SMOKE 단승 bet+start OK finish=", rt._finish.size())
	rt._finish_race()
	print("SMOKE 단승 result payout=", rt._payout_amt)
	# 삼쌍승 경로
	rt._new_race()
	rt._set_bet_type(3)
	rt._toggle_pick(2); rt._toggle_pick(0); rt._toggle_pick(1)
	rt._place_bet(10000)
	rt._finish_race()
	print("SMOKE 삼쌍승 OK payout=", rt._payout_amt)
	# 연승·복승도 빠르게
	rt._new_race(); rt._set_bet_type(0); rt._toggle_pick(1); rt._place_bet(10000); rt._finish_race()
	rt._new_race(); rt._set_bet_type(2); rt._toggle_pick(0); rt._toggle_pick(3); rt._place_bet(10000); rt._finish_race()
	print("SMOKE 연승·복승 OK")
	# 전적 누적 확인
	var roster = GameState.flags["horse_world"]["roster"]
	var starts = 0
	for r in roster: starts += int(r["starts"])
	print("SMOKE 전적누적 총출주=", starts, " (>0이어야)")
	print("SMOKE_ALL_OK")
	get_tree().quit(0)
