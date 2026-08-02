import { Link } from 'react-router-dom';

export function NoEncontradaPage() {
  return (
    <div className="max-w-6xl mx-auto px-5 sm:px-8 py-24 text-center">
      <p className="font-mono text-6xl font-bold neon-text glitch" data-text="404">
        404
      </p>
      <p className="mt-4 text-[var(--text-dim)]">Esta ruta no existe.</p>
      <Link
        to="/series"
        className="mt-8 inline-block px-4 py-2 rounded border border-[var(--border)] text-sm text-[var(--text-hi)] hover:border-[var(--border-hi)] hover:text-[var(--neon)] transition-colors"
      >
        Volver al catálogo
      </Link>
    </div>
  );
}
