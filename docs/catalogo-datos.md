# Catálogo de datos por tipo de obra

Este documento es el contenido de las tablas `CFG_TIPO_DATO_*`. Se siembra desde
`db/seeds/002_tipos_dato.sql`.

**Es el documento de diseño más importante del proyecto.** El diagrama ER de un
EAV es engañosamente pequeño —salen unas pocas cajas y parece que ya está— pero
el esquema real del dominio (qué tiene una película, qué tiene un libro) no
aparece en ningún diagrama, porque son *filas* de estas tablas. Está aquí.

---

## Tipos de dato disponibles

`CFG_TIPO_DATO_*.tipo_dato` toma uno de estos valores, y cada uno se guarda en
una columna concreta de `DAT_DATO_*`:

| tipo_dato | Columna en `DAT_DATO_*` |
|---|---|
| `TEXTO` / `TEXTO_LARGO` | `valor_texto` |
| `ENTERO` | `valor_entero` |
| `DECIMAL` | `valor_decimal` |
| `FECHA` | `valor_fecha` |
| `BOOL` | `valor_bool` |
| `OPCION` | `valor_opcion_id` → `CFG_OPCION_DATO_*` |
| `IDIOMA` | `valor_idioma_id` → `CFG_IDIOMA` |
| `PAIS` | `valor_pais_id` → `CFG_PAIS` |

---

## Qué NO va en estos catálogos

Lo que se mete aquí por inercia y no debe estar:

- **`titulo`, `anio`, `portada`** → están en `DAT_OBRA`. Duplicarlos aquí crea dos verdades.
- **`autor`, `director`, `reparto`, `guionista`** → `DAT_PERSONA_OBRA`, con su rol. Nunca como texto.
- **`isbn`, `id_tmdb`, `id_imdb`** → `DAT_ID_EXTERNO_OBRA`. Necesitan índice único, imposible como atributo EAV.
- **`saga`, `num_volumen`** → `DAT_COLECCION` y el campo `orden` del cruce.
- **`num_temporadas`, `num_episodios`, `nota_media`** → son **derivados**. Se calculan con `COUNT`/`AVG`. Almacenarlos garantiza que algún día se desincronicen.

---

## `CFG_TIPO_DATO_LIBRO`

| código | tipo | múlt. | oblig. | notas |
|---|---|:--:|:--:|---|
| `sinopsis` | TEXTO_LARGO | no | no | |
| `genero` | OPCION | **sí** | no | |
| `idioma_original` | IDIOMA | no | sí | |
| `num_paginas` | ENTERO | no | no | unidad: páginas — ver «ediciones» en decisiones-diseno.md |
| `fecha_publicacion` | FECHA | no | no | primera edición |
| `tipo_narrativo` | OPCION | no | no | novela, ensayo, poesía, cómic, manga, relato |
| `es_ficcion` | BOOL | no | no | separa ficción de no ficción en los filtros |
| `publico` | OPCION | no | no | infantil, juvenil, adulto |
| `titulo_original` | TEXTO | no | no | |
| `pais_publicacion` | PAIS | no | no | |
| `contenido_sensible` | OPCION | **sí** | no | opcional; es lo que diferencia a StoryGraph |

## `CFG_TIPO_DATO_PELICULA`

| código | tipo | múlt. | oblig. | notas |
|---|---|:--:|:--:|---|
| `sinopsis` | TEXTO_LARGO | no | no | |
| `genero` | OPCION | **sí** | no | |
| `idioma_original` | IDIOMA | no | sí | |
| `pais_produccion` | PAIS | **sí** | no | las coproducciones son la norma |
| `duracion` | ENTERO | no | no | unidad: minutos |
| `fecha_estreno` | FECHA | no | no | |
| `clasificacion_edad` | OPCION | no | no | valor normalizado propio, no por país |
| `titulo_original` | TEXTO | no | no | |
| `eslogan` | TEXTO | no | no | el *tagline* |
| `presupuesto` | DECIMAL | no | no | unidad: USD |
| `recaudacion` | DECIMAL | no | no | unidad: USD |
| `color` | OPCION | no | no | color, b/n, mixto |

## `CFG_TIPO_DATO_SERIE`

| código | tipo | múlt. | oblig. | notas |
|---|---|:--:|:--:|---|
| `sinopsis` | TEXTO_LARGO | no | no | |
| `genero` | OPCION | **sí** | no | |
| `idioma_original` | IDIOMA | no | sí | |
| `pais_produccion` | PAIS | **sí** | no | |
| `estado` | OPCION | no | sí | en emisión, finalizada, cancelada, en pausa |
| `fecha_inicio` | FECHA | no | no | |
| `fecha_fin` | FECHA | no | no | nulo si sigue en emisión |
| `tipo_serie` | OPCION | no | no | serie, miniserie, antología, documental |
| `duracion_media` | ENTERO | no | no | unidad: minutos |
| `clasificacion_edad` | OPCION | no | no | |
| `titulo_original` | TEXTO | no | no | |

`estado` es más importante de lo que parece: es lo que permite «series que sigo y
tienen episodio nuevo», la funcionalidad que engancha en la parte de series.

## `CFG_TIPO_DATO_EPISODIO`

| código | tipo | múlt. | oblig. | notas |
|---|---|:--:|:--:|---|
| `sinopsis` | TEXTO_LARGO | no | no | |
| `duracion` | ENTERO | no | no | unidad: minutos |
| `fecha_emision` | FECHA | no | no | |
| `numero_absoluto` | ENTERO | no | no | numeración continua entre temporadas |

`DAT_TEMPORADA` no tiene EAV a propósito: sus campos son fijos y no varían.

---

## Vocabularios (`CFG_OPCION_DATO_*`)

**Géneros de libro:** fantasía, ciencia ficción, misterio, thriller, romance,
terror, histórica, contemporánea, biografía, ensayo, autoayuda, divulgación,
poesía, infantil.

**Géneros de película y serie:** acción, aventura, animación, comedia, crimen,
documental, drama, familiar, fantasía, terror, musical, misterio, romance,
ciencia ficción, thriller, bélica, western.

**Clasificación por edades:** `TP`, `+7`, `+12`, `+16`, `+18`. Valor normalizado
propio; replicar PEGI, MPAA e ICAA por separado no compensa.

---

## Códigos compartidos entre tipos

Cuando el concepto es el mismo, el `codigo` debe ser **idéntico** en los tres
catálogos: `sinopsis`, `genero`, `idioma_original`, `titulo_original`,
`clasificacion_edad`.

Aunque vivan en tablas distintas, así la API y el frontend pueden tratarlos de
forma uniforme y se evita un `switch` por tipo de obra en cada componente.
