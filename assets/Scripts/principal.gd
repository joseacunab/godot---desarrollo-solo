extends Node2D

const ESCENA_MONEDA = preload("res://assets/Escenas/moneda.tscn")
const ESCENA_SLIME = preload("res://assets/Escenas/slime.tscn")

@onready var jugador: CharacterBody2D = $Jugador
@onready var marcador: Marker2D = $NivelLargo/Marcadores/Jugador
@onready var zona_muerte: Area2D = $NivelLargo/ZonaMuerte
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	zona_muerte.body_entered.connect(_on_zona_muerte_body_entered)
	hud.seguir_jugador(jugador)
	colocar_jugador()
	crear_monedas()
	crear_slimes()


func colocar_jugador() -> void:
	# El marcador indica dónde van los pies: subimos al jugador lo que mide
	# desde su centro hasta la base de su colisión para no enterrarlo en el suelo.
	var colision: CollisionShape2D = jugador.get_node("CollisionShape2D")
	var pies := colision.position.y + colision.shape.get_rect().end.y
	jugador.global_position = marcador.global_position - Vector2(0, pies)
	jugador.velocity = Vector2.ZERO


# Una moneda en cada marcador de NivelLargo/Marcadores/Monedas (centro de la moneda).
func crear_monedas() -> void:
	for m: Marker2D in $NivelLargo/Marcadores/Monedas.get_children():
		var moneda := ESCENA_MONEDA.instantiate()
		moneda.name = m.name
		moneda.position = m.global_position
		$Monedas.add_child(moneda)


# Un slime en cada marcador de NivelLargo/Marcadores/Slimes (los pies del slime).
func crear_slimes() -> void:
	for m: Marker2D in $NivelLargo/Marcadores/Slimes.get_children():
		var slime := ESCENA_SLIME.instantiate()
		slime.name = m.name
		slime.position = m.global_position
		# El slime no choca físicamente con el jugador; el contacto lo detecta su Area2D.
		slime.add_collision_exception_with(jugador)
		slime.jugador_golpeado.connect(perder_vida)
		$Slimes.add_child(slime)


func perder_vida() -> void:
	jugador.vidas -= 1
	if jugador.vidas <= 0:
		# Sin vidas: se reinicia el nivel (diferido, estamos en un callback de física).
		get_tree().reload_current_scene.call_deferred()
	else:
		# Invencible desde ya, para que otro slime no lo golpee en este mismo frame.
		jugador.volverse_invencible()
		colocar_jugador.call_deferred()


func _on_zona_muerte_body_entered(cuerpo: Node2D) -> void:
	if cuerpo == jugador:
		perder_vida()
