import type { Episodio, Pagina, Serie, SerieResumen, Temporada } from './types';

const BASE = import.meta.env.VITE_API_URL ?? 'http://localhost:8080/api';

/** Error de la API con el codigo HTTP, para poder distinguir un 404 de una caida. */
export class ApiError extends Error {
  // Campo declarado a mano y no como propiedad de constructor: el tsconfig
  // activa erasableSyntaxOnly, que prohibe la sintaxis exclusiva de TS.
  readonly status: number;

  constructor(status: number, mensaje: string) {
    super(mensaje);
    this.name = 'ApiError';
    this.status = status;
  }
}

async function pedir<T>(ruta: string, signal?: AbortSignal): Promise<T> {
  let res: Response;
  try {
    res = await fetch(`${BASE}${ruta}`, { signal });
  } catch (e) {
    // fetch solo rechaza por fallo de red o CORS, nunca por codigo de estado.
    if (e instanceof DOMException && e.name === 'AbortError') throw e;
    throw new ApiError(0, 'No se puede contactar con la API. ¿Está arrancada?');
  }

  if (!res.ok) {
    // La API responde ProblemDetail (RFC 9457); el campo util es `detail`.
    const detalle = await res
      .json()
      .then((b: { detail?: string }) => b.detail)
      .catch(() => null);
    throw new ApiError(res.status, detalle ?? `Error ${res.status}`);
  }

  return res.json() as Promise<T>;
}

export const api = {
  series(q: string, pagina: number, signal?: AbortSignal) {
    const params = new URLSearchParams({ page: String(pagina), size: '12' });
    if (q.trim()) params.set('q', q.trim());
    return pedir<Pagina<SerieResumen>>(`/series?${params}`, signal);
  },

  serie(id: number, signal?: AbortSignal) {
    return pedir<Serie>(`/series/${id}`, signal);
  },

  temporada(id: number, signal?: AbortSignal) {
    return pedir<Temporada>(`/temporadas/${id}`, signal);
  },

  episodio(id: number, signal?: AbortSignal) {
    return pedir<Episodio>(`/episodios/${id}`, signal);
  },
};
