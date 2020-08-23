extends KinematicBody2D

export(int) var ACCELERATION = 300
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 200
export(int) var WANDER_PROXIMITY_RANGE = 4

const EnemyDeathEffect = preload("res://Resources/Effects/EnemyDeathEffect.tscn")
var knockback = Vector2.ZERO
var state = IDLE
var velocity = Vector2.ZERO

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtBox = $Hurtbox
onready var softCollission = $SoftCollision
onready var wanderController = $WanderController
onready var animatedSprite = $AnimatedSprite

enum {
	IDLE,
	WANDER,
	CHASE
}


func _ready():
	state = pick_random_state([IDLE, WANDER])


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, (FRICTION) * delta) #friccao fake
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			idle_keep_position(delta)
		
		WANDER:
			wander_path(delta)
		
		CHASE:
			chase_player(delta)
	
	if softCollission.is_colliding():
		velocity += softCollission.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)


func idle_keep_position(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	seek_player()
	
	if wanderController.get_time_left() == 0:
		renew_random_state()


func wander_path(delta):
	seek_player()
	if wanderController.get_time_left() == 0:
		renew_random_state()
	
	accelerate_towards_point(wanderController.target_position, delta)
	
	if global_position.distance_to(wanderController.target_position) < WANDER_PROXIMITY_RANGE:
		renew_random_state()


func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	animatedSprite.flip_h = direction.x < 0


func renew_random_state():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func chase_player(delta):
	var player = playerDetectionZone.player
	if player != null:
		accelerate_towards_point(player.global_position, delta)
	else:
		state = IDLE


func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE


func _on_Hurtbox_area_entered(area):
	stats.set_health(stats.get_health() - area.damage)
	knockback = (self.global_position - area.get_parent().global_position).normalized() *120
	hurtBox.create_hit_effect()
	hurtBox.start_invicibility(0.5)


func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	queue_free()
