import { Link, useParams } from 'react-router-dom';
import { ChevronLeft, Play } from 'lucide-react';
import { api } from '../api/client';
import { useApi } from '../hooks/useApi';
import { Cargando, Error } from '../components/Estado';

export function TemporadaDetallePage() {
  const { id } = useParams();
  const { datos: temporada, cargando, error } = useApi(
    (signal) => api.temporada(Number(id), signal),
    [id],
  );

  return (
    <div className="max-w-6xl mx-auto px-5 sm:px-8 py-10 sm:py-14">
      {temporada && (
        <Link
          to={`/series/${temporada.serieId}`}
          className="inline-flex items-center gap-1.5 font-mono text-xs text-[var(--text-dim)] hover:text-[var(--neon)] transition-colors"
        >
          <ChevronLeft size={14} /> {temporada.serieTitulo}
        </Link>
      )}

      <div className="mt-6">
        {cargando && <Cargando tarjetas={3} />}
        {error && <Error error={error} />}

        {temporada && (
          <>
            <span className="font-mono text-xs uppercase tracking-widest text-[var(--neon)]">
              Temporada {temporada.numero}
            </span>
            <h1 className="mt-1 text-3xl sm:text-4xl font-bold tracking-tight text-[var(--text-hi)]">
              {temporada.titulo}
            </h1>
            <p className="mt-1.5 font-mono text-sm text-[var(--text-dim)]">
              {temporada.anio ?? '—'} · {temporada.episodios.length}{' '}
              {temporada.episodios.length === 1 ? 'episodio' : 'episodios'}
            </p>

            <ul className="mt-10 space-y-2">
              {temporada.episodios.map((e) => (
                <li key={e.id}>
                  <Link
                    to={`/episodios/${e.id}`}
                    className="panel rounded px-4 py-3 flex items-center gap-4 group"
                  >
                    <span className="font-mono text-sm font-bold text-[var(--neon)] w-8 shrink-0">
                      {String(e.numero).padStart(2, '0')}
                    </span>
                    <span className="flex-1 text-sm text-[var(--text-hi)] group-hover:text-[var(--neon)] transition-colors">
                      {e.titulo}
                    </span>
                    <Play
                      size={14}
                      className="text-[var(--text-dim)] opacity-0 group-hover:opacity-100 transition-opacity"
                    />
                  </Link>
                </li>
              ))}
            </ul>

            {temporada.episodios.length === 0 && (
              <p className="mt-10 text-sm text-[var(--text-dim)]">
                Esta temporada todavía no tiene episodios.
              </p>
            )}
          </>
        )}
      </div>
    </div>
  );
}
