extends Node2D

@onready var jugador: CharacterBody2D = $Jugador
@onready var marcador: Marker2D = $NivelSelva/Marcadores/Jugador


func _ready() -> void:
	# El marcador indica dónde van los pies: subimos al jugador lo que mide
	# desde su centro hasta la base de su colisión para no enterrarlo en el suelo.
	var colision: CollisionShape2D = jugador.get_node("CollisionShape2D")
	var pies := colision.position.y + colision.shape.get_rect().end.y
	jugador.global_position = marcador.global_position - Vector2(0, pies)
