# Genera los efectos de sonido retro (8 bits) en assets/Sonidos/.
# Uso (desde la carpeta del proyecto):
#   Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://assets/Scripts/generar_sonidos.gd
extends SceneTree

const FRECUENCIA_MUESTREO = 22050
const CARPETA = "res://assets/Sonidos/"
const VOLUMEN = 0.45  # Pico de la onda (0..1).


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARPETA))
	guardar("saltar", barrido(0.16, 260.0, 720.0, 0.5))
	guardar("moneda", notas([[988.0, 0.06], [1319.0, 0.22]], 0.5))
	guardar("golpe", mezclar(barrido(0.32, 420.0, 90.0, 0.25), ruido(0.32, 0.35)))
	guardar("aplastar", mezclar(barrido(0.12, 220.0, 70.0, 0.5), ruido(0.08, 0.6)))
	guardar("caer", barrido(0.8, 900.0, 110.0, 0.5, 7.0))
	guardar("meta", notas([[523.0, 0.1], [659.0, 0.1], [784.0, 0.1], [1047.0, 0.45]], 0.25))
	quit()


# Onda cuadrada cuya frecuencia va de f_ini a f_fin, con caída de volumen
# y vibrato opcional (en Hz).
func barrido(duracion: float, f_ini: float, f_fin: float, ciclo: float, vibrato := 0.0) -> PackedFloat32Array:
	var n := int(duracion * FRECUENCIA_MUESTREO)
	var muestras := PackedFloat32Array()
	muestras.resize(n)
	var fase := 0.0
	for i in n:
		var t := float(i) / n
		var f := lerpf(f_ini, f_fin, t)
		if vibrato > 0.0:
			f *= 1.0 + 0.06 * sin(TAU * vibrato * i / FRECUENCIA_MUESTREO)
		fase = fmod(fase + f / FRECUENCIA_MUESTREO, 1.0)
		muestras[i] = (1.0 if fase < ciclo else -1.0) * (1.0 - t)
	return muestras


# Secuencia de notas cuadradas [[frecuencia, duración], ...]; cada una decae.
func notas(lista: Array, ciclo: float) -> PackedFloat32Array:
	var muestras := PackedFloat32Array()
	for nota in lista:
		var n := int(nota[1] * FRECUENCIA_MUESTREO)
		var fase := 0.0
		for i in n:
			fase = fmod(fase + nota[0] / FRECUENCIA_MUESTREO, 1.0)
			muestras.append((1.0 if fase < ciclo else -1.0) * (1.0 - 0.7 * float(i) / n))
	return muestras


# Ruido blanco "a saltos" (como el canal de ruido de una consola de 8 bits).
func ruido(duracion: float, intensidad: float) -> PackedFloat32Array:
	var n := int(duracion * FRECUENCIA_MUESTREO)
	var muestras := PackedFloat32Array()
	muestras.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 8  # Siempre el mismo resultado.
	var valor := 0.0
	for i in n:
		if i % 8 == 0:
			valor = rng.randf_range(-1.0, 1.0)
		muestras[i] = valor * intensidad * (1.0 - float(i) / n)
	return muestras


func mezclar(a: PackedFloat32Array, b: PackedFloat32Array) -> PackedFloat32Array:
	var salida := PackedFloat32Array()
	salida.resize(max(a.size(), b.size()))
	for i in salida.size():
		var va := a[i] if i < a.size() else 0.0
		var vb := b[i] if i < b.size() else 0.0
		salida[i] = clampf(va + vb, -1.0, 1.0)
	return salida


func guardar(nombre: String, muestras: PackedFloat32Array) -> void:
	# Fundidos de 3 ms al principio y al final para evitar chasquidos.
	var fundido := int(0.003 * FRECUENCIA_MUESTREO)
	var datos := PackedByteArray()
	datos.resize(muestras.size() * 2)
	for i in muestras.size():
		var g := minf(1.0, minf(float(i) / fundido, float(muestras.size() - 1 - i) / fundido))
		datos.encode_s16(i * 2, int(clampf(muestras[i] * g * VOLUMEN, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = FRECUENCIA_MUESTREO
	wav.stereo = false
	wav.data = datos
	var ruta := CARPETA + nombre + ".wav"
	var error := wav.save_to_wav(ProjectSettings.globalize_path(ruta))
	print(ruta, ": ", "%.2f s" % (float(muestras.size()) / FRECUENCIA_MUESTREO), " error=", error)
