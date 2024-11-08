@tool
extends EditorPlugin

const PLUGIN_PATH := "plugins/node_to_camera/shortcut"

var shortcut: Shortcut = preload("res://addons/node_to_camera/default_shortcut.tres")

func _enter_tree() -> void:
	var settings := EditorInterface.get_editor_settings()
	settings.set_setting(PLUGIN_PATH, shortcut)

func _exit_tree() -> void:
	var settings := EditorInterface.get_editor_settings()
	settings.clear(PLUGIN_PATH)
	settings.save()
	pass

func _shortcut_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if shortcut.matches_event(event):
		var camera := EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		var camTransform := camera.get_camera_transform()
		var selectedNodes := EditorInterface.get_selection().get_selected_nodes()
		for node: Node in selectedNodes:
			if node is Node3D:
				var node_3d := node as Node3D
				node_3d.global_transform = camTransform

		get_viewport().set_input_as_handled()
