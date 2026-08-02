import type { Dato } from '../api/types';

/**
 * Pinta los datos EAV de una obra, agrupados según su metadato.
 *
 * Este componente es el que hace que el modelo EAV valga la pena: no conoce
 * ningún atributo concreto. Si mañana se añade "duración" al catálogo de la
 * base de datos, aparece aquí sin tocar una línea.
 */
export function ListaDatos({ datos }: { datos: Dato[] }) {
  if (datos.length === 0) {
    return (
      <p className="text-sm text-[var(--text-dim)]">
        Esta ficha todavía no tiene datos cargados.
      </p>
    );
  }

  // Los valores múltiples (géneros, países) llegan como filas distintas del
  // mismo código: se juntan para pintarlos como una sola entrada.
  const grupos = new Map<string, Dato[]>();
  for (const dato of datos) {
    const clave = dato.grupo ?? 'General';
    grupos.set(clave, [...(grupos.get(clave) ?? []), dato]);
  }

  return (
    <div className="space-y-6">
      {[...grupos].map(([grupo, items]) => (
        <div key={grupo}>
          <h3 className="font-mono text-xs uppercase tracking-widest text-[var(--neon)] mb-3">
            {grupo}
          </h3>
          <dl className="grid gap-x-8 gap-y-3 sm:grid-cols-2">
            {agrupar(items).map(([codigo, valores]) => (
              <div key={codigo} className="flex flex-col gap-1">
                <dt className="text-xs text-[var(--text-dim)]">{valores[0].nombre}</dt>
                <dd className="text-sm text-[var(--text-hi)]">
                  <Valor valores={valores} />
                </dd>
              </div>
            ))}
          </dl>
        </div>
      ))}
    </div>
  );
}

function agrupar(datos: Dato[]): [string, Dato[]][] {
  const mapa = new Map<string, Dato[]>();
  for (const d of datos) mapa.set(d.codigo, [...(mapa.get(d.codigo) ?? []), d]);
  return [...mapa];
}

function Valor({ valores }: { valores: Dato[] }) {
  const { tipo } = valores[0];

  // Las referencias se pintan como etiquetas: son vocabulario cerrado y
  // conviene que se lean como tal, no como texto suelto.
  if (tipo === 'OPCION' || tipo === 'IDIOMA' || tipo === 'PAIS') {
    return (
      <span className="flex flex-wrap gap-1.5">
        {valores.map((v, i) => (
          <span
            key={i}
            className="px-2 py-0.5 rounded border border-[var(--border)] bg-[var(--surface-hi)] font-mono text-xs"
          >
            {v.etiqueta ?? String(v.valor)}
          </span>
        ))}
      </span>
    );
  }

  return <>{valores.map((v) => formatear(v)).join(', ')}</>;
}

function formatear(dato: Dato): string {
  const { valor, tipo, unidad } = dato;
  if (valor === null) return '—';

  switch (tipo) {
    case 'BOOL':
      return valor ? 'Sí' : 'No';
    case 'FECHA':
      return new Date(String(valor)).toLocaleDateString('es-ES', {
        day: '2-digit',
        month: 'long',
        year: 'numeric',
      });
    case 'DECIMAL':
      return `${Number(valor).toLocaleString('es-ES')}${unidad ? ` ${unidad}` : ''}`;
    case 'ENTERO':
      return `${Number(valor).toLocaleString('es-ES')}${unidad ? ` ${unidad}` : ''}`;
    default:
      return String(valor);
  }
}
