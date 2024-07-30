extends CharacterBody2D

@onready var player_sprite = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer
@onready var muzzle_run : Marker2D = $MuzzleRun
@onready var muzzle_stand : Marker2D = $MuzzleStand
@onready var shoot_cooldown = $ShootCooldown
@onready var coyote_timer = $CoyoteTimer
@onready var hit_animation_player = $HitAnimationPlayer

@export var speed : int = 8500
@export var jump : int = -350

var bullet = preload("res://player/bullet.tscn")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_state : State
var muzzle_run_position
var muzzle_stand_position
var was_on_ground : bool = true
var on_floor : bool = true

enum State { Idle, Run, Jump, Shoot, Stand, Duck}

func _ready():
	current_state = State.Idle
	muzzle_run_position = muzzle_run.position
	muzzle_stand_position = muzzle_stand.position
	#Engine.time_scale = 0.1

func _physics_process(delta : float):
	on_floor = is_on_floor()
	player_falling(delta)
	player_run(delta)
	player_jump()
	player_muzzle_position()
	player_shooting()
	
	move_and_slide()
	started_falling()
	player_animations()

#PLAYER MOVEMENTS
func player_falling(delta : float):
	if not on_floor:
		velocity.y += gravity * delta

func player_run(delta : float):
	var direction = input_movement()
	
	if direction != 0:
		if on_floor and current_state != State.Shoot:
			current_state = State.Run
		player_sprite.flip_h = direction < 0
		velocity.x = direction * speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, 2 * speed * delta)
		player_idle()
		player_duck()

func player_jump():
	if Input.is_action_just_pressed("jump") and (on_floor or !coyote_timer.is_stopped()):
		velocity.y = jump
		current_state = State.Jump

func player_shooting():
	if Input.is_action_pressed("shoot"):
		if current_state == State.Run:
			current_state = State.Shoot
			try_shoot(muzzle_run)
		elif input_movement() == 0 and on_floor:
			current_state = State.Stand
			try_shoot(muzzle_stand)

func try_shoot(muzzle: Marker2D):
	if shoot_cooldown.is_stopped():
		shoot(muzzle)
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
	if on_floor and current_state != State.Stand:
		if !Input.is_action_pressed("shoot"):
			current_state = State.Idle
		else:
			current_state = State.Stand
			
func player_duck():
	if on_floor and current_state == State.Idle and Input.is_action_pressed("crouch"):
		current_state = State.Duck

func started_falling():
	if was_on_ground and !on_floor and !Input.is_action_just_pressed("jump"):
		coyote_timer.start()
	was_on_ground = on_floor

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
		State.Duck:
			player_sprite.play("duck")
			
#ACTIONS
func shoot(muzzle : Marker2D):
	var bullet_instance = bullet.instantiate() as Node2D
	bullet_instance.direction = -1 if player_sprite.flip_h else 1
	bullet_instance.global_position = muzzle.global_position
	get_parent().add_child(bullet_instance)
	shoot_cooldown.start()
	
#TIMERS
func _on_shoot_timer_timeout():
	if current_state == State.Shoot:
		current_state = State.Run
	elif current_state == State.Stand:
		current_state = State.Idle

#SIGNALS
func _on_hurtbox_body_entered(body : Node2D):
	if body.is_in_group("Enemy"):
		hit_animation_player.play("hit")
		HealthManager.decrease_health(body.contact_damage)
