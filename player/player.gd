extends CharacterBody2D

@onready var player_sprite = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer
@onready var muzzle_run : Marker2D = $MuzzleRun
@onready var muzzle_stand : Marker2D = $MuzzleStand
@onready var shoot_cooldown = $ShootCooldown

@export var speed : int = 8500
@export var jump : int = -350

var bullet = preload("res://player/bullet.tscn")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_state : State
var muzzle_run_position
var muzzle_stand_position

enum State { Idle, Run, Jump, Shoot, Stand }

func _ready():
	current_state = State.Idle
	muzzle_run_position = muzzle_run.position
	muzzle_stand_position = muzzle_stand.position
	#Engine.time_scale = 0.6

func _physics_process(delta : float):
	player_falling(delta)
	player_run(delta)
	player_jump()
	player_muzzle_position()
	player_shooting()
	
	move_and_slide()
	print(current_state)
	player_animations()

#PLAYER MOVEMENTS
func player_falling(delta : float):
	if not is_on_floor():
		velocity.y += gravity * delta

func player_run(delta : float):
	var direction = input_movement()
	
	if direction != 0:
		if is_on_floor() and current_state != State.Shoot:
			current_state = State.Run
		player_sprite.flip_h = direction < 0
		velocity.x = direction * speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, 2 * speed * delta)
		player_idle()

func player_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		current_state = State.Jump

func player_shooting():
	if Input.is_action_pressed("shoot") :
		if current_state == State.Run:
			current_state = State.Shoot
			if $ShootCooldown.is_stopped():
				shoot(muzzle_run)
				shoot_timer.start()
			
		elif input_movement() == 0 and is_on_floor():
			current_state = State.Stand
			if $ShootCooldown.is_stopped():
				shoot(muzzle_stand)
				shoot_timer.start()
			
func player_muzzle_position():
	if !player_sprite.flip_h:
		muzzle_run.position.x = muzzle_run_position.x
		muzzle_stand.position.x = muzzle_stand_position.x
	else:
		muzzle_run.position.x = -muzzle_run_position.x
		muzzle_stand.position.x = -muzzle_stand_position.x

func input_movement() -> int:
	var direction = Input.get_axis("move_left", "move_right")
	return 1 if direction > 0 else -1 if direction < 0 else 0

func player_idle():
	if is_on_floor() and current_state != State.Stand:
		if !Input.is_action_pressed("shoot"):
			current_state = State.Idle
		else:
			current_state = State.Stand

#ANIMATIONS
func player_animations():
	match current_state:
		State.Idle:
			player_sprite.play("idle")
		State.Run:
			player_sprite.play("run")
		State.Jump:
			player_sprite.play("jump")
		State.Shoot:
			player_sprite.play("run_shoot")
		State.Stand:
			player_sprite.play("stand_shoot")
			
#ACTIONS
func shoot(muzzle : Marker2D):
	var bullet_instance = bullet.instantiate() as Node2D
	bullet_instance.direction = -1 if player_sprite.flip_h else 1
	bullet_instance.global_position = muzzle.global_position
	get_parent().add_child(bullet_instance)
	$ShootCooldown.start()
	
#TIMERS
func _on_shoot_timer_timeout():
	if current_state == State.Shoot:
		current_state = State.Run
	elif current_state == State.Stand:
		current_state = State.Idle
