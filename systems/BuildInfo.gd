extends RefCounted
## Player-visible artifact identity. Update BUILD_ID when issuing a new
## testable package. The build manifest owns the exact Git revision; BUILD_ID
## ties that package to its screen and save metadata without becoming a save
## compatibility key.

const BuildFlavorScript := preload("res://systems/BuildFlavor.gd")

const GAME_VERSION := "0.1.0-dev"
const BUILD_ID := "2026.08.11.2"
const DEMO_CHANNEL := "24-WEEK DEMO"
const CORE_LOOP_V2_CHANNEL := "CORE LOOP V2"
const CORE_LOOP_V2_PLAYTEST_CHANNEL := "CORE LOOP V2 · PLAYTEST"


static func artifact_identity() -> Dictionary:
	return {
		"game_version": GAME_VERSION,
		"build_id": BUILD_ID,
		"build_flavor": BuildFlavorScript.build_flavor_id(),
		"save_namespace": BuildFlavorScript.save_namespace_id(),
	}


static func _artifact_channel_label() -> String:
	var flavor := BuildFlavorScript.build_flavor_id()
	if flavor == BuildFlavorScript.PLAYTEST_FLAVOR_ID:
		return CORE_LOOP_V2_PLAYTEST_CHANNEL
	if flavor == "demo":
		return DEMO_CHANNEL
	return ""


static func _run_mode_label(core_loop_v2: bool) -> String:
	# Run mode is deliberately separate from the artifact flavor. A debug/full
	# executable can exercise V2 without pretending to be the V2 package.
	if core_loop_v2 \
			and BuildFlavorScript.build_flavor_id() \
			!= BuildFlavorScript.PLAYTEST_FLAVOR_ID:
		return CORE_LOOP_V2_CHANNEL
	return ""


static func identity_label(core_loop_v2: bool = false) -> String:
	var label := "v%s  ·  BUILD %s" % [GAME_VERSION, BUILD_ID]
	var artifact_channel := _artifact_channel_label()
	if not artifact_channel.is_empty():
		label += "  ·  %s" % artifact_channel
	var run_mode := _run_mode_label(core_loop_v2)
	if not run_mode.is_empty():
		label += "  ·  RUN: %s" % run_mode
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
