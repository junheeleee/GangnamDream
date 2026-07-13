extends Node
## StoreScreenshotExport — ScreenshotQA 산출물에서 Steam 스토어 후보 8장을 16:9로 추출.
## 실행 전 `tools/ScreenshotQA.tscn`으로 `/tmp/gangnamdream_qa` 캡처를 먼저 만든다.

const SRC_DIR := "/tmp/gangnamdream_qa"
const OUT_DIR := "/tmp/gangnamdream_store_screenshots"
const TARGET_SIZE := Vector2i(1280, 720)

const STORE_SET := [
	{
		"src": "store_en_01_cold_open.png",
		"dst": "01_cold_open.png",
		"ko": "2031년 새벽. 누가 이곳에 도착했는지는 아직 모른다.",
		"en": "Dawn, 2031. You do not yet know who survived the climb."
	},
	{
		"src": "store_en_02_money_mule_timer.png",
		"dst": "02_money_mule_timer.png",
		"ko": "12초. 200만원. 한 번 넘으면 돌아오기 어려운 선.",
		"en": "Twelve seconds. Two million won. One line that is hard to uncross."
	},
	{
		"src": "store_en_03_montage_card.png",
		"dst": "03_montage_card.png",
		"ko": "조용한 주는 접혀 지나가지만, 그 대가는 남는다.",
		"en": "Quiet weeks fold forward. Their cost remains."
	},
	{
		"src": "store_en_04_time_ledger.png",
		"dst": "04_time_ledger.png",
		"ko": "돈, 건강, 인연, 간직한 것. 게임은 5년을 기록한다.",
		"en": "Money, health, relationships, keepsakes. The game records all five years."
	},
	{
		"src": "store_en_05_moral_bright.png",
		"dst": "05_moral_bright.png",
		"ko": "같은 장면, 아직 사람을 먼저 보는 시선.",
		"en": "The same scene, while he can still see the person first."
	},
	{
		"src": "store_en_06_moral_dark.png",
		"dst": "06_moral_dark.png",
		"ko": "같은 장면, 이제 숫자를 먼저 세는 시선.",
		"en": "The same scene, after the numbers have learned to come first."
	},
	{
		"src": "store_en_07_season_date_cg.png",
		"dst": "07_season_date_cg.png",
		"ko": "사랑은 계절을 따라 자라고, 선택에 따라 사라질 수도 있다.",
		"en": "Love grows across seasons, and your choices can still cost it."
	},
	{
		"src": "store_en_08_ending_recap.png",
		"dst": "08_ending_recap.png",
		"ko": "5년, 다섯 장면. 무엇을 기억할지도 플레이어가 고른다.",
		"en": "Five years, five scenes. You choose what the ending remembers."
	},
]

var _failures: Array[String] = []
var _manifest: Array[Dictionary] = []

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_clear_output_dir()
	for entry in STORE_SET:
		_export_one(entry)
	_write_manifest()
	if not _failures.is_empty():
		for failure in _failures:
			push_error(failure)
		get_tree().quit(1)
		return
	print("STORE_SCREENSHOT_EXPORT_OK dir=%s count=%d" % [OUT_DIR, _manifest.size()])
	get_tree().quit(0)

func _clear_output_dir() -> void:
	var dir := DirAccess.open(OUT_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".md") or file_name.ends_with(".json")):
			dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func _export_one(entry: Dictionary) -> void:
	var src_name := str(entry.get("src", ""))
	var dst_name := str(entry.get("dst", ""))
	var src_path := "%s/%s" % [SRC_DIR, src_name]
	var dst_path := "%s/%s" % [OUT_DIR, dst_name]
	if not FileAccess.file_exists(src_path):
		_failures.append("missing source screenshot: %s" % src_path)
		return
	var img := Image.load_from_file(src_path)
	if img == null or img.is_empty():
		_failures.append("cannot load screenshot: %s" % src_path)
		return
	var cropped := _crop_to_16x9(img, str(entry.get("anchor", "center")))
	var err := cropped.save_png(dst_path)
	if err != OK:
		_failures.append("cannot save store screenshot: %s" % dst_path)
		return
	_manifest.append({
		"file": dst_name,
		"source": src_name,
		"caption_ko": str(entry.get("ko", "")),
		"caption_en": str(entry.get("en", "")),
		"size": "%dx%d" % [TARGET_SIZE.x, TARGET_SIZE.y],
	})
	print("STORE_SHOT %s" % dst_path)

func _crop_to_16x9(img: Image, anchor: String = "center") -> Image:
	var src_size := img.get_size()
	var target_ratio := float(TARGET_SIZE.x) / float(TARGET_SIZE.y)
	var crop_w := src_size.x
	var crop_h := int(round(float(crop_w) / target_ratio))
	if crop_h > src_size.y:
		crop_h = src_size.y
		crop_w = int(round(float(crop_h) * target_ratio))
	var x := maxi(0, (src_size.x - crop_w) / 2)
	var y := maxi(0, (src_size.y - crop_h) / 2)
	match anchor:
		"top":
			y = 0
		"bottom":
			y = maxi(0, src_size.y - crop_h)
	var cropped := img.get_region(Rect2i(x, y, crop_w, crop_h))
	if cropped.get_size() != TARGET_SIZE:
		cropped.resize(TARGET_SIZE.x, TARGET_SIZE.y, Image.INTERPOLATE_LANCZOS)
	return cropped

func _write_manifest() -> void:
	var json_path := "%s/manifest.json" % OUT_DIR
	var json_file := FileAccess.open(json_path, FileAccess.WRITE)
	if json_file:
		json_file.store_string(JSON.stringify(_manifest, "\t"))

	var md_lines: Array[String] = [
		"# Gangnam Dream Store Screenshot Candidates",
		"",
		"Generated from `/tmp/gangnamdream_qa` by `tools/StoreScreenshotExport.tscn`.",
		"",
		"| # | File | Source | Caption |",
		"|---|---|---|---|",
	]
	for i in range(_manifest.size()):
		var item := _manifest[i]
		md_lines.append("| %d | `%s` | `%s` | %s<br>%s |" % [
			i + 1,
			str(item.get("file", "")),
			str(item.get("source", "")),
			str(item.get("caption_ko", "")),
			str(item.get("caption_en", "")),
		])
	var md_path := "%s/manifest.md" % OUT_DIR
	var md_file := FileAccess.open(md_path, FileAccess.WRITE)
	if md_file:
		md_file.store_string("\n".join(md_lines) + "\n")
