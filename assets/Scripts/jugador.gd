extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -550.0

const REBOTE_VELOCITY = -400.0

signal vidas_cambiadas(vidas: int)
signal monedas_cambiadas(monedas: int)

var vidas := 3:
	set(valor):
		vidas = valor
		vidas_cambiadas.emit(vidas)

var monedas := 0:
	set(valor):
		monedas = valor
		monedas_cambiadas.emit(monedas)

@onready var anim = $Sprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
 

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		anim.flip_h = direction<0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
 

	move_and_slide()
	if not is_on_floor() && velocity.y<0:
		anim.play("saltar")
	elif direction != 0:
		anim.play("caminar")
	else:
		anim.play("respirar")


# Altura global de la base de la colisión (los pies).
func pies_y() -> float:
	var colision: CollisionShape2D = $CollisionShape2D
	return colision.global_position.y + colision.shape.get_rect().end.y


# Impulso hacia arriba al aplastar a un enemigo.
func rebotar() -> void:
	velocity.y = REBOTE_VELOCITY
