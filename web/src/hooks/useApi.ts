import { useEffect, useState } from 'react';
import { ApiError } from '../api/client';

interface Estado<T> {
  datos: T | null;
  cargando: boolean;
  error: ApiError | null;
}

/**
 * Ejecuta una llamada a la API y expone carga, datos y error.
 *
 * El AbortController cancela la peticion en vuelo cuando cambian las
 * dependencias o se desmonta el componente: sin el, teclear en el buscador
 * dejaria respuestas viejas pisando a las nuevas.
 */
export function useApi<T>(
  fn: (signal: AbortSignal) => Promise<T>,
  deps: unknown[],
): Estado<T> {
  const [estado, setEstado] = useState<Estado<T>>({
    datos: null,
    cargando: true,
    error: null,
  });

  useEffect(() => {
    const ac = new AbortController();
    setEstado((e) => ({ ...e, cargando: true, error: null }));

    fn(ac.signal)
      .then((datos) => setEstado({ datos, cargando: false, error: null }))
      .catch((e: unknown) => {
        if (e instanceof DOMException && e.name === 'AbortError') return;
        setEstado({
          datos: null,
          cargando: false,
          error: e instanceof ApiError ? e : new ApiError(0, 'Error inesperado'),
        });
      });

    return () => ac.abort();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);

  return estado;
}
