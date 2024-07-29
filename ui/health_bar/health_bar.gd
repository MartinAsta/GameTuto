extends Node2D

@onready var heart_1 = $Heart1
@onready var heart_2 = $Heart2
@onready var heart_3 = $Heart3

@export var heart2 : Texture2D
@export var heart1 : Texture2D
@export var heart0 : Texture2D

func _ready():
	HealthManager.on_health_change.connect(on_player_health_changed)
	
func on_player_health_changed(player_current_health : int):
	if player_current_health == 6:
		heart_3.texture = heart2
		heart_2.texture = heart2
		heart_1.texture = heart2
	elif player_current_health == 5:
		heart_3.texture = heart1
		heart_2.texture = heart2
		heart_1.texture = heart2
	elif player_current_health == 4:
		heart_3.texture = heart0
		heart_2.texture = heart2
		heart_1.texture = heart2
	elif player_current_health == 3:
		heart_3.texture = heart0
		heart_2.texture = heart1
		heart_1.texture = heart2
	elif player_current_health == 2:
		heart_3.texture = heart0
		heart_2.texture = heart0
		heart_1.texture = heart2
	elif player_current_health == 1:
		heart_3.texture = heart0
		heart_2.texture = heart0
		heart_1.texture = heart1
	elif player_current_health == 0:
		heart_3.texture = heart0
		heart_2.texture = heart0
		heart_1.texture = heart0
