# CLAUDE.md

Guía del proyecto **"Juego desarrollado solo"** para Claude Code.

## El juego

Plataformero 2D hecho en **Godot 4** (`config/features = "4.7", "Forward Plus"`).

- **Protagonista:** un explorador. Animaciones `respirar` (reposo), `caminar`, `saltar` y `recoger`.
- **Enemigos:** slimes y murciélagos.
- **Objetos:** monedas giratorias para recoger.
- **Nivel:** `assets/Escenas/nivel_largo.tscn` (6400×768 px, TileMapLayer). El antiguo `assets/escenario/nivel_selva.tscn` (1408×768) ya no se usa. Debajo tiene `ZonaMuerte` (Area2D de x 0–6400, y 800–1200).

Todo el proyecto (nombres de nodos, carpetas, animaciones, comentarios) está en **español**; mantén esa convención.

## Configuración (`project.godot`)

- Estiramiento: `canvas_items` / `expand`.
- Filtro de texturas por defecto: `0` (Nearest, pixel art).
- Física 3D: Jolt (no afecta al 2D). Renderizador en Windows: D3D12.
- Escena principal (`run/main_scene`): `res://assets/Escenas/principal.tscn`.
- No hay acciones de input propias: el jugador usa `ui_left`, `ui_right` y `ui_accept`.
- `.editorconfig`: UTF-8. `.gitattributes`: finales de línea LF. `.gitignore` excluye `.godot/` y `/android/`.

## Estructura de carpetas

```
res://
├── project.godot
├── icon.svg
└── assets/
    ├── Escenas/
    │   ├── principal.tscn        # Escena principal: nivel largo + jugador
    │   ├── nivel_largo.tscn      # Nivel actual (6400×768)
    │   ├── jugador.tscn          # Escena del explorador
    │   ├── hud.tscn              # HUD (CanvasLayer): vidas y monedas
    │   ├── moneda.tscn           # Area2D, se recoge al tocarla
    │   └── slime.tscn            # CharacterBody2D que patrulla
    ├── Scripts/
    │   ├── principal.gd          # Coloca al jugador, vidas, zona de muerte, instancia monedas y slimes
    │   ├── hud.gd                # Muestra vidas y monedas (señales vidas_cambiadas / monedas_cambiadas)
    │   ├── moneda.gd             # Suma 1 a jugador.monedas y desaparece
    │   ├── slime.gd              # Patrulla; golpe de costado o aplastamiento
    │   └── jugador.gd            # Movimiento y animación del jugador
    ├── Personaje principal/      # Sprites del explorador
    │   ├── respirar/  respirar_00..04.png   + respirar_strip.png
    │   ├── caminar/   caminar_00..08.png    + caminar_strip.png
    │   ├── saltar/    saltar_00..08.png     + saltar_strip.png
    │   ├── recoger/   recoger_00..06.png    + recoger_strip.png
    │   └── personaje_frames.tres            # SpriteFrames (no usado por jugador.tscn)
    ├── Enemigo/                  # Slime
    │   ├── respirar/  slime_respirar_00..02.png
    │   ├── slime_respirar_strip.png
    │   └── slime_frames.tres
    ├── Moneda/
    │   ├── girar/     moneda_00..07.png
    │   ├── moneda_girar_strip.png
    │   └── moneda_frames.tres
    └── escenario/
        ├── escenario_selva.png       # Fondo del nivel (1408×768)
        ├── colisiones_preview.png    # Referencia visual de las colisiones
        └── nivel_selva.tscn          # Nivel de la selva
```

Cada animación existe dos veces: como frames sueltos (`<anim>/<anim>_NN.png`) y como tira horizontal (`<anim>_strip.png`). `jugador.tscn` usa las **tiras** recortadas con `AtlasTexture`; los `.tres` usan los frames sueltos.

## Escenas

### `assets/Escenas/principal.tscn` — escena principal
```
Principal (Node2D, principal.gd)
├── NivelLargo   instancia de nivel_largo.tscn
├── Monedas      Node2D: una moneda.tscn por marcador de NivelLargo/Marcadores/Monedas
├── Slimes       Node2D: un slime.tscn por marcador de NivelLargo/Marcadores/Slimes
├── Jugador      instancia de jugador.tscn
└── HUD          instancia de hud.tscn (CanvasLayer, fijo en pantalla)
```
`principal.gd` coloca al jugador en el marcador `NivelLargo/Marcadores/Jugador` en `_ready()`. El marcador indica dónde van los **pies**: se resta la distancia del centro a la base de la colisión para que no aparezca enterrado en el suelo.

Vidas: `jugador.gd` tiene `var vidas := 3`. `principal.gd` llama a `perder_vida()` al entrar en `NivelLargo/ZonaMuerte` o cuando un slime emite `jugador_golpeado`: resta una vida, hace al jugador invencible (`volverse_invencible()`) y llama a `colocar_jugador()` (marcador + velocidad a cero); si llega a 0 hace `reload_current_scene()`. La zona de muerte quita vida aunque el jugador sea invencible.

Monedas y slimes: las instancias toman el nombre de su marcador (`Moneda1`, `Slime1`...). El marcador de moneda es su centro; el de slime, sus pies (el origen de `slime.tscn` está en la base). Cada slime tiene una excepción de colisión con el jugador: no se empujan, el contacto lo detecta el `Area2D` `Deteccion` del slime.

### `assets/Escenas/moneda.tscn` y `assets/Escenas/slime.tscn`
- **Moneda** (Area2D, `moneda.gd`): `AnimatedSprite2D` con `moneda_frames.tres`, animación `girar`, escala 0.25; `CircleShape2D` r=18. Cuando la toca un cuerpo del grupo `jugador`, suma 1 a `monedas` y hace `queue_free()`.
- **Slime** (CharacterBody2D, `slime.gd`, capa de colisión 3 = valor 4, máscara 1): `slime_frames.tres` (`respirar`), escala 0.45, colisión 76×46. Tiene gravedad y `VELOCIDAD = 60`; da la vuelta con `is_on_wall()` o cuando el `RayCast2D` `DetectorBorde` (delante y hacia abajo) deja de tocar suelo. En cada frame revisa los cuerpos dentro de `Deteccion` (no usa `body_entered`, para golpear también si el jugador sigue encima al acabar su invencibilidad). Si el jugador está cayendo (`velocity.y > 0`) con los pies (`pies_y()`) por encima del centro del slime, el jugador llama a `rebotar()` y el slime muere; si no, y el jugador no es invencible, emite `jugador_golpeado`. Aplastar funciona aunque el jugador sea invencible.

### `assets/Escenas/jugador.tscn` — el explorador
```
jugador (CharacterBody2D, jugador.gd)
├── Sprite2D (AnimatedSprite2D)   escala 0.6, autoplay "respirar"
├── CollisionShape2D              CapsuleShape2D r=26, h=88
└── Camera2D                      límites 0,0 → 6400×768
```
- SpriteFrames embebido: `caminar` (9 frames, 10 fps), `recoger` (7, 10 fps), `respirar` (5, 5 fps), `saltar` (9, 10 fps). Todas en bucle.
- El script `jugador.gd` está asignado en la raíz de esta escena.

### `assets/Scripts/jugador.gd`
- `extends CharacterBody2D`; `SPEED = 300.0`, `JUMP_VELOCITY = -550.0`.
- `var vidas := 3` y `var monedas := 0`, con setters que emiten `vidas_cambiadas` y `monedas_cambiadas`; las vidas las gestiona `principal.gd` y ambas las muestra el HUD (`hud.seguir_jugador(jugador)`).
- Raíz en el grupo `jugador`. `pies_y()` devuelve la altura global de la base de la colisión; `rebotar()` pone `velocity.y = REBOTE_VELOCITY` (-400).
- Invencibilidad: `volverse_invencible()` da `TIEMPO_INVENCIBLE` (1,5 s) y `es_invencible()` lo consulta. Mientras dura, el sprite parpadea alternando `visible` cada `PERIODO_PARPADEO / 2` (0,1 s).
- Gravedad con `get_gravity()`, salto con `ui_accept` sólo en el suelo, voltea el sprite con `flip_h`.
- Animación: `saltar` si sube en el aire, `caminar` si hay dirección, si no `respirar`. `recoger` todavía no se usa.
- El nodo de animación se llama `Sprite2D` aunque es un `AnimatedSprite2D` (`@onready var anim = $Sprite2D`).

### `assets/Escenas/mapa.tscn` — mapa de prueba antiguo (no se usa)
```
mapa (Node2D)
├── TileMapLayer          TileSet con escenario_selva.png como atlas (tiles 16×16, 88×48)
├── jugador               instancia de jugador.tscn + script jugador.gd
├── piso (CollisionShape2D)
│   └── escalera 1 → escalera 2 → escalera 3   (CollisionShape2D anidados)
└── piso 2 (CollisionShape2D)
```

### `assets/escenario/nivel_selva.tscn` — nivel de la selva
```
NivelSelva (Node2D)
├── Fondo (Sprite2D)            escenario_selva.png, centered=false
├── Colisiones (StaticBody2D)   16 CollisionShape2D rectangulares:
│     SueloArribaIzq, PuenteArriba*, PiedraMedio, Escalon1-3, SueloArribaDer,
│     ColumnaIzq, ColumnaDer, RepisaAbajoIzq, SueloAbajoIzq, PuenteAbajo*,
│     SueloAbajoDer, RepisaAbajoDer, ParedIzq, ParedDer   (* = one_way_collision)
└── Marcadores (Node2D)         Marker2D con posiciones de aparición:
      Jugador (480,460)
      Slime1 (1112,377), Slime2 (1012,703)
      Murcielago1 (1246,218), Murcielago2 (1342,532)
      Monedas/ Moneda1..Moneda14
```
Los marcadores sólo guardan posiciones. Este nivel ya no se usa: `principal.gd` lee los marcadores `Jugador`, `Monedas` y `Slimes` de `nivel_largo.tscn`.

## Estado actual y problemas conocidos

- `mapa.tscn` no se usa en ninguna parte. Sus `CollisionShape2D` cuelgan de un `Node2D` y no de un `StaticBody2D`, así que no generan colisión. Las colisiones válidas están en `nivel_selva.tscn`.
- **Murciélagos:** sólo existen los marcadores en `nivel_selva.tscn`; no hay sprites ni escenas.
- **Slimes:** el sprite es frontal, así que no se voltea al cambiar de sentido. `Slime1` está en (1500, 640) y patrulla entre x 1129 y 1500, lejos del punto de aparición.
- Nombres de carpetas con mayúsculas y espacios (`Personaje principal`); cuidado al escribir rutas `res://`.

## Convenciones

- Escenas en `assets/Escenas/`, scripts en `assets/Scripts/`, arte agrupado por entidad.
- Nombres de animación en español e infinitivo: `respirar`, `caminar`, `saltar`, `recoger`, `girar`.
- Editar `.tscn`/`.tres` a mano es posible, pero conserva los `uid` y las rutas `res://` exactas.

## Flujo de trabajo

- **Commit automático:** al terminar cada tarea y comprobar que funciona, haz commit sin esperar a que se pida. Incluye los archivos que genera Godot y que acompañan a los cambios (`*.uid`, `*.import`). Si la tarea no funciona o la prueba falla, no hagas commit: explica el problema.
- Para probar, usa Godot sin ventana: `C:\Users\Administrador\Downloads\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script <prueba.gd>` (antes, `--import` si hay archivos nuevos). Guarda los scripts de prueba fuera del proyecto.
