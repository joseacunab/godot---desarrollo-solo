extends CanvasLayer

# Botones táctiles: disparan las mismas acciones que el teclado
# (ui_left, ui_right, ui_accept) mediante la propiedad `action`.

const MARGEN = 32.0
const SEPARACION = 24.0

@onready var izquierda: TouchScreenButton = $Izquierda
@onready var derecha: TouchScreenButton = $Derecha
@onready var saltar: TouchScreenButton = $Saltar


func _ready() -> void:
	# Sólo en pantallas táctiles.
	visible = DisplayServer.is_touchscreen_available()
	get_viewport().size_changed.connect(_colocar)
	_colocar()


# Esquinas inferiores del área visible, que cambia con el tamaño de la pantalla.
func _colocar() -> void:
	var pantalla := get_viewport().get_visible_rect().size
	var lado := izquierda.texture_normal.get_size().x
	var y := pantalla.y - MARGEN - lado
	izquierda.position = Vector2(MARGEN, y)
	derecha.position = Vector2(MARGEN + lado + SEPARACION, y)
	saltar.position = Vector2(pantalla.x - MARGEN - lado, y)
