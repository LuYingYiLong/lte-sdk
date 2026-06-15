extends SceneTree
## LTE-SDK plugin initialization CLI.
##
## Usage:
##   Godot --headless --path <sdk_dir> --script res://tools/init_plugin.gd -- \
##     --plugin-id my_plugin --plugin-name "My Plugin" --author "Me"
##
## Run with --help for full usage.

const RESERVED_IDS: PackedStringArray = ["lteapi", "addons", "template", "lte_sdk", "godot", "engine", "editor", "main", "root", "scene"]
const PLACEHOLDERS: Array[String] = ["{{plugin_id}}", "{{plugin_name}}", "{{author}}", "{{description}}", "{{lteapi_version}}", "{{created_date}}"]
const TEXT_EXTENSIONS: PackedStringArray = ["gd", "cfg", "godot", "json", "md", "txt"]

var _args: Dictionary = {}
var _force: bool = false
var _keep_template: bool = false
var _plugin_id: String = ""
var _plugin_name: String = ""
var _author: String = ""
var _description: String = ""


func _initialize() -> void:
	_parse_args()
	if _args.has("help"):
		_print_help()
		_quit(0)
		return

	if not _validate():
		_quit(1)
		return

	_print_banner()
	if not _init_plugin():
		_quit(1)
		return

	_print_success()
	_quit(0)


func _parse_args() -> void:
	var raw_args: PackedStringArray = OS.get_cmdline_user_args()
	var i: int = 0
	while i < raw_args.size():
		var arg: String = raw_args[i]
		match arg:
			"--plugin-id":
				i += 1
				if i < raw_args.size():
					_args["plugin_id"] = raw_args[i]
			"--plugin-name":
				i += 1
				if i < raw_args.size():
					_args["plugin_name"] = raw_args[i]
			"--author":
				i += 1
				if i < raw_args.size():
					_args["author"] = raw_args[i]
			"--description":
				i += 1
				if i < raw_args.size():
					_args["description"] = raw_args[i]
			"--force":
				_args["force"] = true
			"--keep-template":
				_args["keep_template"] = true
			"--help":
				_args["help"] = true
			_:
				printerr("Unknown argument: ", arg)
		i += 1


func _print_help() -> void:
	print("""LTE-SDK Plugin Initialization CLI

Usage:
  Godot --headless --path <sdk_dir> --script res://tools/init_plugin.gd -- \\
    --plugin-id <id> --plugin-name <name> --author <author> [options]

Required arguments:
  --plugin-id     Unique plugin ID (lowercase letters, digits, underscores;
                  must not start with a digit; must not be a reserved name).
  --plugin-name   Plugin display name (quoted if it contains spaces).
  --author        Author name.

Optional arguments:
  --description   Short plugin description (default: empty).
  --force         Overwrite an existing target plugin directory.
  --keep-template  Keep addons/lte_plugin_template after initialization.
  --help          Show this help and exit.

Examples:
  Godot --headless --path . --script res://tools/init_plugin.gd -- \\
    --plugin-id my_plugin --plugin-name "My Plugin" --author "YourName"

  Godot --headless --path . --script res://tools/init_plugin.gd -- \\
    --plugin-id my_plugin --plugin-name "My Plugin" --author "Me" \\
    --description "Does cool things" --force
""")


func _validate() -> bool:
	_plugin_id = _args.get("plugin_id", "")
	_plugin_name = _args.get("plugin_name", "")
	_author = _args.get("author", "")
	_description = _args.get("description", "")
	_force = _args.get("force", false)
	_keep_template = _args.get("keep_template", false)

	if _plugin_id == "":
		printerr("ERROR: --plugin-id is required.")
		return false

	if _plugin_name == "":
		printerr("ERROR: --plugin-name is required.")
		return false

	if _author == "":
		printerr("ERROR: --author is required.")
		return false

	# Validate plugin_id format: lowercase letters, digits, underscores only
	var regex: RegEx = RegEx.new()
	regex.compile("^[a-z][a-z0-9_]*$")
	var result: RegExMatch = regex.search(_plugin_id)
	if result == null:
		printerr("ERROR: --plugin-id must be lowercase letters, digits, underscores, and must not start with a digit.")
		return false

	# Check reserved names
	for reserved: String in RESERVED_IDS:
		if _plugin_id == reserved:
			printerr("ERROR: --plugin-id '%s' is reserved." % _plugin_id)
			return false

	# Check template directory exists
	if not DirAccess.dir_exists_absolute("res://addons/lte_plugin_template"):
		printerr("ERROR: Template directory 'addons/lte_plugin_template' not found.")
		return false

	# Check target directory
	var target_path: String = "res://addons/" + _plugin_id
	if DirAccess.dir_exists_absolute(target_path) and not _force:
		printerr("ERROR: Target directory '%s' already exists. Use --force to overwrite." % target_path)
		return false

	return true


func _init_plugin() -> bool:
	var template_path: String = "res://addons/lte_plugin_template"
	var target_path: String = "res://addons/" + _plugin_id

	print("Initializing plugin '%s'..." % _plugin_id)

	# If forcing and target already exists, clean it first to avoid stale residue
	if _force and DirAccess.dir_exists_absolute(target_path):
		print("Removing existing target directory (--force)...")
		_remove_directory(target_path)

	# Copy template directory
	var err: Error = _copy_directory(template_path, target_path)
	if err != OK:
		printerr("ERROR: Failed to copy template directory. Error: ", err)
		return false

	# Replace placeholders in all text files
	var file_list: Array[String] = []
	_collect_files(target_path, file_list)
	for file_path: String in file_list:
		_replace_placeholders(file_path)

	# Update project.godot with new plugin
	_update_project_config()

	# Remove template if not keeping it
	if not _keep_template:
		print("Removing template directory...")
		_remove_directory(template_path)

	print("Plugin '%s' initialized successfully." % _plugin_id)
	return true


func _copy_directory(source: String, dest: String) -> Error:
	var dir: DirAccess = DirAccess.open(source)
	if dir == null:
		return ERR_CANT_OPEN

	# Create target directory
	var make_err: Error = DirAccess.make_dir_recursive_absolute(dest)
	if make_err != OK and make_err != ERR_ALREADY_EXISTS:
		return make_err

	# Copy files and subdirectories
	dir.list_dir_begin()
	var item_name: String = dir.get_next()
	while item_name != "":
		if item_name == "." or item_name == "..":
			item_name = dir.get_next()
			continue

		var source_item: String = source.path_join(item_name)
		var dest_item: String = dest.path_join(item_name)

		if dir.current_is_dir():
			var sub_err: Error = _copy_directory(source_item, dest_item)
			if sub_err != OK:
				dir.list_dir_end()
				return sub_err
		else:
			# Skip .uid files — Godot regenerates them
			if item_name.ends_with(".uid"):
				item_name = dir.get_next()
				continue

			var copy_err: Error = DirAccess.copy_absolute(source_item, dest_item)
			if copy_err != OK:
				dir.list_dir_end()
				printerr("ERROR: Failed to copy '%s' -> '%s'" % [source_item, dest_item])
				return copy_err

		item_name = dir.get_next()
	dir.list_dir_end()
	return OK


func _remove_directory(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()
	var item_name: String = dir.get_next()
	while item_name != "":
		if item_name == "." or item_name == "..":
			item_name = dir.get_next()
			continue

		var item_path: String = path.path_join(item_name)
		if dir.current_is_dir():
			_remove_directory(item_path)
		else:
			DirAccess.remove_absolute(item_path)
		item_name = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(path)


func _collect_files(base_path: String, out_files: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(base_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var item_name: String = dir.get_next()
	while item_name != "":
		if item_name == "." or item_name == "..":
			item_name = dir.get_next()
			continue

		var item_path: String = base_path.path_join(item_name)
		if dir.current_is_dir():
			_collect_files(item_path, out_files)
		else:
			var ext: String = item_name.get_extension().to_lower()
			if ext in TEXT_EXTENSIONS:
				out_files.append(item_path)
		item_name = dir.get_next()
	dir.list_dir_end()


func _replace_placeholders(file_path: String) -> void:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("WARNING: Cannot read '%s' for placeholder replacement." % file_path)
		return

	var content: String = file.get_as_text()
	file.close()

	var original: String = content
	var now: Dictionary = Time.get_datetime_dict_from_system()
	var date_str: String = "%04d-%02d-%02d" % [now.year, now.month, now.day]
	var lteapi_version: String = _read_lteapi_version()

	content = content.replace("{{plugin_id}}", _plugin_id)
	content = content.replace("{{plugin_name}}", _plugin_name)
	content = content.replace("{{author}}", _author)
	content = content.replace("{{description}}", _description)
	content = content.replace("{{lteapi_version}}", lteapi_version)
	content = content.replace("{{created_date}}", date_str)

	# Check for leftover placeholders
	for ph: String in PLACEHOLDERS:
		if ph in content:
			printerr("WARNING: Placeholder '%s' still present in '%s'." % [ph, file_path])

	if content != original:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file == null:
			printerr("WARNING: Cannot write to '%s'." % file_path)
			return
		file.store_string(content)
		file.close()


func _read_lteapi_version() -> String:
	if not FileAccess.file_exists("res://addons/lteapi/plugin.cfg"):
		return "0.1.0"

	var cfg: ConfigFile = ConfigFile.new()
	var err: Error = cfg.load("res://addons/lteapi/plugin.cfg")
	if err != OK:
		return "0.1.0"

	var version: String = cfg.get_value("plugin", "version", "0.1.0")
	return version


func _update_project_config() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var err: Error = cfg.load("res://project.godot")
	if err != OK:
		printerr("WARNING: Cannot read project.godot to update config.")
		return

	# Update project name
	cfg.set_value("application", "config/name", _plugin_name)

	# Add new plugin to enabled plugins
	var enabled: PackedStringArray = PackedStringArray()
	var existing: Array = cfg.get_value("editor_plugins", "enabled", [])
	if existing is Array:
		for item: Variant in existing:
			if item is String and not (item as String).contains("lte_plugin_template"):
				enabled.append(item as String)

	var new_plugin_cfg: String = "res://addons/" + _plugin_id + "/plugin.cfg"
	if new_plugin_cfg not in enabled:
		enabled.append(new_plugin_cfg)

	cfg.set_value("editor_plugins", "enabled", enabled)

	# Save back
	err = cfg.save("res://project.godot")
	if err != OK:
		printerr("WARNING: Failed to save project.godot.")
		return

	print("Updated project.godot: name='%s', enabled plugin='%s'" % [_plugin_name, new_plugin_cfg])


func _print_banner() -> void:
	print("=== LTE-SDK Plugin Initialization ===")
	print("  Plugin ID:   ", _plugin_id)
	print("  Plugin Name: ", _plugin_name)
	print("  Author:      ", _author)
	if _description != "":
		print("  Description: ", _description)
	print("")


func _print_success() -> void:
	print("")
	print("=== Plugin initialized successfully ===")
	print("")
	print("Next steps:")
	print("  1. Open the project in Godot Editor:")
	print("     Godot --path .")
	print("  2. Your plugin is at: addons/", _plugin_id)
	print("  3. Edit plugin.gd to add your editor logic.")
	print("  4. Edit plugin.cfg to update metadata.")
	print("")
	if _keep_template:
		print("  NOTE: Template directory was kept at addons/lte_plugin_template")
		print("        Remove it manually when no longer needed.")
	print("")


func _quit(exit_code: int) -> void:
	quit(exit_code)
