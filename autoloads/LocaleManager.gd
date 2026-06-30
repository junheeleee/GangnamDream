extends Node
## 언어 설정 관리자 — ko(한국어) / en(영어)
## 언어 변경 시 DataRegistry.reload() 트리거

var language: String = "en"

# 주인공 기본 이름 — 언어 전환 시 다른 언어 기본값으로 동기화 (커스텀 이름은 보존)
const DEFAULT_NAME_KO := "김민준"
const DEFAULT_NAME_EN := "Kim Minjun"

signal language_changed(lang: String)

func _ready() -> void:
	# SaveManager는 오토로드 순서상 뒤에 로드 — 첫 프레임 후 안전하게 읽는다.
	call_deferred("_load_saved_language")

func _load_saved_language() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm == null:
		return
	var saved = sm.get_setting("language", "en")
	var lang := str(saved) if str(saved) in ["ko", "en"] else "en"
	if lang != language:
		language = lang
		_sync_player_name(lang)
		language_changed.emit(lang)
		DataRegistry.reload()

func set_language(lang: String) -> void:
	if lang == language:
		return
	language = lang
	SaveManager.set_setting("language", lang)
	_sync_player_name(lang)
	language_changed.emit(lang)
	DataRegistry.reload()

## 주인공 이름이 기본값이면 새 언어 기본값으로 교체 (유저가 직접 지은 이름은 건드리지 않음)
func _sync_player_name(lang: String) -> void:
	var gs = get_node_or_null("/root/GameState")
	if gs == null:
		return
	var cur := str(gs.player_name)
	if cur == DEFAULT_NAME_KO or cur == DEFAULT_NAME_EN:
		gs.player_name = DEFAULT_NAME_EN if lang == "en" else DEFAULT_NAME_KO

func is_english() -> bool:
	return language == "en"

## UI 문자열 간단 조회 — 번역 없으면 ko 반환
func ui(ko_text: String, en_text: String) -> String:
	return en_text if language == "en" else ko_text
