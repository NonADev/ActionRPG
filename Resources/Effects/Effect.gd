extends AnimatedSprite


func _ready():
	var error = connect("animation_finished", self, "_on_animation_finished")
	if error:
		print(error)
	else:
		frame = 0
		play("Animate")


func _on_animation_finished():
	queue_free()
