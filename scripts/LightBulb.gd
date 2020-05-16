tool
extends StaticBody2D
class_name LightBulb

var light_on_texture = preload("res://assets/aseprite/lightbulb-on.png")
var light_off_texture = preload("res://assets/aseprite/lightbulb-unscrewed.png")

var light_has_been_turned_on = false

export var light_on = false setget set_light_on

func set_light_on(new_value):
	light_on = new_value
	if get_node("LightNode") != null:
		if light_on:
			light_has_been_turned_on = true
			$LightNode/Sprite.texture = light_on_texture
			$LightNode/Light.visible = true
			$LightMask.visible = true
			#$LightNode.enabled = true
		else:
			$LightNode/Sprite.texture = light_off_texture
			$LightNode/Light.visible = false
			$LightMask.visible = false
			#$LightNode.enabled = false
		
	
