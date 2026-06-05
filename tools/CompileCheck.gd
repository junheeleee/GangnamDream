extends Node
## 프로젝트 전체 .gd 강제 컴파일 체크. 씬으로 부팅되므로 오토로드 글로벌·
## class_name 캐시가 모두 정상 등록된 상태에서 load()가 함수 본문까지 완전
## 컴파일한다 → 정규식이 못 잡는 '없는 식별자/없는 함수' 의미 에러까지 stderr에 찍힘.
## 깨진 스크립트는 'Failed to load script ... Parse error'를 stderr에 출력 →
## audit.sh가 그 출력을 보고 판정한다(load 반환값은 캐시 탓에 신뢰 불가).
func _ready() -> void:
	var total: Array = [0]
	_scan("res://", total)
	print("COMPILE_SCAN total=%d (verdict from stderr)" % total[0])
	get_tree().quit(0)

func _scan(dir: String, total: Array) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	d.list_dir_begin()
	var f := d.get_next()
	while f != "":
		var p := dir.path_join(f)
		if d.current_is_dir():
			if not f.begins_with(".") and f != "addons":
				_scan(p, total)
		elif f.ends_with(".gd") and not p.contains("/tools/"):
			total[0] += 1
			load(p)   # 컴파일 강제 (실패 시 stderr에 에러 출력)
		f = d.get_next()
	d.list_dir_end()
