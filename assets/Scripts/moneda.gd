extends Area2D

signal recogida


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(cuerpo: Node2D) -> void:
	if not cuerpo.is_in_group("jugador"):
		return
	cuerpo.monedas += 1
	recogida.emit()
	queue_free()
