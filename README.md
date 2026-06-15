# LTE SDK

LTE SDK is a Godot plugin template project for building Lightech plugins with LTEAPI.

## Layout

``text
addons/lteapi/             # LTEAPI release artifact
addons/lte_plugin_template/ # Starter plugin template
dev/sync_lteapi_release.ps1 # Local release artifact sync helper
sdk_manifest.json          # SDK metadata
``

## LTEAPI

This SDK consumes LTEAPI release artifacts. It should not use the LTEAPI source repository as a submodule.

To refresh the local runtime copy from a local LTEAPI checkout:

``powershell
pwsh -File dev/sync_lteapi_release.ps1 -Source D:\GodotProjects\LTEAPI
``
