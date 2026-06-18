# LTE SDK

LTE SDK is a Godot plugin development kit for building Lightech editor plugins with LTEAPI.

This repository is a ready-to-open Godot template project. It includes the LTEAPI runtime artifact, a starter plugin template, and a CLI initializer that turns the template into your own plugin project.

## What Is Included

```text
addons/lteapi/              # LTEAPI runtime artifact and plugin packaging tools
addons/lte_plugin_template/  # Starter plugin template, not enabled by default
tools/init_plugin.gd         # CLI plugin initializer
sdk_manifest.json            # SDK metadata
project.godot                # Godot project file
```

LTE SDK consumes the compiled LTEAPI release artifact. It does not use the LTEAPI source repository as a submodule.

## Requirements

- Godot 4.6 or newer
- Windows x86_64 for the included LTEAPI binaries
- PowerShell 7 if you want to use the helper scripts in `dev/`

## Get The SDK

### Option 1: Download Release ZIP

This is the recommended path for plugin authors.

1. Download the latest LTE SDK release ZIP.
2. Extract it to your plugin workspace, for example:

```text
D:\LightechPlugins\MyPluginProject
```

3. Open a terminal in the extracted folder.

### Option 2: Clone The Repository

Use this if you want to keep your plugin project under Git immediately.

```powershell
git clone https://github.com/LuYingYiLong/LTE-SDK.git MyPluginProject
cd MyPluginProject
```

This repository does not require submodules.

## Create A Plugin Project

Run the initializer from the SDK project root:

```powershell
Godot --headless --path . --script res://tools/init_plugin.gd -- --plugin-id my_plugin --plugin-name "My Plugin" --author "YourName"
```

The initializer will:

- copy `addons/lte_plugin_template` to `addons/my_plugin`
- replace template placeholders
- update `project.godot` project name
- enable your generated plugin
- remove the original template directory unless `--keep-template` is used

Plugin IDs must use lowercase letters, digits, and underscores, and must not start with a digit.

## Initializer Options

```powershell
Godot --headless --path . --script res://tools/init_plugin.gd -- --help
```

Common options:

```text
--plugin-id       Unique plugin ID, such as my_plugin
--plugin-name     Display name, such as "My Plugin"
--author          Author name
--description     Optional short description
--force           Replace an existing target plugin directory
--keep-template   Keep addons/lte_plugin_template after initialization
```

Example:

```powershell
Godot --headless --path . --script res://tools/init_plugin.gd -- --plugin-id note_tools --plugin-name "Note Tools" --author "YourName" --description "Extra note editing tools"
```

## Open In Godot

After initialization, open the project:

```powershell
Godot --path .
```

Your plugin code is in:

```text
addons/<plugin_id>/
```

The generated plugin is enabled in `project.godot`. You can edit `plugin.gd`, add scenes, add scripts, and call LTEAPI from your plugin.

## Package A Plugin

LTEAPI includes helper tools for packaging `.lteplugin` files.

From your initialized plugin project:

```powershell
Godot --headless --path . --script res://addons/lteapi/tools/lteplugin_packer_cli.gd -- pack --source res://addons/my_plugin --output my_plugin.lteplugin
```

You can also validate a plugin folder:

```powershell
Godot --headless --path . --script res://addons/lteapi/tools/lteplugin_packer_cli.gd -- validate --source res://addons/my_plugin
```

## Refresh LTEAPI Runtime

SDK releases already include LTEAPI runtime files. SDK maintainers can refresh them from a local LTEAPI checkout:

```powershell
pwsh -File dev/sync_lteapi_release.ps1 -Source D:\GodotProjects\LTEAPI
```

This copies only the release artifact files into `addons/lteapi/`. It does not copy LTEAPI source code, `godot-cpp`, or build project files.

## Repository Roles

```text
LTEAPI
  Maintains native GDExtension source and publishes LTEAPI runtime artifacts.

LTE SDK
  Provides a Godot plugin template project with the LTEAPI runtime artifact.

Lightech
  Loads and runs installed plugins inside the editor.
```

## Notes

- Do not add the LTEAPI source repository as a submodule inside SDK projects.
- Do not edit files under `addons/lteapi/` unless you are updating the embedded runtime artifact.
- Keep your plugin code under `addons/<plugin_id>/`.
- The starter template is only a scaffold. After initialization, your generated plugin is the one you should edit.
