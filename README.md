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
└── db/
    ├── migrations/              DDL, en orden de ejecución
    └── seeds/                   Datos iniciales de configuración
```

## Montar la base de datos desde cero

Requiere PostgreSQL 14 o superior (se usa `num_nonnulls`, columnas generadas
y `CREATE OR REPLACE TRIGGER`).

```bash
createdb medialog
```

Después, ejecutar en orden todo `db/migrations/` y luego todo `db/seeds/`:

```bash
for f in db/migrations/*.sql db/seeds/*.sql; do psql -d medialog -f "$f"; done
```

En PowerShell:

```bash
Get-ChildItem db/migrations/*.sql, db/seeds/*.sql | ForEach-Object { psql -d medialog -f $_.FullName }
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

- [x] Modelo de datos
- [x] DDL
- [ ] Dominio social (usuarios, reviews, ratings, listas, seguimiento)
- [ ] API
- [ ] Aplicación web
- [ ] App Android
