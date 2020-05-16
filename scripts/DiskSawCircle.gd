extends KinematicBody2D

export (float) var RotateSpeed
export (float) var animation_duration
var _centre
var _angle = 0
var Radius

var tween

func _ready():
	var radius_anchor = self.get_node("RadiusPosition")
	Radius = self.get_global_position().distance_to(radius_anchor.get_global_position())
	set_process(true)
	tween = self.get_node("Sprite/Tween")
	_centre = self.position
	tween.interpolate_property(self.get_node("Sprite"), "rotation_degrees", 0, -360,
								animation_duration, Tween.TRANS_LINEAR)
	tween.start()

func _physics_process(delta): 
	$AnimationPlayer.play("down")
	_angle += RotateSpeed * delta;
	var offset = Vector2(sin(_angle), cos(_angle)) * Radius;
	var pos = _centre + offset
	self.position = pos

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
