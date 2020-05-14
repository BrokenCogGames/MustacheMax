extends KinematicBody2D

const ACCELERATION = 1000
const MAX_SPEED = 6000
const LIMIT_SPEED_Y = 1000
const JUMP_HEIGHT = 12000
const MIN_JUMP_HEIGHT = 4000
const MAX_COYOTE_TIME = 6
const JUMP_BUFFER_TIME = 10
const WALL_JUMP_AMOUNT = 5000
const WALL_JUMP_TIME = 10
const WALL_SLIDE_FACTOR = 0.8
const WALL_HORIZONTAL_TIME = 30
const GRAVITY = 900
const DASH_SPEED = 12000

# Physics vars
var velocity = Vector2()
var axis = Vector2()

# Timers
var coyote_timer = 0
var jump_buffer_timer = 0
var wall_jump_timer = 0
var wall_horizontal_timer = 0
var dash_time = 0

# Sprite state
var sprite_color = "red"
var can_jump = false
var friction = false
var wall_sliding = false
var trail = false
var is_dashing = false
var has_dashed = false
var is_grabbing = false

# Camera variables
var prev_anchor
var current_anchor
var camera
var camera_anchor
var area_limits
var current_area
var area_position

onready var effect = get_node("CameraTransition")

func _ready():
	camera = self.find_node("PlayerAnchor").get_child(0)
	camera_anchor = self.find_node("PlayerAnchor").get_child(0)

func _physics_process(delta):
	# If vertical velocity is less than the max falling speed and you are not
	# dashing, apply more gravity to the sprite.
	if velocity.y < LIMIT_SPEED_Y:
		if !is_dashing:
			velocity.y += GRAVITY * delta
		
	# Unless stated otherwise, don't apply friction. Friction allows the player
	# to move in air... I think
	friction = false
	
	# Process user input, dash logic, and wallslide logic
	get_input_axis()
	dash(delta)
	wall_slide(delta)
	#if camera != null:
	#	print(camera.position)
	
	# Handle basic vertical movement mechanics
	if wall_jump_timer > WALL_JUMP_TIME:
		wall_jump_timer = WALL_JUMP_AMOUNT
		# If you are not grabbing or dashing, performs horizontal movement
		if !is_dashing and !is_grabbing:
			horizontal_movement(delta)
	else:
		wall_jump_timer += 1
		
	# If you can't jump or wall slide then you must be in the air,
	# check for what animation you should use (JUMP or FALL)
	if !can_jump:
		if !wall_sliding:
			if velocity.y >= 0:
				#print("Play: Fall Animation")
				pass
			elif velocity.y < 0:
				#print("Play: Jump Animation")
				pass
	
	# Jumping mechanics and coyote time
	if is_on_floor():
		# If you are on the floor, you can jump again, and it resets COYOTE_TIME.
		can_jump = true
		coyote_timer = 0
	else:
		# Player is not on the ground, apply coyote time.
		coyote_timer += 1
		if coyote_timer > MAX_COYOTE_TIME:
			can_jump = false
			coyote_timer = 0
		friction = true
		
	jump_buffer(delta)
	
	if Input.is_action_just_pressed("jump"):
		if can_jump:
			jump(delta)
			friction_on_air()
		else:
			if $Rotatable/RayCast2D.is_colliding():
				wall_jump(delta)
			friction_on_air()
			jump_buffer_timer = JUMP_BUFFER_TIME
			
	set_jump_height(delta)
	jump_buffer(delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)

#
# Get a normalized vector pointing in the direction of the players movement
# according to the input keys. Pressing LEFT and RIGHT at the same time cancels
# eacho ther out. This allows for 8 different directions of movement.
#
func get_input_axis():
	axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	axis = axis.normalized()
	
func dash(delta):
	if !has_dashed:
		if Input.is_action_just_pressed("dash"):
			velocity = axis * delta * DASH_SPEED
			sprite_color = "blue"
			Input.start_joy_vibration(0, 1, 1, 0.2)
			is_dashing = true
			has_dashed = true
			#$Camera/ShakeCamera2D.add_trauma(0.5)
	
	if is_dashing:
		trail = true
		dash_time += 1
		# huh?
		if dash_time >= int(0.25 * 1 / delta):
			is_dashing = false
			trail = false
			dash_time = 0
			
	if is_on_floor() and velocity.y >= 0:
		has_dashed = false
		sprite_color = "red"
	
func wall_slide(delta):
	pass
	
func horizontal_movement(delta):
	if Input.is_action_pressed("ui_right"):
		if $Rotatable/RayCast2D.is_colliding():
			yield(get_tree().create_timer(0.1),"timeout")
			velocity.x = min(velocity.x + ACCELERATION * delta, MAX_SPEED * delta)
			$Rotatable.scale.x = 1
			if can_jump:
				pass
				#$AnimationPlayer.play(str(sprite_color, "Run"))
		else:
			velocity.x = min(velocity.x + ACCELERATION * delta, MAX_SPEED * delta)
			$Rotatable.scale.x = 1
			if can_jump:
				pass
				#$AnimationPlayer.play(str(sprite_color, "Run"))

	elif Input.is_action_pressed("ui_left"):
		if $Rotatable/RayCast2D.is_colliding():
			yield(get_tree().create_timer(0.1),"timeout")
			velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_SPEED * delta)
			$Rotatable.scale.x = -1
			if can_jump:
				pass
				#$AnimationPlayer.play(str(sprite_color, "Run"))
		else:
			velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_SPEED * delta)
			$Rotatable.scale.x = -1
			if can_jump:
				pass
				#$AnimationPlayer.play(str(sprite_color, "Run"))
	else:
		velocity.x = lerp(velocity.x, 0, 0.4)
		if can_jump:
			pass
			#$AnimationPlayer.play(str(sprite_color, "Idle"))
	
#
# The jump buffer is used to allow the player to input a JUMP command within
# the time right before they ht the ground. This helps remove the feeling of
# a failed jump when they press the jump button a little bit too soon.
# Use JUMP_BUFFER_TIME to set the jump_buffer_timer and determine how big that
# window of time is.
#
func jump_buffer(delta):
	if jump_buffer_timer > 0:
		if is_on_floor():
			jump(delta)
		jump_buffer_timer -= 1
	
#
# Apply jump velocity to sprite
#
func jump(delta):
	# Apply a fraction of gravity for this frame
	velocity.y = -JUMP_HEIGHT * delta
	
func wall_jump(delta):
	wall_jump_timer = 0
	velocity.x = -WALL_JUMP_AMOUNT * $Rotatable.scale.x * delta
	velocity.y = -JUMP_HEIGHT * delta
	$Rotatable.scale.x = -$Rotatable.scale.x
	

func friction_on_air():
	pass

#
# This function allows the user to cancel a jump already in mid-air. This would
# be used if a user stopped pressing jump or released the up button for instance
#
func set_jump_height(delta):
	if Input.is_action_just_released("ui_up"):
		if velocity.y < -MIN_JUMP_HEIGHT * delta:
			velocity.y = -MIN_JUMP_HEIGHT * delta

	
	


var _original_local_anchor_pos = 0
func _on_Area2D_area_entered(area):
	# Check if it's a room!
	# TODO this should iterate through a list of rooms to see which one it is...
	current_area = area
	var destination_position
	var origin_position
	print(area.name)
	if "Room" in area.name:
		print("In " + area.name)
		prev_anchor = current_anchor
		current_anchor = area.find_node("CameraAnchor")
		area_limits = area.get_node('CollisionShape2D').shape.extents * 2
		area_position = area.get_child(0).get_global_position()
		if prev_anchor != null:
			# Tween here please
			print("Tween!")
			destination_position = current_anchor.get_global_position()
			origin_position = prev_anchor.get_global_position()
			print(camera.position)
			print(camera.get_global_position())
			print(origin_position)
			print(destination_position)
			print(camera.to_local(origin_position))
			print(camera.to_local(destination_position))
			effect.interpolate_property(camera, "position", camera.to_local(origin_position),
										camera.to_local(destination_position), 3.0,
										Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			_original_local_anchor_pos = camera.position
			camera.smoothing_enabled = false
			
			set_physics_process(false)
			set_process_unhandled_input(false)
			effect.start()
		else:
			print(area_limits)
			print(area_position)
			print("Not tween!")
			camera.limit_top = area_position.y - area_limits[1]
			camera.limit_bottom = (area_limits[1] / 2) + area_position.y
			camera.limit_left =  area_position.x
			camera.limit_right = (area_limits[0] / 2) + area_position.x
			#camera.set_global_position(current_anchor.get_global_position())
	

	pass # Replace with function body.


func _on_CameraTransition_tween_completed(object, key):
	print("Done!")
	print(area_limits)
	print("Current")
	print(current_area.name)
	camera.position = _original_local_anchor_pos
	camera.limit_top = area_position.y - area_limits[1]
	camera.limit_bottom = (area_limits[1] / 2) + area_position.y
	camera.limit_left =  area_position.x
	camera.limit_right = (area_limits[0] / 2) + area_position.x
	camera.smoothing_enabled = true
	
	set_physics_process(true)
	set_process_unhandled_input(true)
	#camera.set_global_position(current_anchor.get_global_position())
	#get_tree().paused = false
	pass # Replace with function body.


func _on_CameraTransition_tween_started(object, key):
	camera.limit_top = -10000000
	camera.limit_bottom = 10000000
	camera.limit_left =  -10000000
	camera.limit_right = 10000000
	pass # Replace with function body.
