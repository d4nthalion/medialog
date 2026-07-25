# Decisiones de diseño

Registro de las decisiones estructurales y del motivo de cada una. Sirve para no
volver a discutirlas dentro de seis meses.

---

## 1. PostgreSQL como motor

Un EAV vive de pivotar filas a columnas y de filtrar por atributos concretos.
PostgreSQL da las herramientas que eso necesita y que otros motores no tienen:

- `FILTER`, `LATERAL` y `crosstab()` para pivotar sin `CASE` anidados.
- Índices **parciales** y **de expresión**, imprescindibles para que la tabla de
  valores no se vuelva inmanejable.
- `pg_trgm` para búsqueda difusa de títulos («interestelar» → «Interstellar»).
- `CHECK` y dominios, que devuelven parte de la seguridad de tipos que el EAV quita.
- MVCC real, necesario en cuanto haya usuarios escribiendo a la vez.

Descartados: MySQL (sin índices parciales, pivotar es más verboso), SQLite/D1
(un solo escritor), MongoDB (con modelo documental el EAV sobra, pero se pierde
integridad referencial justo donde más hace falta: el grafo social).

## 2. EAV solo para los metadatos de las obras

El EAV cubre lo que **varía entre tipos de obra**: una película tiene duración y
presupuesto, un libro tiene páginas y editorial.

Todo lo demás —usuarios, reviews, ratings, listas, follows, watchlist— es
relacional puro. Su esquema es fijo y conocido; meterlo en EAV destruiría el
rendimiento sin dar nada a cambio.

## 3. Una tabla de entidad por tipo

`DAT_LIBRO`, `DAT_PELICULA`, `DAT_SERIE` en lugar de una tabla `entidad` única,
y lo mismo para valores (`DAT_DATO_*`) y configuración (`CFG_TIPO_DATO_*`).

**A favor:** índices más selectivos, FKs con tipo real, tablas más pequeñas, el
tipo es implícito en la tabla.

**En contra:** cada tipo nuevo son tres tablas nuevas, y las consultas que cruzan
tipos necesitan `UNION ALL`.

## 4. `DAT_OBRA` como supertipo

Consecuencia directa de la decisión anterior, y la pieza que sostiene todo lo
demás.

Con tres tablas de entidad separadas, una review no tiene a qué apuntar: no
existe FK posible hacia «cualquier obra». `DAT_OBRA` resuelve eso — es una tabla
fina con lo común (título, año, portada), y `DAT_LIBRO` / `DAT_PELICULA` /
`DAT_SERIE` comparten su PK con ella (*class table inheritance*).

Aporta tres cosas:

1. Reviews, ratings y listas tienen **una sola FK** con integridad real.
2. Búsqueda global y feed de actividad sin `UNION ALL` de tres tablas.
3. Lo transversal (ids externos, personas, colecciones) se modela una vez, no tres.

Sin ella, cada tabla del dominio social necesitaría `tipo_obra + obra_id` sin FK
posible: el agujero clásico por el que entran las referencias huérfanas.

## 5. Columnas de valor tipadas, no `text` para todo

`DAT_DATO_*` tiene ocho columnas de valor (`valor_texto`, `valor_entero`,
`valor_decimal`, `valor_fecha`, `valor_bool`, `valor_opcion_id`,
`valor_idioma_id`, `valor_pais_id`) y un `CHECK` que obliga a que exactamente
una sea no nula.

Que ocho de nueve columnas vayan a `NULL` en cada fila no es un desperdicio: en
PostgreSQL los `NULL` se almacenan en un bitmap de la cabecera de fila, ocupan
bits y no bytes.

La alternativa —guardar todo como texto y castear— produce el bug clásico del
EAV: ordenar duraciones alfabéticamente, donde «9» va después de «120».

La otra alternativa —una tabla por tipo de valor— obligaría a un `UNION ALL` en
cada consulta.

## 6. `IDIOMA` y `PAIS` como tipos de dato propios

Podrían ser opciones más dentro de `CFG_OPCION_DATO_*`, pero entonces habría que
sembrar la lista ISO completa una vez por cada tipo de obra. Con columnas
`valor_idioma_id` / `valor_pais_id` apuntando a `CFG_IDIOMA` y `CFG_PAIS` se
siembran una sola vez y la FK es real.

## 7. Las personas son entidades, no texto

Un director no es la cadena `'Christopher Nolan'`, es una fila en `DAT_PERSONA`.

La diferencia práctica: «todas las películas de Nolan» pasa de ser un `LIKE`
sobre texto libre —lento, sensible a erratas, sin página de perfil posible— a un
join indexado por FK.

`DAT_PERSONA` es **una sola tabla** para autores, directores y actores, porque
Cormac McCarthy es autor y guionista, y esa dualidad no debería exigir dos filas.

## 8. `DAT_PERSONA_OBRA` con el personaje en la relación

«Cillian Murphy actúa en Oppenheimer **como** J. Robert Oppenheimer».

Ese «como» no es un dato de la persona ni de la obra: es de la relación entre
ambas. Por eso no cabe en `DAT_DATO_PELICULA` y necesita tabla propia, con
`personaje` y `orden`.

## 9. Lo que deliberadamente NO es un atributo EAV

| Dato | Dónde vive | Por qué |
|---|---|---|
| título, año, portada | `DAT_OBRA` | se leen en todas las pantallas; un join por tarjeta de parrilla mata el EAV |
| autor, director, reparto | `DAT_PERSONA_OBRA` | son entidades con página propia |
| ISBN, id de TMDB | `DAT_ID_EXTERNO_OBRA` | necesitan índice único, que en EAV no se puede |
| saga, número de volumen | `DAT_COLECCION` | relación N:M con orden |
| nº de temporadas, nota media | en ninguna parte | son **derivados**: `COUNT`/`AVG`. Almacenarlos garantiza desincronizarlos |

## 10. Auditoría en las 31 tablas

Cuatro columnas: `fecha_alta`, `usuario_alta`, `fecha_modificacion`,
`usuario_modificacion`.

`usuario_*` es `varchar(60)` y **no** una FK a la tabla de usuarios: buena parte
de las altas las harán procesos de importación (`SISTEMA`, `IMPORT_TMDB`), y una
FK obligaría a inventar usuarios ficticios para ellos.

Un trigger común rellena `fecha_modificacion` en cada `UPDATE`.
`usuario_modificacion` lo pone la aplicación, porque la base de datos no sabe
quién está detrás de la sesión.

**Coste conocido:** unos 40 bytes por fila. Irrelevante en las `CFG_*`, no tanto
en las `DAT_DATO_*`, que son las de mayor volumen y donde la auditoría puede
llegar a pesar más que el propio dato. Se asume a cambio de trazabilidad, que en
un catálogo colaborativo es justo lo que se quiere.

---

## Decisiones pendientes

### Ediciones de libro

`num_paginas`, `formato` (tapa dura / bolsillo / ebook / audiolibro) e `isbn` **no
son propiedades del libro**, son de *una edición concreta*. *Dune* tiene decenas
de ISBNs y paginaciones distintas.

Goodreads y StoryGraph separan obra de edición. Aquí se ha dejado `num_paginas`
en el catálogo de `LIBRO` asumiendo que **no** se modelan ediciones, que es lo
razonable para una v1.

Si se quieren más adelante hará falta `DAT_EDICION_LIBRO` colgando de
`DAT_LIBRO`, y esos campos se mudan allí. **Es la migración más probable de este
esquema.**

### Títulos multiidioma

`DAT_OBRA.titulo` es único por obra. Si se quiere el mismo título en varios
idiomas sin duplicar obras, la vía es añadir una columna `locale` a
`DAT_DATO_*` y tratar el título como atributo traducible.

Meterlo después es una migración incómoda: conviene decidirlo antes de cargar
datos en volumen.

### Clasificación por edades

Varía por país (PEGI, MPAA, ICAA). Se guarda un valor normalizado propio
(`TP`, `+7`, `+12`, `+16`, `+18`) en lugar de replicar cada sistema nacional.
