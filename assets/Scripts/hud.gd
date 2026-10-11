extends CanvasLayer

@onready var etiqueta_vidas: Label = $Vidas


# Muestra las vidas del jugador y se actualiza cada vez que cambian.
func seguir_jugador(jugador: CharacterBody2D) -> void:
	jugador.vidas_cambiadas.connect(_on_vidas_cambiadas)
	_on_vidas_cambiadas(jugador.vidas)


func _on_vidas_cambiadas(vidas: int) -> void:
	etiqueta_vidas.text = "Vidas: %d" % vidas
