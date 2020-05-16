extends KinematicBody2D

# Player movement speed
export (float) var speed
export (float) var animation_duration

var spigot

func _input(event):
	if event.is_action_released("ui_select"):
		if spigot:
			spigot.stop()

var position1
var position2

var flag = true

onready var node = get_node("Sprite")
onready var effect = get_node("Tween")
var tween

func _ready():
	position1 = get_node("Position1").get_global_position()
	position2 = get_node("Position2").get_global_position()
	self.position = position1
	
	set_process(true)
	tween = self.get_node("Sprite/Tween")
	tween.interpolate_property(self.get_node("Sprite"), "rotation_degrees", 0, -360,
								animation_duration, Tween.TRANS_LINEAR)
	tween.start()

func _physics_process(delta):
	var direction: Vector2
	$AnimationPlayer.play("down")
	var jitter = 2 
	if(self.position.x <= position1.x + jitter && self.position.x >= position1.x - jitter &&
	   self.position.y <= position1.y + jitter && self.position.y >= position1.y - jitter):
		flag = true
		print("self " + str(self.position))
		print("pos1 " + str(position1))
		print(flag)
	if(self.position.x <= position2.x + jitter && self.position.x >= position2.x - jitter &&
	   self.position.y <= position2.y + jitter && self.position.y >= position2.y - jitter):
		flag = false
		print("self " + str(self.position))
		print("pos2 " + str(position2))
		print(flag)
	
	if (flag):
		direction = self.position.direction_to(position2)
		print("dir " + str(direction))
	else:
		direction = self.position.direction_to(position1)
		print("dir " + str(direction))
	
	# Apply movement
	var movement = speed * direction * delta
	move_and_collide(movement)

func _on_TickCounter_timeout():
	var by_spigot = false
	var bodies = $DetectArea.get_overlapping_bodies()
	for body in bodies:
		# Check to see if we are attacking a player!
		if body.name == "Player":
			body._saw_hit()


func _on_Tween_tween_completed(object, key):
	tween.interpolate_property(self.get_node("Sprite"), "rotation_degrees", 0, -360,
								animation_duration, Tween.TRANS_LINEAR)
	tween.start()
	pass # Replace with function body.
