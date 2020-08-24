extends Camera2D

onready var pointTop_Left = $Node/PositionTop
onready var pointBottom_right = $Node/PositionBottom


func _ready():
	limit_top = pointTop_Left.global_position.y
	limit_left = pointTop_Left.global_position.x
	limit_bottom = pointBottom_right.global_position.y
	limit_right = pointBottom_right.global_position.x
