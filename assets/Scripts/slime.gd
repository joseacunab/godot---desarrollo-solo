extends CharacterBody2D

# Se emite cuando el slime toca al jugador de costado.
signal jugador_golpeado

const VELOCIDAD = 60.0

var direccion := -1.0

@onready var cuerpo: CollisionShape2D = $CollisionShape2D
@onready var detector_borde: RayCast2D = $DetectorBorde
@onready var deteccion: Area2D = $Deteccion


func _ready() -> void:
	deteccion.body_entered.connect(_on_deteccion_body_entered)
	_actualizar_detector()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = direccion * VELOCIDAD
	move_and_slide()

	# Da la vuelta al chocar con una pared o al llegar al borde de la plataforma.
	if is_on_wall() or (is_on_floor() and not detector_borde.is_colliding()):
		direccion = -direccion
		_actualizar_detector()


func _actualizar_detector() -> void:
	# El rayo mira hacia abajo justo delante del slime, en el sentido de la marcha.
	var medio_ancho: float = cuerpo.shape.get_rect().size.x / 2.0
	detector_borde.position.x = direccion * (medio_ancho + 4.0)


func _on_deteccion_body_entered(otro: Node2D) -> void:
	if not otro.is_in_group("jugador"):
		return
	# Si el jugador cae y sus pies están por encima del centro del slime, lo aplasta.
	var centro_y := cuerpo.global_position.y
	if otro.velocity.y > 0.0 and otro.pies_y() < centro_y:
		otro.rebotar()
		queue_free()
	else:
		jugador_golpeado.emit()
