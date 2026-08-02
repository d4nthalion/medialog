import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { Search } from 'lucide-react';
import { api } from '../api/client';
import { useApi } from '../hooks/useApi';
import { Section } from '../components/Section';
import { Tarjeta } from '../components/Tarjeta';
import { Paginacion } from '../components/Paginacion';
import { Cargando, Error, Vacio } from '../components/Estado';

export function SeriesPage() {
  const [params, setParams] = useSearchParams();
  const q = params.get('q') ?? '';
  const pagina = Number(params.get('page') ?? 0);

  // El input es local y solo se vuelca a la URL tras una pausa: asi la
  // busqueda no lanza una peticion por tecla pulsada.
  const [texto, setTexto] = useState(q);

  useEffect(() => {
    if (texto === q) return;
    const t = setTimeout(() => {
      const siguiente = new URLSearchParams();
      if (texto.trim()) siguiente.set('q', texto.trim());
      setParams(siguiente, { replace: true });
    }, 350);
    return () => clearTimeout(t);
  }, [texto, q, setParams]);

  const { datos, cargando, error } = useApi(
    (signal) => api.series(q, pagina, signal),
    [q, pagina],
  );

  const irA = (p: number) => {
    const siguiente = new URLSearchParams(params);
    siguiente.set('page', String(p));
    setParams(siguiente);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <Section
      index="01"
      title="Series"
      subtitle={
        datos ? `${datos.totalElements} en el catálogo` : 'Consultando el catálogo…'
      }
      action={
        <label className="relative hidden sm:block">
          <Search
            size={14}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--text-dim)]"
          />
          <input
            type="search"
            value={texto}
            onChange={(e) => setTexto(e.target.value)}
            placeholder="Buscar…"
            aria-label="Buscar series"
            className="w-52 pl-9 pr-3 py-1.5 rounded border border-[var(--border)] bg-[var(--surface)] text-sm text-[var(--text-hi)] placeholder:text-[var(--text-dim)] focus:border-[var(--border-hi)] outline-none transition-colors"
          />
        </label>
      }
    >
      {cargando && <Cargando tarjetas={8} />}
      {error && <Error error={error} />}

      {datos && datos.empty && (
        <Vacio
          mensaje={
            q ? `Ninguna serie coincide con «${q}».` : 'Todavía no hay series en el catálogo.'
          }
        />
      )}

      {datos && !datos.empty && (
        <>
          <div className="grid gap-4 grid-cols-2 sm:grid-cols-3 lg:grid-cols-4">
            {datos.content.map((serie) => (
              <Tarjeta
                key={serie.id}
                to={`/series/${serie.id}`}
                titulo={serie.titulo}
                anio={serie.anio}
                portadaUrl={serie.portadaUrl}
                etiqueta="Serie"
              />
            ))}
          </div>

          <Paginacion
            pagina={datos.number}
            totalPaginas={datos.totalPages}
            onCambiar={irA}
          />
        </>
      )}
    </Section>
  );
}
