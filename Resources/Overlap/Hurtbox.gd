extends Area2D

export(bool) var show_hit = true

const HitEffect = preload("res://Resources/Effects/HitEffect.tscn")
var invicible = false setget set_invincible

onready var timer = $Timer

signal invicibility_started
signal invicibility_ended


func set_invincible(value):
	invicible = value
	if invicible == true:
		emit_signal("invicibility_started")
	else:
		emit_signal("invicibility_ended")


func start_invicibility(duration):
	self.invicible = true
	timer.start(duration)


func create_hit_effect():
	var hitEffect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(hitEffect)
	hitEffect.position = global_position


func _on_Timer_timeout():
	self.invicible = false


func _on_Hurtbox_invicibility_started():
	set_deferred("monitoring", false)


func _on_Hurtbox_invicibility_ended():
	set_deferred("monitoring", true)
