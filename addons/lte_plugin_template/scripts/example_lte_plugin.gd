extends RefCounted

func initialize() -> void:
	if not Engine.has_singleton("LTEAPI"):
		push_warning("{{plugin_name}}: LTEAPI singleton is not available.")
		return

	var lteapi: Object = Engine.get_singleton("LTEAPI")
	if not is_instance_valid(lteapi):
		push_error("{{plugin_name}}: LTEAPI singleton is invalid.")
		return

	# Minimum LTEAPI capability demo: retrieve the user singleton
	var lte_user: Object = lteapi.get_user()
	if is_instance_valid(lte_user):
		print("{{plugin_name}}: LTEAPI connected, user server available.")


func shutdown() -> void:
	pass
