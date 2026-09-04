extends SceneTree
## Test-only entrypoint: select fresh storage BEFORE game autoloads initialize.

func _init() -> void:
	var qa_namespace := OS.get_environment("STORY_NAMEPLATE_QA_NAMESPACE")
	var qa_namespace_pattern := RegEx.new()
	if qa_namespace_pattern.compile("^GangnamDream_StoryNameplateQA_[0-9a-f]{32}$") != OK \
			or qa_namespace_pattern.search(qa_namespace) == null:
		push_error("STORY_NAMEPLATE_CHECK_FAIL bootstrap namespace refused")
		quit(1)
		return
	ProjectSettings.set_setting("application/config/use_custom_user_dir", true)
	ProjectSettings.set_setting("application/config/custom_user_dir_name", qa_namespace)
	var qa_path := OS.get_user_data_dir()
	if qa_path.get_file() != qa_namespace \
			or DirAccess.dir_exists_absolute(qa_path) \
			or DirAccess.make_dir_recursive_absolute(qa_path) != OK:
		push_error("STORY_NAMEPLATE_CHECK_FAIL bootstrap isolation refused")
		quit(1)
		return
	print("STORY_NAMEPLATE_PRE_AUTOLOAD_USER_DIR=%s" % qa_path)
