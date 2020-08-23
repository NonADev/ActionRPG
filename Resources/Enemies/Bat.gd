extends KinematicBody2D

export(int) var ACCELERATION = 300
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 100

const EnemyDeathEffect = preload("res://Resources/Effects/EnemyDeathEffect.tscn")
var knockback = Vector2.ZERO
var state = IDLE
var velocity = Vector2.ZERO

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone

enum {
	IDLE,
	WANDER,
	CHASE
}


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, (FRICTION) * delta) #friccao fake
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		
		WANDER:
			pass
		
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE

	move_and_slide(velocity)


func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE


func _on_Hurtbox_area_entered(area):
	stats.set_health(stats.get_health() - area.damage)
	knockback = (self.global_position - area.get_parent().global_position).normalized() *120


func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	queue_free()