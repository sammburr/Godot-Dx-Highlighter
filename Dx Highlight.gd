extends Node2D

@export_category("Target")
@export var TARGET : CollisionShape3D

enum OUTLINE {DX, BOX}
@export_category("Settings")
@export var OUTLINE_TYPE : OUTLINE
@export_subgroup("Generic")
@export var COLOR := Color.WHITE
@export var WIDTH := 20.0
@export_subgroup("Dx Outline")
@export var GAP := 370.0

# Used for dx outline
var offset = 0.0

# Keep track of the max and min verts of the bounding collision shape projected onto the screen
var max
var min
# Origin of collision shape
var origin

func _draw():
	if TARGET == null:
		return
		
	calc_box()
	
	if(get_viewport().get_camera_3d().is_position_behind(origin)):
		return
	
	var diff = max - min
	var width = WIDTH * (1/origin.distance_to(get_viewport().get_camera_3d().global_transform.origin))
	var gap = GAP * (1/origin.distance_to(get_viewport().get_camera_3d().global_transform.origin))
	
	# Draw dx outline
	if OUTLINE_TYPE == OUTLINE.DX:
		draw_dx_outline(max, min, 10.0, width, gap, COLOR)
	# Draw box outline
	elif OUTLINE_TYPE == OUTLINE.BOX:
		draw_rect_outline(max, min, width, COLOR)

func calc_box():
	# Calculate min and max coordinates on screen
	var size = TARGET.shape.size
	
	origin = TARGET.get_global_transform().origin
	var verts : PackedVector2Array
	
	verts.append(calc_vertex_on_screen(origin, Vector3(size.x/2, size.y/2, size.z/2)))
	verts.append(calc_vertex_on_screen(origin, Vector3(size.x/2, size.y/2, -size.z/2)))
	verts.append(calc_vertex_on_screen(origin, Vector3(size.x/2, -size.y/2, size.z/2)))
	verts.append(calc_vertex_on_screen(origin, Vector3(size.x/2, -size.y/2, -size.z/2)))
	verts.append(calc_vertex_on_screen(origin, Vector3(-size.x/2, size.y/2, size.z/2)))
	verts.append(calc_vertex_on_screen(origin, Vector3(-size.x/2, size.y/2, -size.z/2)))
	verts.append(calc_vertex_on_screen(origin, Vector3(-size.x/2, -size.y/2, size.z/2)))
	verts.append(calc_vertex_on_screen(origin, Vector3(-size.x/2, -size.y/2, -size.z/2)))
	
	var min_x = 999999
	var max_x = 0
	var min_y = 999999
	var max_y = 0
	
	for vert in verts:
		if vert.x > max_x:
			max_x = vert.x
		if vert.x < min_x:
			min_x = vert.x
		if vert.y > max_y:
			max_y = vert.y
		if vert.y < min_y:
			min_y = vert.y
	
	max = Vector2(max_x, max_y)
	min = Vector2(min_x, min_y)

func calc_vertex_on_screen(origin : Vector3, offset : Vector3):
	return get_viewport().get_camera_3d().unproject_position(origin + offset)

func draw_dx_outline(max, min, bump, width, gap, color):
	var half = (max + min)/2
	
	if offset >= bump - 0.01:
		offset = 0.0
	offset = lerp(offset, bump, 0.35)
	
	# Bottom Right
	draw_line(Vector2(max.x + width/2, max.y) + Vector2(offset, offset), Vector2(half.x + gap, max.y) + Vector2(offset, offset), color, width) # Bottom
	draw_line(max + Vector2(offset, offset), Vector2(max.x, half.y + gap) + Vector2(offset, offset), color, width) # Right

	# Top Left
	draw_line(Vector2(half.x - gap, min.y) - Vector2(offset, offset), Vector2(min.x - width/2, min.y) - Vector2(offset, offset), color, width) # Top
	draw_line(Vector2(min.x, half.y - gap) - Vector2(offset, offset), min - Vector2(offset, offset), color, width) # Left
	
	# Bottom Left
	draw_line(Vector2(min.x - width/2, max.y) + Vector2(-offset, offset), Vector2(half.x - gap, max.y) + Vector2(-offset, offset), color, width) # Bottom
	draw_line(Vector2(min.x, half.y + gap) + Vector2(-offset, offset), Vector2(min.x, max.y) - Vector2(offset, -offset), color, width) # Left
	
	# Top Right
	draw_line(Vector2(half.x + gap, min.y) + Vector2(offset, -offset), Vector2(max.x + width/2, min.y) + Vector2(offset, -offset), color, width) # Top
	draw_line(Vector2(max.x, half.y - gap) - Vector2(-offset, offset), Vector2(max.x, min.y) - Vector2(-offset, offset), color, width) # Right

func draw_rect_outline(max, min, width, color):
	var diff = max - min
	draw_rect(Rect2(max, -diff), color, false, width)

func _process(delta):
	queue_redraw()
