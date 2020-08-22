extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("ui_attack"):
		var GrassEffect = load("res://Resources/Effects/GrassEffect.tscn")
		var grassEffect = GrassEffect.instance()
		get_parent().add_child(grassEffect)
		grassEffect.global_position = self.position
		
		queue_free()
