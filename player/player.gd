extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state

enum State { Idle, Run }

func _ready():
	current_state = State.Idle

func _physics_process(delta):
	player_falling(delta)
	player_idle()
		
	move_and_slide()

func player_falling(delta):
	if not is_on_floor():
		velocity.y += gravity*delta

func player_idle():
	if is_on_floor():
		current_state = State.Idle
