extends Area2D

# Se emite una sola vez, cuando el jugador toca la meta.
signal alcanzada

var alcanzada_ya := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(cuerpo: Node2D) -> void:
	if alcanzada_ya or not cuerpo.is_in_group("jugador"):
		return
	alcanzada_ya = true
	alcanzada.emit()
