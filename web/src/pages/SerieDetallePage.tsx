import { Link, useParams } from 'react-router-dom';
import { ChevronLeft, ImageOff, Layers } from 'lucide-react';
import { api } from '../api/client';
import { useApi } from '../hooks/useApi';
import { ListaDatos } from '../components/ListaDatos';
import { Cargando, Error } from '../components/Estado';

export function SerieDetallePage() {
  const { id } = useParams();
  const { datos: serie, cargando, error } = useApi(
    (signal) => api.serie(Number(id), signal),
    [id],
  );

  return (
    <div className="max-w-6xl mx-auto px-5 sm:px-8 py-10 sm:py-14">
      <Link
        to="/series"
        className="inline-flex items-center gap-1.5 font-mono text-xs text-[var(--text-dim)] hover:text-[var(--neon)] transition-colors"
      >
        <ChevronLeft size={14} /> Series
      </Link>

      <div className="mt-6">
        {cargando && <Cargando tarjetas={4} />}
        {error && <Error error={error} />}

        {serie && (
          <>
            <div className="grid gap-8 md:grid-cols-[220px_1fr]">
              <div className="panel bracket rounded overflow-hidden aspect-[2/3] flex items-center justify-center">
                {serie.portadaUrl ? (
                  <img src={serie.portadaUrl} alt="" className="w-full h-full object-cover" />
                ) : (
                  <ImageOff size={28} className="text-[var(--text-dim)] opacity-50" />
                )}
              </div>

              <div className="reveal">
                <span className="font-mono text-xs uppercase tracking-widest text-[var(--neon)]">
                  Serie
                </span>
                <h1 className="mt-1 text-3xl sm:text-4xl font-bold tracking-tight text-[var(--text-hi)]">
                  {serie.titulo}
                </h1>
                <p className="mt-1.5 font-mono text-sm text-[var(--text-dim)]">
                  {serie.anio ?? '—'} · {serie.numTemporadas}{' '}
                  {serie.numTemporadas === 1 ? 'temporada' : 'temporadas'}
                </p>

                <div className="mt-8">
                  <ListaDatos datos={serie.datos} />
                </div>
              </div>
            </div>

            <section className="mt-14">
              <div className="flex items-center gap-3 mb-6">
                <Layers size={16} className="text-[var(--neon)]" />
                <h2 className="text-xl font-bold tracking-tight text-[var(--text-hi)]">
                  Temporadas
                </h2>
                <span className="flex-1 h-px bg-gradient-to-r from-[var(--border)] to-transparent" />
              </div>

              {serie.temporadas.length === 0 ? (
                <p className="text-sm text-[var(--text-dim)]">
                  Esta serie todavía no tiene temporadas.
                </p>
              ) : (
                <ul className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                  {serie.temporadas.map((t) => (
                    <li key={t.id}>
                      <Link
                        to={`/temporadas/${t.id}`}
                        className="panel bracket rounded p-4 flex items-baseline gap-3 group"
                      >
                        <span className="font-mono text-lg font-bold text-[var(--neon)]">
                          {String(t.numero).padStart(2, '0')}
                        </span>
                        <span className="text-sm text-[var(--text-hi)] group-hover:text-[var(--neon)] transition-colors">
                          {t.titulo}
                        </span>
                      </Link>
                    </li>
                  ))}
                </ul>
              )}
            </section>
          </>
        )}
      </div>
    </div>
  );
}
