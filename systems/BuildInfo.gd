extends RefCounted
## Player-visible build identity. Update these two values together for each
## testable build so screenshots and bug reports identify the exact revision.

const GAME_VERSION := "0.1.0-dev"
const BUILD_ID := "2026.07.27.1"
const CORE_LOOP_V2_CHANNEL := "CORE LOOP V2"


static func identity_label(core_loop_v2: bool = false) -> String:
	var label := "v%s  ·  BUILD %s" % [GAME_VERSION, BUILD_ID]
	if core_loop_v2:
		label += "  ·  %s" % CORE_LOOP_V2_CHANNEL
	return label


static func window_title(core_loop_v2: bool = false, english: bool = false) -> String:
	var product_name := "Gangnam Dream" if english else "강남드림"
	var title := "%s  %s" % [product_name, identity_label(core_loop_v2)]
	if OS.is_debug_build():
		title += "  (DEBUG)"
	return title


static func apply_window_title(window: Window, core_loop_v2: bool = false,
		english: bool = false) -> void:
	if is_instance_valid(window):
		window.title = window_title(core_loop_v2, english)
