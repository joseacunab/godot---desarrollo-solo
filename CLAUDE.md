# CLAUDE.md

Guía del proyecto **"Juego desarrollado solo"** para Claude Code.

## El juego

Plataformero 2D hecho en **Godot 4** (`config/features = "4.7", "Forward Plus"`).

- **Protagonista:** un explorador. Animaciones `respirar` (reposo), `caminar`, `saltar` y `recoger`.
- **Enemigos:** slimes y murciélagos.
- **Objetos:** monedas giratorias para recoger.
- **Nivel:** la selva, en `assets/escenario/nivel_selva.tscn` (escenario de 1408×768 px).

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
    │   ├── principal.tscn        # Escena principal: nivel + jugador
    │   ├── jugador.tscn          # Escena del explorador
    │   └── mapa.tscn             # Mapa de prueba antiguo (no se usa)
    ├── Scripts/
    │   ├── principal.gd          # Coloca al jugador en su marcador
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
├── NivelSelva   instancia de nivel_selva.tscn
└── Jugador      instancia de jugador.tscn
```
`principal.gd` coloca al jugador en el marcador `NivelSelva/Marcadores/Jugador` en `_ready()`. El marcador indica dónde van los **pies**: se resta la distancia del centro a la base de la colisión para que no aparezca enterrado en el suelo.

### `assets/Escenas/jugador.tscn` — el explorador
```
jugador (CharacterBody2D, jugador.gd)
├── Sprite2D (AnimatedSprite2D)   escala 0.6, autoplay "respirar"
├── CollisionShape2D              CapsuleShape2D r=26, h=88
└── Camera2D                      límites 0,0 → 1408×768
```
- SpriteFrames embebido: `caminar` (9 frames, 10 fps), `recoger` (7, 10 fps), `respirar` (5, 5 fps), `saltar` (9, 10 fps). Todas en bucle.
- El script `jugador.gd` está asignado en la raíz de esta escena.

### `assets/Scripts/jugador.gd`
- `extends CharacterBody2D`; `SPEED = 300.0`, `JUMP_VELOCITY = -400.0`.
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
Los marcadores sólo guardan posiciones. `principal.gd` usa el de `Jugador`; todavía no hay código que instancie enemigos ni monedas.

## Estado actual y problemas conocidos

- `mapa.tscn` no se usa en ninguna parte. Sus `CollisionShape2D` cuelgan de un `Node2D` y no de un `StaticBody2D`, así que no generan colisión. Las colisiones válidas están en `nivel_selva.tscn`.
- **Murciélagos:** sólo existen los marcadores en `nivel_selva.tscn`; no hay sprites ni escenas.
- **Slimes y monedas:** hay sprites y `SpriteFrames`, pero no escenas ni scripts (sin IA, sin recogida, sin contador).
- Nombres de carpetas con mayúsculas y espacios (`Personaje principal`); cuidado al escribir rutas `res://`.

## Convenciones

- Escenas en `assets/Escenas/`, scripts en `assets/Scripts/`, arte agrupado por entidad.
- Nombres de animación en español e infinitivo: `respirar`, `caminar`, `saltar`, `recoger`, `girar`.
- Editar `.tscn`/`.tres` a mano es posible, pero conserva los `uid` y las rutas `res://` exactas.
