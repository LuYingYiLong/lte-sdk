# LTE SDK

LTE SDK is a Godot plugin template project for building Lightech plugins with LTEAPI.

## Layout

```text
addons/lteapi/              # LTEAPI release artifact
addons/lte_plugin_template/  # Starter plugin template (not enabled by default)
tools/init_plugin.gd         # CLI plugin initializer
sdk_manifest.json            # SDK metadata
```

## Quick Start

Open the project in Godot, then initialize your plugin:

```powershell
Godot --headless --path . --script res://tools/init_plugin.gd -- \
  --plugin-id my_plugin --plugin-name "My Plugin" --author "YourName"
```

The template plugin `addons/lte_plugin_template` is provided as a scaffold only.
It is **not enabled** by default. Run `init_plugin.gd` to create your own plugin
from the template — the generated plugin will be enabled automatically.

To see all options:

```powershell
Godot --headless --path . --script res://tools/init_plugin.gd -- --help
```

## LTEAPI

This SDK consumes LTEAPI release artifacts. It should not use the LTEAPI source repository as a submodule.

To refresh the local runtime copy from a local LTEAPI checkout:

```powershell
pwsh -File dev/sync_lteapi_release.ps1 -Source D:\GodotProjects\LTEAPI
```
