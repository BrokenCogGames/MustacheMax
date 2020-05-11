extends KinematicBody2D

const ACCELERATION = 3000
const MAX_SPEED = 18000
const LIMIT_SPEED_Y = 1200
const JUMP_HEIGHT = 36000
const MIN_JUMP_HEIGHT = 12000
const MAX_COYOTE_TIME = 6
const JUMP_BUFFER_TIME = 10
const WALL_JUMP_AMOUNT = 18000
const WALL_JUMP_TIME = 10
const WALL_SLIDE_FACTOR = 0.8
const WALL_HORIZONTAL_TIME = 30
const GRAVITY = 2100
const DASH_SPEED = 36000

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
				print("Play: Fall Animation")
			elif velocity.y < 0:
				print("Play: Jump Animation")
	
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

func get_input_axis():
	pass
	
func dash(delta):
	pass
	
func wall_slide(delta):
	pass
	
func horizontal_movement(delta):
	pass
	
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

	
	
