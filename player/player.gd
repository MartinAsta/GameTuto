extends CharacterBody2D
@onready var player_sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state : State

@export var speed : int = 200
@export var jump : int = -300

enum State { Idle, Run, Jump }

func _ready():
	current_state = State.Idle

func _physics_process(delta : float):
	player_falling(delta)
	player_run()
	player_jump()
	
	move_and_slide()
	
	player_animations()

#PLAYER MOVEMENTS
func player_falling(delta : float):
	if not is_on_floor():
		velocity.y += gravity*delta

func player_run():
	var direction = Input.get_axis("move_left", "move_right")
	direction = 1 if direction > 0 else floor(direction)
	
	if direction:
		if is_on_floor():
			current_state = State.Run
		player_sprite.flip_h = false if direction > 0 else true
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		player_idle()
		
func player_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		current_state = State.Jump
		
#ANIMATION STATES
func player_idle():
	if is_on_floor():
		current_state = State.Idle

#ANIMATIONS
func player_animations():
	if current_state == State.Idle:
		player_sprite.play("idle")
	elif current_state == State.Run:
		player_sprite.play("run")
	elif current_state == State.Jump:
		player_sprite.play("jump")
