extends CanvasLayer

@onready var etiqueta_vidas: Label = $Vidas
@onready var etiqueta_monedas: Label = $Monedas


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
