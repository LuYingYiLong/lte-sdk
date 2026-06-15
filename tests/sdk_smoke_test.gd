extends Object
## Smoke test: verify LTE-SDK project structure is valid.
## Run: Godot --headless --path D:\GodotProjects\LTE-SDK --script res://tests/sdk_smoke_test.gd


func _init() -> void:
	print("=== LTE-SDK Smoke Test ===")
	test_project_config()
	test_lteapi_addon()
	test_template_addon()
	test_manifest()
	print("=== All smoke tests passed ===")
	_quit()


func test_project_config() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var err: Error = cfg.load("res://project.godot")
	assert(err == OK, "Failed to load project.godot")
	var name: String = cfg.get_value("application", "config/name", "")
	assert("LTE-SDK" in name, "Project name mismatch: %s" % name)
	print("  [PASS] project.godot loads with correct name")


func test_lteapi_addon() -> void:
	assert(FileAccess.file_exists("res://addons/lteapi/plugin.cfg"),
		"lteapi plugin.cfg missing")
	assert(FileAccess.file_exists("res://addons/lteapi/bin/lteapi.gdextension"),
		"lteapi .gdextension missing")
	var dll_exists: bool = false
	var dir: DirAccess = DirAccess.open("res://addons/lteapi/bin")
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".dll"):
				dll_exists = true
				break
			file_name = dir.get_next()
		dir.list_dir_end()
	assert(dll_exists, "No .dll found in addons/lteapi/bin")
	print("  [PASS] addons/lteapi structure valid")


func test_template_addon() -> void:
	assert(FileAccess.file_exists("res://addons/lte_plugin_template/plugin.cfg"),
		"Template plugin.cfg missing")
	assert(FileAccess.file_exists("res://addons/lte_plugin_template/plugin.gd"),
		"Template plugin.gd missing")
	assert(FileAccess.file_exists("res://addons/lte_plugin_template/scripts/example_lte_plugin.gd"),
		"Template example_lte_plugin.gd missing")

	var cfg: ConfigFile = ConfigFile.new()
	var err: Error = cfg.load("res://addons/lte_plugin_template/plugin.cfg")
	assert(err == OK, "Failed to load template plugin.cfg")
	var script_path: String = cfg.get_value("plugin", "script", "")
	assert(script_path == "plugin.gd", "Template script path mismatch: %s" % script_path)
	print("  [PASS] lte_plugin_template structure valid")


func test_manifest() -> void:
	assert(FileAccess.file_exists("res://sdk_manifest.json"), "sdk_manifest.json missing")
	var file: FileAccess = FileAccess.open("res://sdk_manifest.json", FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	var err: Error = json.parse(content)
	assert(err == OK, "Failed to parse sdk_manifest.json: %s" % json.get_error_message())
	var data: Variant = json.get_data()
	assert(data is Dictionary, "sdk_manifest.json is not a dictionary")
	assert("sdk_id" in data, "sdk_manifest.json missing sdk_id")
	print("  [PASS] sdk_manifest.json valid")


func _quit() -> void:
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	if scene_tree:
		scene_tree.quit(0)
