extends CharacterBody2D
@onready var crab_sprite = $AnimatedSprite2D
@onready var idle_timer = $IdleTimer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state : State
var direction : Vector2 = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_walk : bool = true

@export var speed : int = 1500
@export var patrol_points : Node

enum State { Idle, Walk }

func _ready():
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No patrol points")
		
	current_state = State.Walk

func _physics_process(delta : float):
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	
	move_and_slide()
	
	crab_animation()

func enemy_gravity(delta : float):
	if not is_on_floor():
		velocity.y += gravity*delta

func enemy_idle(delta : float):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed*delta)
		current_state = State.Idle
		current_state = State.Idle

func enemy_walk(delta : float):
	if !can_walk:
		return
	
	if abs(position.x -current_point.x) > 0.5:
		velocity.x = direction.x * speed * delta
		current_state = State.Walk
	else:
		current_point_position += 1
		
		if current_point_position >= number_of_points:
			current_point_position = 0
		
		current_point = point_positions[current_point_position]
	
		if current_point.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		
		can_walk = false
		idle_timer.start()

func _on_idle_timer_timeout():
	can_walk = true
	crab_sprite.flip_h = direction.x > 0
	current_state = State.Walk
	
func crab_animation():
	if current_state == State.Idle && !can_walk:
		crab_sprite.play("idle")
	elif current_state == State.Walk && can_walk:
		crab_sprite.play("walk")
