extends KinematicBody2D

const ACCELERATION = 1000
const MAX_SPEED = 6000
const LIMIT_SPEED_Y = 1000
const JUMP_HEIGHT = 11000
const MIN_JUMP_HEIGHT = 2000
const MAX_COYOTE_TIME = 6
const JUMP_BUFFER_TIME = 10
const WALL_JUMP_AMOUNT = 3000
const WALL_JUMP_TIME = 16
const WALL_SLIDE_FACTOR = 0.9
const WALL_HORIZONTAL_TIME = 10
const GRAVITY = 600
const DASH_SPEED = 12000
const WALL_JUMP_BUFFER = 2

# Physics vars
var velocity = Vector2()
var axis = Vector2()
var wall_jump_direction = 1

# Timers
var coyote_timer = 0
var jump_buffer_timer = 0
var wall_jump_timer = 1000
var wall_horizontal_timer = 0
var dash_time = 0
var wall_press_timer = 0

# Sprite state
var sprite_color = "red"
var can_jump = false
var friction = false
var wall_sliding = false
var trail = false
var is_dashing = false
var has_dashed = false
var is_grabbing = false
var pressed_to_wall = false
var has_double_jumped = false
var is_double_jumping = false

func _physics_process(delta):
	# If vertical velocity is less than the max falling speed and you are not
	# dashing, apply more gravity to the sprite.
	if velocity.y < LIMIT_SPEED_Y:
		if !is_dashing:
			velocity.y += GRAVITY * delta
		
	# Unless stated otherwise, don't apply friction. Friction allows the player
	# to move in air... I think
	friction = false
	
	if wall_press_timer > 0:
		print("pressed")
		wall_press_timer -= 1
	
	if $Rotatable/RayCast2D.is_colliding():
		pressed_to_wall = true
		
	if $Rotatable/RayCast2D.is_colliding() == false and pressed_to_wall:
		pressed_to_wall = false
		wall_press_timer = WALL_JUMP_BUFFER
	
	# Process user input, dash logic, and wallslide logic
	get_input_axis()
	dash(delta)
	double_jump(delta)
	wall_slide(delta)
	
	# Handle basic vertical movement mechanics
	if wall_jump_timer > WALL_JUMP_TIME:
		#wall_jump_timer = WALL_HORIZONTAL_TIME
		# If you are not grabbing or dashing, performs horizontal movement
		if !is_dashing and !is_grabbing:
			horizontal_movement(delta)
	else:
		#print("build up %d" % wall_jump_timer)
		#velocity.x = -WALL_JUMP_AMOUNT * wall_jump_direction * delta
		wall_jump_timer += 1
		
	# If you can't jump or wall slide then you must be in the air,
	# check for what animation you should use (JUMP or FALL)
	if !can_jump:
		if !wall_sliding:
			if velocity.y >= 0:
				pass
				#print("Play: Fall Animation")
			elif velocity.y < 0:
				pass
				#print("Play: Jump Animation")
	
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
			if $Rotatable/RayCast2D.is_colliding() or is_pressing_away_from_wall():
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
	
func double_jump(delta):
	if !has_double_jumped:
		if !can_jump and !$Rotatable/RayCast2D.is_colliding():
			# If you can't jump (in air) and you haven't double jumped yet...
			if Input.is_action_just_pressed("jump"):
				has_double_jumped = true
				jump(delta)
				friction_on_air()
				
	if is_on_floor() and velocity.y >= 0:
		has_double_jumped = false
		sprite_color = "red"
	
func dash(delta):
	if !has_dashed:
		if Input.is_action_just_pressed("dash"):
			print("dash")
			if axis == Vector2.ZERO:
				axis.x = $Rotatable.scale.x
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

#
# Tells you if the player is pressing actively against a wall
#
func is_pressing_against_wall():
	if ($Rotatable.scale.x < 0 and Input.is_action_pressed("ui_left")) or ($Rotatable.scale.x > 0 and Input.is_action_pressed("ui_right")):
		return true
	return false
	
#
# Tells you if the player is pressing actively away from a wall
#
func is_pressing_away_from_wall():
	if wall_press_timer > 0:
		return true
	return false
	
func wall_slide(delta):
	if !can_jump:
		if $Rotatable/RayCast2D.is_colliding():
			if is_pressing_against_wall():
				wall_sliding = true
				if Input.is_action_pressed("grab"):
					is_grabbing = true
					if axis.y != 0:
						velocity.y = axis.y * 12000 * delta
						#$AnimationPlayer.play(str(sprite_color, "Climb"))
					else:
						velocity.y = 0
						#$AnimationPlayer.play(str(spriteColor, "Wall Slide"))
				else:
					is_grabbing = false
					velocity.y = velocity.y * WALL_SLIDE_FACTOR
					#$AnimationPlayer.play(str(spriteColor, "Wall Slide"))
		else:
			wall_sliding = false
			is_grabbing = false
	
func horizontal_movement(delta):
	if Input.is_action_pressed("ui_right"):
		if $Rotatable/RayCast2D.is_colliding():
			#yield(get_tree().create_timer(0.1),"timeout")
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
			#yield(get_tree().create_timer(0.1),"timeout")
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
	print("wall jump")
	wall_jump_timer = 0
	var multiplier = 1
	var dir = $Rotatable.scale.x
	if is_pressing_away_from_wall():
		dir = -dir
	if is_pressing_against_wall() or is_pressing_away_from_wall():
		multiplier = 1.5
	velocity.x = -WALL_JUMP_AMOUNT * dir * delta * multiplier
	velocity.y = -JUMP_HEIGHT * delta
	
	if is_pressing_against_wall():
		print("rotate")
		$Rotatable.scale.x = -dir
		wall_jump_direction = dir
		
	if is_pressing_away_from_wall():
		wall_press_timer = 0
	

func friction_on_air():
	if friction:
		velocity.x = lerp(velocity.x, 0, 0.01)

#
# This function allows the user to cancel a jump already in mid-air. This would
# be used if a user stopped pressing jump or released the up button for instance
#
func set_jump_height(delta):
	if Input.is_action_just_released("jump"):
		if velocity.y < -MIN_JUMP_HEIGHT * delta:
			velocity.y = -MIN_JUMP_HEIGHT * delta

	
	
