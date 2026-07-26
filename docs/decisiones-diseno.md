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

## 10. Auditoría en las 45 tablas

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

# Dominio social

## 11. Valoración, registro y reseña son tres tablas

La decisión estructural de esta mitad del esquema.

- `DAT_VALORACION` — la nota **actual**. Una fila por usuario y obra. Cambiar de opinión es un `UPDATE`.
- `DAT_REGISTRO` — el diario. **Acumulativo**: releer *Dune* tres veces son tres filas.
- `DAT_RESENA` — el texto. Varias por obra, ligadas o no a un registro concreto.

Mezclarlas es el error clásico. La nota es *un hecho que se corrige*; el diario es
*una historia que se acumula*. Si van juntas, o pierdes el historial al
recalificar, o acabas con cinco notas activas sin saber cuál es «la del usuario».

## 12. Marcar un episodio visto no necesita tabla

Un episodio ya es una fila de `DAT_OBRA`, así que verlo es un `DAT_REGISTRO` más.
Puntuar una temporada suelta, igual.

Es el retorno de la decisión 4. Sin el supertipo harían falta
`DAT_EPISODIO_VISTO`, `DAT_VALORACION_TEMPORADA` y las que fueran saliendo.

## 13. Las notas, enteros de 1 a 10

Medias estrellas sobre cinco, guardadas como `smallint`: 7 son tres estrellas y
media.

Nada de `numeric(2,1)` ni de coma flotante. Comparar `4.5` en flotante da
sorpresas, y con enteros el `CHECK (nota BETWEEN 1 AND 10)` es trivial. La
conversión a estrellas es cosa del frontend.

## 14. Un solo estado por obra y usuario

`DAT_ESTADO_USUARIO_OBRA` cubre `PENDIENTE`, `EN_CURSO`, `SIGUIENDO`,
`COMPLETADA` y `ABANDONADA` en una tabla, en lugar de una lista de pendientes,
otra de «leyendo ahora» y otra de abandonados.

Son estados mutuamente excluyentes del mismo hecho. Como tablas independientes
habría que sincronizarlas a mano en cada transición, y antes o después una se
quedaría desfasada.

`SIGUIENDO` existe aparte de `EN_CURSO` por las series: distingue «la veo semana
a semana» de «la tengo empezada y parada», y sin ese matiz no se puede avisar de
episodios nuevos solo a quien los espera.

## 15. Nada de FKs polimórficas: dos tablas de «me gusta»

`DAT_ME_GUSTA_RESENA` y `DAT_ME_GUSTA_LISTA` en vez de una tabla genérica con
`(tipo, id)`.

Misma razón que llevó a `DAT_OBRA`: una FK polimórfica no tiene integridad
referencial y permite apuntar a filas que no existen. Aquí las tablas son
pequeñas y duplicarlas apenas cuesta.

## 16. Bajas de usuario lógicas, no en cascada

`activo = false` más anonimización de `login`, `email` y `biografia`. El
contenido sobrevive como «usuario eliminado».

Si un usuario se borrase en cascada se llevaría por delante sus reseñas y, con
ellas, los hilos de comentarios de otras personas. Un borrado real por RGPD, si
llega a hacer falta, es un procedimiento aparte y consciente.

## 17. La nota media sí se almacena, pero en tabla aparte

Matiza la decisión 9. Con `num_temporadas` la regla se mantiene: un `COUNT` sobre
veinte filas es gratis.

La nota media es distinta: un `AVG` sobre potencialmente millones de valoraciones
que se pinta en **cada tarjeta de cada parrilla**. Al vuelo no escala.

Va en `DAT_ESTADISTICA_OBRA` y no como columna de `DAT_OBRA`. Así queda explícito
que es una caché —con su `fecha_calculo` a la vista— y nadie la confunde con una
propiedad de la obra. Se puede borrar entera y reconstruir con
`fn_refrescar_estadisticas()`.

**No es un trigger a propósito.** Un trigger por cada voto pondría todas las
escrituras de una obra popular a competir por la misma fila, y la contención
sería peor que el ahorro. Se refresca periódicamente.

## 18. El feed de actividad, derivado

Un `UNION ALL` sobre registros, reseñas, listas y seguimientos de la gente a la
que sigues. Correcto y suficiente durante mucho tiempo.

Una tabla `DAT_ACTIVIDAD` desnormalizada es la optimización que se hace *cuando*
el feed va lento. Metida desde el día uno, obliga a mantenerla sincronizada con
cinco tablas sin saber todavía si hacía falta.

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

### Inicio de sesión con proveedores externos

`DAT_USUARIO.hash_password` asume autenticación propia con argon2id, que es lo
razonable para una v1.

Cuando se quiera «entrar con Google», hará falta `DAT_IDENTIDAD_USUARIO`
(`usuario_id`, `proveedor`, `id_externo`, único por proveedor), y `hash_password`
pasará a ser opcional: quien entre solo por OAuth no tendrá contraseña.

Es el equivalente social de la migración de ediciones: previsible, acotada y no
urgente.

### Títulos multiidioma

`DAT_OBRA.titulo` es único por obra. Si se quiere el mismo título en varios
idiomas sin duplicar obras, la vía es añadir una columna `locale` a
`DAT_DATO_*` y tratar el título como atributo traducible.

Meterlo después es una migración incómoda: conviene decidirlo antes de cargar
datos en volumen.

### Clasificación por edades

Varía por país (PEGI, MPAA, ICAA). Se guarda un valor normalizado propio
(`TP`, `+7`, `+12`, `+16`, `+18`) en lugar de replicar cada sistema nacional.
