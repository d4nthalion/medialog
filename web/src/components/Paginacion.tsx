import { ChevronLeft, ChevronRight } from 'lucide-react';

interface Props {
  pagina: number;
  totalPaginas: number;
  onCambiar: (pagina: number) => void;
}

export function Paginacion({ pagina, totalPaginas, onCambiar }: Props) {
  if (totalPaginas <= 1) return null;

  const boton =
    'p-2 rounded border border-[var(--border)] text-[var(--text-dim)] transition-colors ' +
    'enabled:hover:text-[var(--neon)] enabled:hover:border-[var(--border-hi)] ' +
    'disabled:opacity-35 disabled:cursor-not-allowed';

  return (
    <nav className="mt-10 flex items-center justify-center gap-4" aria-label="Paginación">
      <button
        type="button"
        className={boton}
        disabled={pagina === 0}
        onClick={() => onCambiar(pagina - 1)}
        aria-label="Página anterior"
      >
        <ChevronLeft size={16} />
      </button>

      <span className="font-mono text-xs text-[var(--text-dim)]">
        {pagina + 1} / {totalPaginas}
      </span>

      <button
        type="button"
        className={boton}
        disabled={pagina >= totalPaginas - 1}
        onClick={() => onCambiar(pagina + 1)}
        aria-label="Página siguiente"
      >
        <ChevronRight size={16} />
      </button>
    </nav>
  );
}
