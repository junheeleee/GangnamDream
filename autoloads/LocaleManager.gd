extends Node
## 언어 설정 관리자 — ko(한국어) / en(영어)
## 언어 변경 시 DataRegistry.reload() 트리거

var language: String = "ko"

signal language_changed(lang: String)

func _ready() -> void:
	var saved = SaveManager.get_setting("language", "ko") if Engine.has_singleton("SaveManager") else "ko"
	language = str(saved) if str(saved) in ["ko", "en"] else "ko"

func set_language(lang: String) -> void:
	if lang == language:
		return
	language = lang
	SaveManager.set_setting("language", lang)
	language_changed.emit(lang)
	DataRegistry.reload()

func is_english() -> bool:
	return language == "en"

## UI 문자열 간단 조회 — 번역 없으면 ko 반환
func ui(ko_text: String, en_text: String) -> String:
	return en_text if language == "en" else ko_text
