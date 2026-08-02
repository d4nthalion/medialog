import { Link, useParams } from 'react-router-dom';
import { ChevronLeft } from 'lucide-react';
import { api } from '../api/client';
import { useApi } from '../hooks/useApi';
import { ListaDatos } from '../components/ListaDatos';
import { Cargando, Error } from '../components/Estado';

export function EpisodioDetallePage() {
  const { id } = useParams();
  const { datos: episodio, cargando, error } = useApi(
    (signal) => api.episodio(Number(id), signal),
    [id],
  );

  return (
    <div className="max-w-6xl mx-auto px-5 sm:px-8 py-10 sm:py-14">
      {episodio && (
        <Link
          to={`/temporadas/${episodio.temporadaId}`}
          className="inline-flex items-center gap-1.5 font-mono text-xs text-[var(--text-dim)] hover:text-[var(--neon)] transition-colors"
        >
          <ChevronLeft size={14} /> Temporada {episodio.temporadaNumero}
        </Link>
      )}

      <div className="mt-6">
        {cargando && <Cargando tarjetas={2} />}
        {error && <Error error={error} />}

        {episodio && (
          <>
            <span className="font-mono text-xs uppercase tracking-widest text-[var(--neon)]">
              T{String(episodio.temporadaNumero).padStart(2, '0')} · E
              {String(episodio.numero).padStart(2, '0')}
            </span>
            <h1 className="mt-1 text-3xl sm:text-4xl font-bold tracking-tight text-[var(--text-hi)]">
              {episodio.titulo}
            </h1>

            <div className="mt-10 max-w-3xl">
              <ListaDatos datos={episodio.datos} />
            </div>
          </>
        )}
      </div>
    </div>
  );
}
