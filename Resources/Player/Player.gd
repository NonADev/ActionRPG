extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var hurtBox = $Hurtbox
export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION  = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var motion = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats


func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true


func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		ROLL:
			roll_state(delta)
			
		ATTACK:
			attack_state(delta)


func move_state(delta):	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	input_vector.y =Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		motion = motion.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		motion = motion.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("ui_shift"):
		state = ROLL
	
	if Input.is_action_just_pressed("ui_attack"):
		state = ATTACK


func roll_state(delta):
	motion = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	hurtBox.start_invicibility(0.1)
	move()


func attack_state(delta):
	motion = Vector2.ZERO
	animationState.travel("Attack")


func move():
	motion = move_and_slide(motion)


func attack_animation_finished():
	state = MOVE


func roll_animation_finished():
	motion /= 1.5
	state = MOVE


func _on_Hurtbox_area_entered(area: Area2D):
	stats.health -= 1
	hurtBox.start_invicibility(0.8)
	hurtBox.create_hit_effect()
