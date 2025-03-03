extends Node3D

const RAY_LENGTH := 1000
@onready var shader = load("res://ArtAssets/Shaders/Sand.gdshader") as Shader
@onready var viewport := $SubViewportContainer/SubViewport as SubViewport
@onready var sprite := $SubViewportContainer/SubViewport/Sprite2D as Sprite2D
@export var mesh : MeshInstance3D

@onready var sand_tex = load("uid://dpni7xv27k32k") as Texture2D
#var material : ShaderMaterial

func _ready() -> void:
	'''material = mesh.get_active_material(0) as ShaderMaterial
	if material:
		material.set_shader_parameter("draw_mask", viewport.get_texture())'''
	
	'''if viewport != null:
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		var draw_material = mesh.get_surface_override_material(0)
		if not draw_material:
			draw_material = StandardMaterial3D.new()
			mesh.set_surface_override_material(0, draw_material)
		draw_material.albedo_texture = viewport.get_texture()'''
	
	if mesh != null and sand_tex != null:
		var sand_material = StandardMaterial3D.new()
		sand_material.albedo_texture = sand_tex
		mesh.set_surface_override_material(0, sand_material)

func _process(delta: float) -> void:
	if get_mouse_world_position() != null:
		var mouse_pos = get_mouse_world_position()
		#print(mouse_pos)
		sprite.global_position = Vector2(mouse_pos.x * 8, mouse_pos.z * 8)

func _do_raycast_on_mouse_position(collision_mask: int = 0b00000000_00000000_00000000_00000001):
	# Raycast related code
	var space_state = get_world_3d().direct_space_state
	var cam = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collision_mask = collision_mask
	
	var result = space_state.intersect_ray(query) # raycast result
	return result

# Gets ray-cast hit position from camera to world.
# @return Vector3 or null
func get_mouse_world_position(collision_mask: int = 0b00000000_00000000_00000000_00000001):
	var raycast_result = _do_raycast_on_mouse_position(collision_mask)
	if raycast_result:
		return raycast_result.position
	return null

# Gets ray-cast hit object from camera to world.
# @return Object or null
func get_raycast_hit_object(collision_mask: int = 0b00000000_00000000_00000000_00000001):
	var raycast_result = _do_raycast_on_mouse_position(collision_mask)
	if raycast_result:
		return raycast_result.collider
	return null

func _on_mouse_clicked(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
		else:
			var mask_img = viewport.get_texture().get_image()
			var sand_img = sand_tex.get_image()
			var rect = Rect2i(Vector2i.ZERO, mask_img.get_size())
			sand_img.blend_rect_mask(sand_img, mask_img, rect, Vector2i.ZERO)
			var blend_tex = ImageTexture.create_from_image(sand_img)
			
			var blend_material = StandardMaterial3D.new()
			blend_material.albedo_texture = blend_tex
			mesh.set_surface_override_material(0, blend_material)
			
			viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
