tool
extends EditorInspectorPlugin


func visit_children(node : Node, with : Object, method : String, binds : Array = []):
    var new_binds = binds.duplicate()
    new_binds.push_front(node)
    var v = with.callv(method, new_binds)
    if v != null:
        return v
    for child in node.get_children():
        v = visit_children(child, with, method, binds)
        if v != null:
            return v
    return null

func tile_set_finder(node : Node):
    if node.get_class() == "TileSetEditor":
        return node

func text_button_finder(node : Node, text):
    if node.is_class("Button") and node.text == text:
        return node


var interface : EditorInterface = null
var current : Object = null

var current_tileset = null
var current_obj = null
func can_handle(obj : Object) -> bool:
    return obj.is_class("TilesetEditorContext")

func parse_category(obj : Object, category : String):
    pass


class BitmaskButton extends Button:
    var bitmask_3x3min_alt = [
        [1,1,1,1,1,1,1,1,1,1,1,1],
        [1,0,1,1,0,0,0,0,0,0,0,1],
        [1,0,1,1,0,2,2,0,2,2,0,1],
        [1,0,1,1,0,2,2,0,2,2,0,1],
        [1,0,1,1,0,0,0,0,0,0,0,1],
        [1,0,1,1,0,2,2,0,2,2,0,1],
        [1,0,1,1,0,2,2,0,2,2,0,1],
        [1,0,1,1,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1],
        [1,0,1,1,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1],
    ]
    var bitmask_3x3min = [
        [1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1,1,1,1],
        [1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,1,0,0,1,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,1,0,0,1,1,1,0,1,1,0,0,1,0,0,1,1,1,0,0,1],
        [1,0,1,1,0,0,0,0,0,0,0,1,1,0,1,1,1,0,0,1,1,1,0,1,1,0,0,0,0,0,1,1,1,0,0,0],
        [1,0,1,1,0,1,1,0,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,1,1,0,0,1],
        [1,0,1,1,0,1,1,0,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,1],
        [1,0,1,1,0,0,0,0,0,0,0,1,1,0,1,1,1,0,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,0,1,1,1,0,1,1,0,0,0,0,0,1,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,0,1,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,0,1,1,1,1],
    ]
    var offsets_3x3min = [
        Vector2(-1, -1), Vector2( 0, -1), Vector2( 1, -1),
        Vector2(-1,  0), Vector2( 0,  0), Vector2( 1,  0),
        Vector2(-1,  1), Vector2( 0,  1), Vector2( 1,  1),
    ]
    var bits_3x3min = [
        TileSet.BIND_TOPLEFT,
        TileSet.BIND_TOP,
        TileSet.BIND_TOPRIGHT,
        TileSet.BIND_LEFT,
        TileSet.BIND_CENTER,
        TileSet.BIND_RIGHT,
        TileSet.BIND_BOTTOMLEFT,
        TileSet.BIND_BOTTOM,
        TileSet.BIND_BOTTOMRIGHT,
    ]
    
    var bitmask_2x2 = [
        [1,1,1,0,0,1,1,1],
        [0,1,1,0,0,0,0,0],
        [0,1,1,0,0,0,0,0],
        [1,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,1],
        [1,1,1,1,1,0,0,1],
        [1,1,1,1,1,0,0,1],
        [1,1,1,0,0,1,1,1],
    ]
    var offsets_2x2 = [
        Vector2(-1, -1), Vector2( 0, -1),
        Vector2(-1,  0), Vector2( 0,  0),
    ]
    var bits_2x2 = [
        TileSet.BIND_TOPLEFT,
        TileSet.BIND_TOPRIGHT,
        TileSet.BIND_BOTTOMLEFT,
        TileSet.BIND_BOTTOMRIGHT,
    ]
    
    var context
    var parent : Object
    func _init(_context, _parent).():
        context = _context
        parent = _parent
    func _ready():
        var editor_node = get_tree().get_root().get_child(0)
        var gui_base = editor_node.get_gui_base()
        icon = gui_base.get_icon("PackedDataContainer", "EditorIcons")
        text = "Place Bitmask"
    func _process(delta):
        if !is_instance_valid(context) or context.tile_autotile_bitmask_mode == 2 or context.tile_tile_mode != 1:
            visible = false
        else:
            visible = true
    func _pressed():
        # needed to avoid stale graphical state
        var editor = parent.visit_children(parent.interface.get_base_control(), parent, "tile_set_finder", [])
        
        var tileset = parent.current
        
        var mode = context.tile_autotile_bitmask_mode
        
        if !is_instance_valid(context) or mode == 2 or context.tile_tile_mode != 1:
            printerr("TILE HELPER: stale or misconfigured context ", context)
            return
        if !is_instance_valid(tileset):
            printerr("TILE HELPER: stale tileset ", tileset)
            return
        var tile = tileset.find_tile_by_name(context.tile_name)
        
        
        var size = tileset.autotile_get_size(tile)
        var real_size = (size + Vector2(1,1)*tileset.autotile_get_spacing(tile))
        var tile_count = tileset.tile_get_region(tile).size/real_size
        
        tileset.autotile_clear_bitmask_map(tile)
        for y in range(min(tile_count.y, 4)):
            for x in range(min(tile_count.x, 12 if mode == 1 else 4)):
                var bits = 0
                var offsets = offsets_3x3min if mode == 1 else offsets_2x2
                var bitmask = bitmask_3x3min if mode == 1 else bitmask_2x2
                var bits_array = bits_3x3min if mode == 1 else bits_2x2
                
                if bitmask == bitmask_3x3min and tile_count.x <= 4:
                    bitmask = bitmask_3x3min_alt
                
                var scale = 3 if mode > 0 else 2
                for i in range(offsets.size()):
                    var offset = offsets[i]
                    var bit = bitmask[y*scale+1+offset.y][x*scale+1+offset.x]
                    if bit == 0:
                        bits |= bits_array[i]
                    elif bit == 2:
                        bits |= bits_array[i] << 16
                tileset.autotile_set_bitmask(tile, Vector2(x, y), bits)
        
        if editor:
            # hack to force it to graphically update
            var button = parent.visit_children(editor, parent, "text_button_finder", [tr("Bitmask")])
            if button:
                button.pressed = true
                button.emit_signal("pressed")
            else:
                editor._zoom_in()
                editor._zoom_out()
        else:
            printerr("TILE HELPER: no editor to update")

class CollisionButton extends Button:
    var context
    var parent : Object
    var mode = "squares"
    func _init(_context, _parent, _mode).():
        context = _context
        parent = _parent
        mode = _mode
    func _ready():
        var editor_node = get_tree().get_root().get_child(0)
        var gui_base = editor_node.get_gui_base()
        if mode == "squares":
            icon = gui_base.get_icon("CollisionShape2D", "EditorIcons")
            text = "Place Square Collisions"
        elif mode == "envelope":
            icon = gui_base.get_icon("Node2D", "EditorIcons")
            text = "Place Hull Collisions"
        elif mode == "pixel":
            icon = gui_base.get_icon("Skeleton2D", "EditorIcons")
            text = "Place Pixel Collisions"
        else:
            icon = gui_base.get_icon("Remove", "EditorIcons")
            text = "Remove All Collisions"
    func _process(delta):
        if !is_instance_valid(context):
            visible = false
        else:
            visible = true
    
    func _px_alpha(image : Image, origin : Vector2, offset : Vector2) -> float:
        var size = image.get_size()
        var pos = origin + offset
        if pos.x >= size.x or pos.y >= size.y:
            return 0.0
        return image.get_pixelv(pos).a
    
    func _pressed():
        # needed to avoid stale graphical state
        var editor = parent.visit_children(parent.interface.get_base_control(), parent, "tile_set_finder", [])
        
        var tileset = parent.current
        if !is_instance_valid(context):
            printerr("TILE HELPER: stale or misconfigured context ", context)
            return
        if !is_instance_valid(tileset):
            printerr("TILE HELPER: stale tileset ", tileset)
            return
        
        var tile = tileset.find_tile_by_name(context.tile_name)
        tileset.tile_set_shapes(tile, [])
        
        var image = tileset.tile_get_texture(tile).get_data()
        image.lock()
        
        var atlas_mode = tileset.tile_get_tile_mode(tile)
        
        var origin = tileset.tile_get_region(tile).position
        
        var size = tileset.autotile_get_size(tile) \
                   if atlas_mode != TileSet.SINGLE_TILE \
                   else tileset.tile_get_region(tile).size
        var real_size = (size + Vector2(1,1)*tileset.autotile_get_spacing(tile)) \
                        if atlas_mode != TileSet.SINGLE_TILE \
                        else size
        var tile_count = tileset.tile_get_region(tile).size/real_size
        
        for y in range(ceil(tile_count.y)):
            for x in range(ceil(tile_count.x)):
                if atlas_mode == TileSet.AUTO_TILE and tileset.autotile_get_bitmask(tile, Vector2(x, y)) == 0:
                    continue
                if mode == "squares":
                    var shape = ConvexPolygonShape2D.new()
                    var points = PoolVector2Array()
                    points.push_back(Vector2(0, 0))
                    points.push_back(Vector2(0, size.y))
                    points.push_back(Vector2(size.x, size.y))
                    points.push_back(Vector2(size.x, 0))
                    shape.points = points
                    var xform = Transform2D.IDENTITY
                    tileset.tile_add_shape(tile, shape, xform, false, Vector2(x, y))
                elif mode == "envelope":
                    var shape = ConvexPolygonShape2D.new()
                    var point_cloud = PoolVector2Array()
                    var local_origin = origin + Vector2(x, y)*real_size
                    for p_y in range(size.y):
                        for p_x in range(size.x):
                            if _px_alpha(image, local_origin, Vector2(p_x, p_y)) > 0.5:
                                point_cloud.push_back(Vector2(p_x, p_y))
                                point_cloud.push_back(Vector2(p_x, p_y+1))
                                point_cloud.push_back(Vector2(p_x+1, p_y))
                                point_cloud.push_back(Vector2(p_x+1, p_y+1))
                    shape.set_point_cloud(point_cloud)
                    var xform = Transform2D.IDENTITY
                    tileset.tile_add_shape(tile, shape, xform, false, Vector2(x, y))
                elif mode == "pixel":
                    var scanlines = []
                    var local_origin = origin + Vector2(x, y)*real_size
                    for p_y in range(size.y):
                        var start = -1
                        for p_x in range(size.x):
                            if _px_alpha(image, local_origin, Vector2(p_x, p_y)) > 0.5:
                                if start < 0:
                                    start = p_x
                            else:
                                if start >= 0:
                                    scanlines.push_back([Vector2(start, p_y), Vector2(p_x, p_y+1)])
                                    start = -1
                        if start >= 0:
                            scanlines.push_back([Vector2(start, p_y), Vector2(size.x, p_y+1)])
                    
                    var i = -1
                    while i+1 < scanlines.size():
                        i += 1
                        var curr = scanlines[i]
                        var j = i
                        while j+1 < scanlines.size():
                            j += 1
                            var next = scanlines[j]
                            if curr[0].x == next[0].x and curr[1].x == next[1].x and curr[1].y == next[0].y:
                                curr[1].y = next[1].y
                                scanlines.remove(j)
                                j -= 1
                    
                    for scanline in scanlines:
                        var shape = ConvexPolygonShape2D.new()
                        var points = PoolVector2Array()
                        var start = scanline[0]
                        var end = scanline[1]
                        points.push_back(start)
                        points.push_back(Vector2(end.x, start.y))
                        points.push_back(end)
                        points.push_back(Vector2(start.x, end.y))
                        shape.points = points
                        var xform = Transform2D.IDENTITY
                        tileset.tile_add_shape(tile, shape, xform, false, Vector2(x, y))
                
        image.unlock()
        if editor:
            # hack to force it to graphically update
            var button = parent.visit_children(editor, parent, "text_button_finder", [tr("Collision")])
            if button:
                button.pressed = true
                button.emit_signal("pressed")
            else:
                editor._zoom_in()
                editor._zoom_out()
        else:
            printerr("TILE HELPER: no editor to update")


func parse_property(obj : Object, type : int, path : String, hint : int, hint_text : String, usage : int):
    if path == "tile_subtile_size":
        add_custom_control(BitmaskButton.new(obj, self))
    if (obj.tile_tile_mode != TileSet.SINGLE_TILE and path == "tile_subtile_size") or (obj.tile_tile_mode == TileSet.SINGLE_TILE and path == "tile_occluder_offset"):
        add_custom_control(CollisionButton.new(obj, self, "squares"))
        add_custom_control(CollisionButton.new(obj, self, "envelope"))
        add_custom_control(CollisionButton.new(obj, self, "pixel"))
        add_custom_control(CollisionButton.new(obj, self, "remove"))
    
    return false

func parse_begin(obj : Object):
    current_obj = obj

func parse_end():
    current_obj = null
