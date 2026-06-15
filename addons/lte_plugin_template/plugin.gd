@tool
extends EditorPlugin

const ExampleLTEPlugin: GDScript = preload("res://addons/{{plugin_id}}/scripts/example_lte_plugin.gd")

var plugin_instance: RefCounted

func _enter_tree() -> void:
	plugin_instance = ExampleLTEPlugin.new()
	plugin_instance.initialize()


func _exit_tree() -> void:
	if plugin_instance != null:
		plugin_instance.shutdown()
	plugin_instance = null
