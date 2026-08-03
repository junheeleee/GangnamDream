extends RefCounted
## Build flavor and persistence namespace contract.
##
## The exported feature is authoritative. The user argument exists only so
## editor/CI checks can exercise the same path before an export is produced.

const PLAYTEST_FEATURE := "core_loop_v2_playtest"
const PLAYTEST_TEST_ARG := "--core-loop-v2-playtest-build"
const PLAYTEST_FLAVOR_ID := "core_loop_v2_playtest"
const PLAYTEST_SAVE_NAMESPACE := "core_loop_v2_playtest_v1"
const QA_ISOLATED_USER_ARG := "--qa-isolated-user-data"
const QA_ISOLATED_USER_ENV := "GANGNAM_QA_USER_DIR"

const RETAIL_SETTINGS_PATH := "user://gangnam_dream_settings.json"
const RETAIL_DISPLAY_SETTINGS_PATH := "user://gangnam_dream_display.json"
const RETAIL_META_PATH := "user://gangnam_dream_meta.json"

const _PLAYTEST_SETTINGS_PATH := \
	"user://gangnam_dream_v2_playtest_v1_settings.json"
const _PLAYTEST_DISPLAY_SETTINGS_PATH := \
	"user://gangnam_dream_v2_playtest_v1_display.json"
const _PLAYTEST_META_PATH := \
	"user://gangnam_dream_v2_playtest_v1_meta.json"

const _DEMO_FEATURE := "gangnam_demo"
const _DEMO_TEST_ARG := "--demo-build"
const _LEGACY_SAVE_NAMESPACE := "legacy"
const _MANUAL_SLOT_COUNT := 10


static func is_core_loop_v2_playtest_build() -> bool:
	return OS.has_feature(PLAYTEST_FEATURE) \
		or OS.get_cmdline_user_args().has(PLAYTEST_TEST_ARG)


static func build_flavor_id() -> String:
	if is_core_loop_v2_playtest_build():
		return PLAYTEST_FLAVOR_ID
	# Preserve the pre-existing payload labels outside the playtest flavor.
	if OS.has_feature(_DEMO_FEATURE) \
			or OS.get_cmdline_user_args().has(_DEMO_TEST_ARG):
		return "demo"
	return "full"


static func save_namespace_id() -> String:
	return PLAYTEST_SAVE_NAMESPACE \
		if is_core_loop_v2_playtest_build() else _LEGACY_SAVE_NAMESPACE


static func settings_path() -> String:
	return _settings_path_for(is_core_loop_v2_playtest_build())


static func display_settings_path() -> String:
	return _display_settings_path_for(is_core_loop_v2_playtest_build())


static func meta_path() -> String:
	return _meta_path_for(is_core_loop_v2_playtest_build())


static func slot_path(slot: int) -> String:
	return _slot_path_for(slot, is_core_loop_v2_playtest_build())


static func user_data_paths_for_playtest(playtest: bool) -> Dictionary:
	var paths := {
		"settings": _settings_path_for(playtest),
		"display_settings": _display_settings_path_for(playtest),
		"meta": _meta_path_for(playtest),
		"autosave": _slot_path_for(0, playtest),
	}
	for slot in range(1, _MANUAL_SLOT_COUNT + 1):
		paths["slot_%d" % slot] = _slot_path_for(slot, playtest)
	return paths


static func qa_isolated_user_root() -> String:
	if not is_core_loop_v2_playtest_build() \
			or not OS.get_cmdline_user_args().has(QA_ISOLATED_USER_ARG):
		return ""
	var root := OS.get_environment(QA_ISOLATED_USER_ENV).strip_edges()
	if root.is_empty() or not root.is_absolute_path():
		return ""
	return root.simplify_path()


static func _qa_playtest_path(playtest: bool, filename: String) -> String:
	if not playtest:
		return ""
	var root := qa_isolated_user_root()
	return root.path_join(filename) if not root.is_empty() else ""


static func _settings_path_for(playtest: bool) -> String:
	var qa_path := _qa_playtest_path(
		playtest, _PLAYTEST_SETTINGS_PATH.trim_prefix("user://"))
	if not qa_path.is_empty():
		return qa_path
	return _PLAYTEST_SETTINGS_PATH if playtest else RETAIL_SETTINGS_PATH


static func _display_settings_path_for(playtest: bool) -> String:
	var qa_path := _qa_playtest_path(
		playtest, _PLAYTEST_DISPLAY_SETTINGS_PATH.trim_prefix("user://"))
	if not qa_path.is_empty():
		return qa_path
	return _PLAYTEST_DISPLAY_SETTINGS_PATH \
		if playtest else RETAIL_DISPLAY_SETTINGS_PATH


static func _meta_path_for(playtest: bool) -> String:
	var qa_path := _qa_playtest_path(
		playtest, _PLAYTEST_META_PATH.trim_prefix("user://"))
	if not qa_path.is_empty():
		return qa_path
	return _PLAYTEST_META_PATH if playtest else RETAIL_META_PATH


static func _slot_path_for(slot: int, playtest: bool) -> String:
	var prefix := "gangnam_dream_v2_playtest_v1" \
		if playtest else "gangnam_dream"
	var filename := "%s_autosave.json" % prefix \
		if slot == 0 else "%s_slot_%d.json" % [prefix, slot]
	var qa_path := _qa_playtest_path(playtest, filename)
	if not qa_path.is_empty():
		return qa_path
	if slot == 0:
		return "user://%s_autosave.json" % prefix
	return "user://%s_slot_%d.json" % [prefix, slot]
