import { Link } from 'react-router-dom';
import { ImageOff } from 'lucide-react';

interface Props {
  to: string;
  titulo: string;
  anio?: number | null;
  portadaUrl?: string | null;
  etiqueta?: string;
}

/** Tarjeta de obra con proporción de póster. */
export function Tarjeta({ to, titulo, anio, portadaUrl, etiqueta }: Props) {
  return (
    <Link to={to} className="reveal group block">
      <div className="panel bracket rounded overflow-hidden aspect-[2/3] flex items-center justify-center">
        {portadaUrl ? (
          <img
            src={portadaUrl}
            alt=""
            loading="lazy"
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
          />
        ) : (
          <ImageOff size={26} className="text-[var(--text-dim)] opacity-50" />
        )}
      </div>

      <div className="mt-2.5">
        {etiqueta && (
          <span className="font-mono text-[10px] uppercase tracking-widest text-[var(--neon)]">
            {etiqueta}
          </span>
        )}
        <p className="text-sm font-medium text-[var(--text-hi)] line-clamp-2 group-hover:text-[var(--neon)] transition-colors">
          {titulo}
        </p>
        {anio != null && (
          <p className="font-mono text-xs text-[var(--text-dim)]">{anio}</p>
        )}
      </div>
    </Link>
  );
}
