extends CanvasLayer

@onready var etiqueta_vidas: Label = $Vidas
@onready var etiqueta_monedas: Label = $Monedas
@onready var pantalla_final: ColorRect = $NivelCompletado
@onready var etiqueta_monedas_final: Label = $NivelCompletado/Centro/Caja/MonedasFinal
@onready var boton_volver: Button = $NivelCompletado/Centro/Caja/VolverAJugar


func _ready() -> void:
	boton_volver.pressed.connect(_on_volver_a_jugar_pressed)


# Muestra las vidas y monedas del jugador y se actualiza cada vez que cambian.
func seguir_jugador(jugador: CharacterBody2D) -> void:
	jugador.vidas_cambiadas.connect(_on_vidas_cambiadas)
	jugador.monedas_cambiadas.connect(_on_monedas_cambiadas)
	_on_vidas_cambiadas(jugador.vidas)
	_on_monedas_cambiadas(jugador.monedas)


func _on_vidas_cambiadas(vidas: int) -> void:
	etiqueta_vidas.text = "Vidas: %d" % vidas


func _on_monedas_cambiadas(monedas: int) -> void:
	etiqueta_monedas.text = "Monedas: %d" % monedas


# El HUD tiene process_mode = Always, así que el botón funciona con el juego en pausa.
func mostrar_nivel_completado(monedas: int, total: int) -> void:
	etiqueta_monedas_final.text = "Monedas: %d / %d" % [monedas, total]
	pantalla_final.show()
	boton_volver.grab_focus()


func _on_volver_a_jugar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
