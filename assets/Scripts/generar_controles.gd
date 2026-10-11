# Genera las texturas de los controles táctiles en assets/ControlesTactiles/.
# Uso (desde la carpeta del proyecto):
#   Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://assets/Scripts/generar_controles.gd
extends SceneTree

const CARPETA = "res://assets/ControlesTactiles/"
const TAM = 160  # Lado de cada botón en píxeles.


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARPETA))
	# Triángulos de la flecha, en coordenadas relativas al centro (radio = 1).
	var izquierda := PackedVector2Array([Vector2(-0.45, 0), Vector2(0.3, -0.42), Vector2(0.3, 0.42)])
	var derecha := PackedVector2Array([Vector2(0.45, 0), Vector2(-0.3, -0.42), Vector2(-0.3, 0.42)])
	var arriba := PackedVector2Array([Vector2(0, -0.45), Vector2(0.42, 0.3), Vector2(-0.42, 0.3)])
	for nombre in ["izquierda", "derecha", "saltar"]:
		var flecha: PackedVector2Array = {"izquierda": izquierda, "derecha": derecha, "saltar": arriba}[nombre]
		guardar(dibujar(flecha, false), "boton_%s.png" % nombre)
		guardar(dibujar(flecha, true), "boton_%s_pulsado.png" % nombre)
	quit()


# Círculo blanco semitransparente con borde y una flecha. Pulsado = más opaco.
func dibujar(flecha: PackedVector2Array, pulsado: bool) -> Image:
	var img := Image.create(TAM, TAM, false, Image.FORMAT_RGBA8)
	var centro := Vector2(TAM, TAM) / 2.0
	var radio := TAM / 2.0 - 2.0
	var a_relleno := 0.45 if pulsado else 0.22
	var a_borde := 0.85 if pulsado else 0.55
	var a_flecha := 0.95 if pulsado else 0.7
	for y in TAM:
		for x in TAM:
			var p := Vector2(x + 0.5, y + 0.5)
			var d := p.distance_to(centro)
			var alfa := 0.0
			if d <= radio:
				alfa = a_relleno
				if d > radio - 6.0:
					alfa = a_borde
				if Geometry2D.is_point_in_polygon((p - centro) / radio, flecha):
					alfa = a_flecha
				# Suavizado del contorno exterior.
				alfa *= clampf(radio - d + 0.5, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, alfa))
	return img


func guardar(img: Image, archivo: String) -> void:
	var error := img.save_png(ProjectSettings.globalize_path(CARPETA + archivo))
	print(CARPETA + archivo, " error=", error)
