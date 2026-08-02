import { AlertTriangle, SearchX } from 'lucide-react';
import type { ApiError } from '../api/client';

/** Rejilla de esqueletos con la proporción de un póster. */
export function Cargando({ tarjetas = 6 }: { tarjetas?: number }) {
  return (
    <div className="grid gap-4 grid-cols-2 sm:grid-cols-3 lg:grid-cols-4">
      {Array.from({ length: tarjetas }, (_, i) => (
        <div key={i} className="skeleton rounded aspect-[2/3]" />
      ))}
    </div>
  );
}

export function Error({ error }: { error: ApiError }) {
  // status 0 = no hubo respuesta: la API está caída o CORS la bloqueó.
  const apiCaida = error.status === 0;

  return (
    <div className="panel bracket rounded p-6 flex gap-4">
      <AlertTriangle size={20} className="text-[var(--neon-alt)] shrink-0 mt-0.5" />
      <div>
        <p className="font-medium text-[var(--text-hi)]">
          {apiCaida ? 'Sin conexión con la API' : `Error ${error.status}`}
        </p>
        <p className="mt-1 text-sm text-[var(--text-dim)]">{error.message}</p>
        {apiCaida && (
          <p className="mt-3 font-mono text-xs text-[var(--text-dim)]">
            cd api &amp;&amp; ./mvnw spring-boot:run
          </p>
        )}
      </div>
    </div>
  );
}

export function Vacio({ mensaje }: { mensaje: string }) {
  return (
    <div className="panel rounded p-10 flex flex-col items-center gap-3 text-center">
      <SearchX size={26} className="text-[var(--text-dim)]" />
      <p className="text-sm text-[var(--text-dim)]">{mensaje}</p>
    </div>
  );
}
