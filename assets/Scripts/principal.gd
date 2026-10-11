extends Node2D

@onready var jugador: CharacterBody2D = $Jugador
@onready var marcador: Marker2D = $NivelLargo/Marcadores/Jugador
@onready var zona_muerte: Area2D = $NivelLargo/ZonaMuerte
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	zona_muerte.body_entered.connect(_on_zona_muerte_body_entered)
	hud.seguir_jugador(jugador)
	colocar_jugador()


func colocar_jugador() -> void:
	# El marcador indica dónde van los pies: subimos al jugador lo que mide
	# desde su centro hasta la base de su colisión para no enterrarlo en el suelo.
	var colision: CollisionShape2D = jugador.get_node("CollisionShape2D")
	var pies := colision.position.y + colision.shape.get_rect().end.y
	jugador.global_position = marcador.global_position - Vector2(0, pies)
	jugador.velocity = Vector2.ZERO


func _on_zona_muerte_body_entered(cuerpo: Node2D) -> void:
	if cuerpo != jugador:
		return
	jugador.vidas -= 1
	if jugador.vidas <= 0:
		# Sin vidas: se reinicia el nivel (diferido, estamos en un callback de física).
		get_tree().reload_current_scene.call_deferred()
	else:
		colocar_jugador.call_deferred()
