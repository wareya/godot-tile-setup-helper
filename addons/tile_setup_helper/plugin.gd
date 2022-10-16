tool
extends EditorPlugin

var plugin
func _enter_tree():
    plugin = preload("helper.gd").new()
    add_inspector_plugin(plugin)

func _process(delta):
    if plugin:
        plugin.interface = get_editor_interface()

func handles(object : Object):
    if object is TileSet:
        return true

func edit(object : Object):
    if plugin:
        plugin.current = object

func clear():
    if plugin:
        plugin.current = null

func _exit_tree():
    remove_inspector_plugin(plugin)
