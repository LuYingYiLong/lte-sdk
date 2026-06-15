extends SceneTree
## Smoke test: verify LTE-SDK project structure is valid.
## Run: Godot --headless --path D:\GodotProjects\LTE-SDK --script res://tests/sdk_smoke_test.gd


func _init() -> void:
	print("=== LTE-SDK Smoke Test ===")
	var ok: bool = true
	ok = test_project_config() and ok
	ok = test_lteapi_addon() and ok
	ok = test_template_addon() and ok
	ok = test_manifest() and ok
	if ok:
		print("=== All smoke tests passed ===")
	else:
		printerr("=== Some smoke tests FAILED ===")
	quit(0 if ok else 1)


func test_project_config() -> bool:
	var cfg: ConfigFile = ConfigFile.new()
	var err: Error = cfg.load("res://project.godot")
	if err != OK:
		printerr("FAIL: Failed to load project.godot")
		return false
	var name: String = cfg.get_value("application", "config/name", "")
	if "LTE-SDK" in name:
		print("  [PASS] project.godot loads with correct name")
		return true
	printerr("FAIL: project.godot name mismatch: %s" % name)
	return false


func test_lteapi_addon() -> bool:
	if not FileAccess.file_exists("res://addons/lteapi/plugin.cfg"):
		printerr("FAIL: lteapi plugin.cfg missing")
		return false
	if not FileAccess.file_exists("res://addons/lteapi/bin/lteapi.gdextension"):
		printerr("FAIL: lteapi .gdextension missing")
		return false
	var dll_found: bool = false
	var dir: DirAccess = DirAccess.open("res://addons/lteapi/bin")
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".dll"):
				dll_found = true
				break
			file_name = dir.get_next()
		dir.list_dir_end()
	if not dll_found:
		printerr("FAIL: No .dll in addons/lteapi/bin")
		return false
	print("  [PASS] addons/lteapi structure valid")
	return true


func test_template_addon() -> bool:
	if not FileAccess.file_exists("res://addons/lte_plugin_template/plugin.cfg"):
		printerr("FAIL: Template plugin.cfg missing")
		return false
	if not FileAccess.file_exists("res://addons/lte_plugin_template/plugin.gd"):
		printerr("FAIL: Template plugin.gd missing")
		return false
	if not FileAccess.file_exists("res://addons/lte_plugin_template/scripts/example_lte_plugin.gd"):
		printerr("FAIL: Template example_lte_plugin.gd missing")
		return false
	print("  [PASS] lte_plugin_template structure valid")
	return true


func test_manifest() -> bool:
	if not FileAccess.file_exists("res://sdk_manifest.json"):
		printerr("FAIL: sdk_manifest.json missing")
		return false
	var file: FileAccess = FileAccess.open("res://sdk_manifest.json", FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	var err: Error = json.parse(content)
	if err != OK:
		printerr("FAIL: sdk_manifest.json parse error: %s" % json.get_error_message())
		return false
	var data: Variant = json.get_data()
	if not (data is Dictionary):
		printerr("FAIL: sdk_manifest.json is not a dictionary")
		return false
	print("  [PASS] sdk_manifest.json valid")
	return true
