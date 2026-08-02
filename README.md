# medialog

Catálogo social de libros, películas y series — un «Letterboxd» para las tres cosas.

Base de datos con **modelo EAV** sobre PostgreSQL, API propia y aplicación web.
Una app Android queda pendiente para después de esas tres piezas.

## Estructura del repositorio

```
medialog/
├── docs/
│   ├── modelo-datos.dbml        Modelo para dbdiagram.io
│   ├── catalogo-datos.md        Qué datos tiene cada tipo de obra
│   └── decisiones-diseno.md     Por qué el modelo es como es
├── db/
│   ├── migrations/              DDL, en orden de ejecución
│   ├── seeds/                   Datos iniciales de configuración
│   └── tools/                   run.mjs (ejecutor) y drop_all.sql
├── api/                         Spring Boot 4.1, Java 21, Maven
│   └── src/main/java/com/medialog/api/
│       ├── config/  controller/  dto/  exception/
│       └── mapper/  model/  repository/  service/
└── web/                         Vite + React 19 + TypeScript + Tailwind 4
    └── src/
        ├── api/  components/  hooks/  pages/
```

## Arrancar el proyecto entero

Tres piezas, en este orden:

```bash
cd api; ./mvnw spring-boot:run
```

```bash
cd web; npm install; npm run dev
```

La API queda en `localhost:8080` y el front en `localhost:5175`. El front lee
`VITE_API_URL` de `web/.env.local` (ver `web/.env.example`); sin él asume
`http://localhost:8080/api`.

Los orígenes permitidos por CORS se configuran con `medialog.cors.origenes`,
que por defecto vale `http://localhost:5175`. En producción hay que fijarlo al
dominio real.

`db/migrations/099_auditoria.sql` va numerado al final a propósito: recorre las
tablas ya creadas para engancharles el trigger de auditoría y los comentarios
comunes, así que tiene que ejecutarse después de todas las demás. Al añadir
migraciones nuevas, numéralas por debajo de 099 y vuelve a lanzarlo — es
idempotente.

## Montar la base de datos

La base de datos vive en [Neon](https://console.neon.tech) — PostgreSQL
gestionado, sin instalar nada en local. Requiere PostgreSQL 14 o superior;
Neon va por encima de eso.

**1. Crear el proyecto en Neon** y copiar la cadena de conexión que muestra
la consola.

**2. Configurar el entorno:**

```bash
cp .env.example .env
```

Pegar la cadena en `DATABASE_URL`. El `.env` no se versiona.

**3. Instalar dependencias y montar el esquema:**

```bash
npm install
```

```bash
npm run db:migrate
```

```bash
npm run db:seed
```

Los scripts SQL se envían a través de `db/tools/run.mjs`, un ejecutor en Node
que aplica cada fichero en su propia transacción. Por eso **ninguno de los
`.sql` usa metacomandos de psql** (`\set`, `\if`, `\echo`): no se entenderían.

Si algún día instalas `psql`, los ficheros siguen siendo SQL puro y funcionan
igual con `-f`.

## Borrar y reconstruir

`db/tools/drop_all.sql` elimina las 45 tablas con todos sus datos. Está fuera de
`migrations/` a propósito: esa carpeta se ejecuta entera en bucle, y un script de
borrado dentro arrasaría la base de datos en cada montaje.

Exige confirmación explícita — sin ella aborta:

```bash
npm run db:drop -- --confirmar=BORRAR
```

Para rehacerlo todo de una vez (borrar, migrar y sembrar):

```bash
npm run db:reset -- --confirmar=BORRAR
```

## Mayúsculas en los nombres de tabla

Los nombres se escriben `DAT_OBRA`, `CFG_TIPO_OBRA`, etc. por convención, pero
el DDL **no los entrecomilla**. PostgreSQL los pliega a minúsculas y los guarda
como `dat_obra`. Esto es intencionado: puedes seguir escribiendo `SELECT * FROM
DAT_OBRA` en cualquier consulta y funciona, pero evitas que la API y el ORM
tengan que poner comillas dobles en cada identificador.

Si algún día entrecomillas una tabla, tendrás que entrecomillarlas todas y para
siempre. No lo hagas.

## Estado

- [x] Modelo de datos del catálogo (EAV)
- [x] DDL del catálogo
- [x] Dominio social (usuarios, valoraciones, diario, reseñas, listas, seguimiento)
- [ ] API (Spring Boot — series, temporadas y episodios; faltan películas y libros)
- [ ] Aplicación web (catálogo de series; faltan películas, libros y el dominio social)
- [ ] App Android
