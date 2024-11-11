@tool
extends EditorPlugin

const PLUGIN_PATH              := "plugins/node_to_camera/"
var shortcut_pos: Shortcut     =  preload("res://addons/node_to_camera/shortcut_pos.tres")
var shortcut_rot: Shortcut     =  preload("res://addons/node_to_camera/shortcut_rot.tres")
var shortcut_pos_rot: Shortcut =  preload("res://addons/node_to_camera/shortcut_pos_rot.tres")
var ntc_ui: Control


func _enter_tree() -> void:
	var settings := ProjectSettings
	settings.set_setting(PLUGIN_PATH + "shortcut_position", shortcut_pos)
	settings.set_setting(PLUGIN_PATH + "shortcut_rotation", shortcut_rot)
	settings.set_setting(PLUGIN_PATH + "shortcut_position_rotation", shortcut_pos_rot)

	ntc_ui = _create_ui_control()
	ntc_ui.set_visible(false)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, ntc_ui)


func _exit_tree() -> void:
	var settings := ProjectSettings
	settings.clear(PLUGIN_PATH + "shortcut")
	settings.clear(PLUGIN_PATH + "shortcut_position")
	settings.clear(PLUGIN_PATH + "shortcut_rotation")
	settings.clear(PLUGIN_PATH + "shortcut_position_rotation")
	settings.save()

	if ntc_ui:
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, ntc_ui)
		ntc_ui.queue_free()
		ntc_ui = null


func _shortcut_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if shortcut_pos.matches_event(event):
		_node_3d_set_cam_transform(true, false)
		get_viewport().set_input_as_handled()
	elif shortcut_rot.matches_event(event):
		_node_3d_set_cam_transform(false, true)
		get_viewport().set_input_as_handled()
	elif shortcut_pos_rot.matches_event(event):
		_node_3d_set_cam_transform(true, true)
		get_viewport().set_input_as_handled()


# Only handles a single selected node_3d (or descendant)
func _handles(object: Object) -> bool:
	return object is Node3D


func _make_visible(visible: bool) -> void:
	if ntc_ui:
		ntc_ui.set_visible(visible)


func _create_ui_control() -> Control:
	var pos_button := Button.new()
	pos_button.text = "Pos"
	pos_button.connect("pressed", _button_set_pos)

	var rotation_button := Button.new()
	rotation_button.text = "Rot"
	rotation_button.connect("pressed", _button_set_rotation)

	var pos_rotation_button := Button.new()
	pos_rotation_button.text = "Pos+Rot"
	pos_rotation_button.connect("pressed", _button_set_pos_rotation)

	var control := HBoxContainer.new()
	control.add_child(pos_button)
	control.add_child(rotation_button)
	control.add_child(pos_rotation_button)
	return control


func _button_set_pos() -> void:
	_node_3d_set_cam_transform(true, false)


func _button_set_rotation() -> void:
	_node_3d_set_cam_transform(false, true)


func _button_set_pos_rotation() -> void:
	_node_3d_set_cam_transform(true, true)


func _node_3d_set_cam_transform(set_position: bool, set_rotation: bool) -> void:
	var camera        := EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
	var cam_pos       := camera.global_position
	var cam_rotation  := camera.global_rotation
	var selectedNodes := EditorInterface.get_selection().get_selected_nodes()
	for node: Node in selectedNodes:
		if node is Node3D:
			var node_3d := node as Node3D
			if set_position:
				node_3d.global_position = cam_pos
			if set_rotation:
				node_3d.global_rotation = cam_rotation