export function Footer() {
  return (
    <footer className="border-t border-[var(--border)] mt-20">
      <div className="max-w-6xl mx-auto px-5 sm:px-8 py-8 flex flex-wrap items-center gap-x-3 gap-y-1">
        <span className="font-mono text-xs text-[var(--text-dim)]">
          media<span className="text-[var(--neon)]">log</span>
        </span>
        <span className="text-[var(--border-hi)]">·</span>
        <span className="font-mono text-xs text-[var(--text-dim)]">
          Catálogo de libros, películas y series
        </span>
      </div>
    </footer>
  );
}
