#!/usr/bin/env node
/**
 * Ejecutor de scripts SQL de medialog.
 *
 * Existe porque no hay psql instalado: los ficheros .sql se envian a
 * PostgreSQL a traves del driver de Node. Por eso ninguno de ellos usa
 * metacomandos de psql (\set, \if, \echo): no se entenderian aqui.
 *
 * Uso:
 *   npm run db:migrate    aplica db/migrations/*.sql en orden
 *   npm run db:seed       aplica db/seeds/*.sql en orden
 *   npm run db:drop       borra el esquema completo (pide confirmacion)
 *   npm run db:reset      drop + migrate + seed
 *
 * La conexion sale de DATABASE_URL, en .env o en el entorno.
 */

import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const RAIZ = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');

// Node 20.12+ lee .env sin dependencias externas.
if (existsSync(join(RAIZ, '.env'))) process.loadEnvFile(join(RAIZ, '.env'));

const { DATABASE_URL } = process.env;
if (!DATABASE_URL) {
  console.error('\nFalta DATABASE_URL.');
  console.error('Copia .env.example a .env y pega ahi la cadena de Neon.\n');
  process.exit(1);
}

/** Neon y cualquier Postgres gestionado exigen TLS. */
const necesitaSsl = /sslmode=require|neon\.tech/.test(DATABASE_URL);

const comando = process.argv[2];
const confirmado = process.argv.includes('--confirmar=BORRAR');

function ficherosDe(carpeta) {
  const ruta = join(RAIZ, 'db', carpeta);
  return readdirSync(ruta)
    .filter((f) => f.endsWith('.sql'))
    .sort()
    .map((f) => ({ nombre: `${carpeta}/${f}`, ruta: join(ruta, f) }));
}

/**
 * Cada fichero va en su propia transaccion: si uno falla a mitad no
 * queda a medias, y los anteriores ya aplicados se conservan.
 */
async function aplicar(cliente, fichero, previo = null) {
  const sql = readFileSync(fichero.ruta, 'utf8');
  const t0 = Date.now();
  try {
    await cliente.query('BEGIN');
    if (previo) await cliente.query(previo);
    await cliente.query(sql);
    await cliente.query('COMMIT');
    console.log(`  ok   ${fichero.nombre}  (${Date.now() - t0} ms)`);
  } catch (err) {
    await cliente.query('ROLLBACK');
    console.error(`  FALLO ${fichero.nombre}`);
    console.error(`        ${err.message}`);
    if (err.position) {
      const hasta = sql.slice(0, Number(err.position));
      console.error(`        linea ${hasta.split('\n').length}`);
    }
    throw err;
  }
}

async function migrar(cliente) {
  console.log('\nAplicando migraciones...');
  for (const f of ficherosDe('migrations')) await aplicar(cliente, f);
}

async function sembrar(cliente) {
  console.log('\nSembrando datos de configuracion...');
  for (const f of ficherosDe('seeds')) await aplicar(cliente, f);
}

async function borrar(cliente) {
  if (!confirmado) {
    console.error('\n  ABORTADO. Esto borra TODAS las tablas y TODOS los datos.');
    console.error('  Para ejecutarlo de verdad:\n');
    console.error('      npm run db:drop -- --confirmar=BORRAR\n');
    process.exit(1);
  }
  console.log('\nBorrando el esquema completo...');
  // El cerrojo del propio script: sin este SET, drop_all.sql aborta.
  await aplicar(
    cliente,
    { nombre: 'tools/drop_all.sql', ruta: join(RAIZ, 'db', 'tools', 'drop_all.sql') },
    "SET LOCAL medialog.confirmar = 'BORRAR'",
  );
}

async function resumen(cliente) {
  const { rows } = await cliente.query(`
    SELECT count(*)::int AS tablas
    FROM   information_schema.tables
    WHERE  table_schema = 'public' AND table_type = 'BASE TABLE'
  `);
  console.log(`\nTablas en el esquema: ${rows[0].tablas}`);
}

const cliente = new pg.Client({
  connectionString: DATABASE_URL,
  ssl: necesitaSsl ? { rejectUnauthorized: true } : false,
});

try {
  await cliente.connect();
  const { rows } = await cliente.query('SELECT version()');
  console.log(rows[0].version.split(',')[0]);

  switch (comando) {
    case 'migrate':
      await migrar(cliente);
      break;
    case 'seed':
      await sembrar(cliente);
      break;
    case 'drop':
      await borrar(cliente);
      break;
    case 'reset':
      await borrar(cliente);
      await migrar(cliente);
      await sembrar(cliente);
      break;
    default:
      console.error('\nComandos: migrate | seed | drop | reset\n');
      process.exit(1);
  }

  await resumen(cliente);
  console.log('Listo.\n');
} catch (err) {
  console.error(`\n${err.message}\n`);
  process.exitCode = 1;
} finally {
  await cliente.end();
}
