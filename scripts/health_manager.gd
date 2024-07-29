extends Node

var max_health : int = 6
var current_health : int

signal on_health_change

func _ready():
	current_health = max_health
	
func decrease_health(damage_taken : int):
	current_health -= damage_taken
	
	if current_health < 0:
		current_health = 0
	
	on_health_change.emit(current_health)
		
func increase_health(heal_value : int):
	current_health += heal_value
	
	if current_health > max_health:
		current_health = max_health
	
	on_health_change.emit(current_health)
