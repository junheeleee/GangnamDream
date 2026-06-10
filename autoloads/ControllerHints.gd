extends Node
## ControllerHints — 연결된 패드 브랜드를 감지해 올바른 버튼 레이블을 반환한다.
## Xbox A/B/X/Y · PS ✕/○/□/△ · Nintendo B/A/Y/X · Steam Deck(= Xbox 레이블)

enum Brand { GENERIC, XBOX, PLAYSTATION, NINTENDO }

var _brand: Brand = Brand.GENERIC

# [south, east, west, north, r_shoulder, start]
const _LABELS: Dictionary = {
	Brand.XBOX:        ["A",  "B",  "X",  "Y",  "RB", "Menu"],
	Brand.PLAYSTATION: ["✕",  "○",  "□",  "△",  "R1", "Options"],
	Brand.NINTENDO:    ["B",  "A",  "Y",  "X",  "R",  "+"],
	Brand.GENERIC:     ["A",  "B",  "X",  "Y",  "RB", "Menu"],
}

func _ready():
	Input.joy_connection_changed.connect(_on_joy_changed)
	_detect()

func _on_joy_changed(_device: int, _connected: bool):
	_detect()

func _detect():
	_brand = Brand.GENERIC
	for i in Input.get_connected_joypads():
		var n: String = Input.get_joy_name(i).to_lower()
		if "playstation" in n or "dualshock" in n or "dualsense" in n or "sony" in n \
				or "ps3" in n or "ps4" in n or "ps5" in n:
			_brand = Brand.PLAYSTATION
			return
		elif "nintendo" in n or "switch" in n or "pro controller" in n or "joycon" in n:
			_brand = Brand.NINTENDO
			return
		else:
			# Xbox, Steam Deck, XInput, 기타 알 수 없는 패드 → Xbox 레이블
			_brand = Brand.XBOX
			return

func is_pad_active() -> bool:
	return Input.get_connected_joypads().size() > 0

## 확인 버튼 (South): A / ✕ / B
func south()     -> String: return _LABELS[_brand][0]
## 취소 버튼 (East): B / ○ / A
func east()      -> String: return _LABELS[_brand][1]
## 오른쪽 어깨 (RB/R1/R)
func shoulder_r()-> String: return _LABELS[_brand][4]
## 스타트/옵션/+ 버튼
func start_btn() -> String: return _LABELS[_brand][5]

## 현재 브랜드 이름 (UI 디버그용)
func brand_name() -> String:
	match _brand:
		Brand.XBOX:        return "Xbox"
		Brand.PLAYSTATION: return "PlayStation"
		Brand.NINTENDO:    return "Nintendo"
	return "Generic"
