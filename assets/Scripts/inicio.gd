extends Node2D

const ESCENA_NIVEL = "res://assets/Escenas/principal.tscn"

@onready var boton_jugar: Button = $Interfaz/Centro/Caja/Jugar


func _ready() -> void:
	boton_jugar.pressed.connect(_on_jugar_pressed)
	# Con el foco en el botón, Enter (ui_accept) lo pulsa.
	boton_jugar.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	# Por si el botón ha perdido el foco (p. ej. tras un clic fuera), Enter sigue funcionando.
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_on_jugar_pressed()


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_NIVEL)
