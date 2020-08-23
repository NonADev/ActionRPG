extends Node2D

export(bool) var DESTRUTIBLE = true

const GrassEffect = preload("res://Resources/Effects/GrassEffect.tscn")


func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = self.position


func _on_Hurtbox_area_entered(area):
	if DESTRUTIBLE:
		create_grass_effect()
		queue_free()
