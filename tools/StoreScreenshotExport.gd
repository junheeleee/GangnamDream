extends Node
## StoreScreenshotExport — ScreenshotQA 산출물에서 Steam 스토어 후보 8장을 16:9로 추출.
## 실행 전 `tools/ScreenshotQA.tscn`으로 `/tmp/gangnamdream_qa` 캡처를 먼저 만든다.

const SRC_DIR := "/tmp/gangnamdream_qa"
const OUT_DIR := "/tmp/gangnamdream_store_screenshots"
const TARGET_SIZE := Vector2i(1280, 720)

const STORE_SET := [
	{
		"src": "00a_story_interview.png",
		"dst": "01_story_hook.png",
		"ko": "5년, 50만원, 30억. 첫 장면부터 목표가 분명해야 한다.",
		"en": "Five years, ₩500,000, ₩3 billion. The stakes are immediate."
	},
	{
		"src": "01_event_gambling_wave.png",
		"dst": "02_event_choice.png",
		"ko": "선택은 짧고, 결과는 오래 따라온다.",
		"en": "Choices are brief. Consequences linger."
	},
	{
		"src": "04_ap_actions_dashboard.png",
		"dst": "03_life_dashboard.png",
		"ko": "매주 무엇을 할지 고르고, 5년을 설계한다.",
		"en": "Plan each week. Survive five years.",
		"anchor": "top"
	},
	{
		"src": "02_investment_portfolio_chart.png",
		"dst": "04_investment_portfolio.png",
		"ko": "월급만으로는 부족하다. 시장도 또 하나의 전장이다.",
		"en": "A salary is not enough. The market is another battlefield.",
		"anchor": "top"
	},
	{
		"src": "05_people_relationships.png",
		"dst": "05_relationship_arcs.png",
		"ko": "돈만이 결말을 정하지 않는다. 사람도 기억된다.",
		"en": "Money is not the only ending. People are remembered too.",
		"anchor": "top"
	},
	{
		"src": "06a_holdem_showdown.png",
		"dst": "06_holdem_showdown.png",
		"ko": "홀덤, 경마, 카지노. 한 번의 베팅이 런을 뒤집는다.",
		"en": "Holdem, racing, casino. One bet can overturn a run.",
		"anchor": "top"
	},
	{
		"src": "13_ending_gangnam_win.png",
		"dst": "07_ending_gangnam.png",
		"ko": "5년의 끝. 강남드림을 이뤘다.",
		"en": "The end of five years. Gangnam Dream achieved."
	},
	{
		"src": "14_ending_bankruptcy.png",
		"dst": "08_ending_bankruptcy.png",
		"ko": "파산도 엔딩이다. 그래서 다시 시작한다.",
		"en": "Bankruptcy is an ending too. That is why you start over."
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
