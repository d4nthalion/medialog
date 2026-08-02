import type { ReactNode } from 'react';

interface SectionProps {
  index: string;
  title: string;
  subtitle?: string;
  action?: ReactNode;
  children: ReactNode;
}

/** Cabecera de sección con el índice monoespaciado, igual que en el portfolio. */
export function Section({ index, title, subtitle, action, children }: SectionProps) {
  return (
    <section className="relative py-10 sm:py-14">
      <div className="max-w-6xl mx-auto px-5 sm:px-8">
        <header className="reveal mb-8">
          <div className="flex items-center gap-3">
            <span className="font-mono text-xs font-semibold text-[var(--neon)] tracking-widest">
              {index}
            </span>
            <h2 className="text-2xl sm:text-3xl font-bold tracking-tight text-[var(--text-hi)]">
              {title}
            </h2>
            <span className="flex-1 h-px bg-gradient-to-r from-[var(--border)] to-transparent ml-2" />
            {action}
          </div>
          {subtitle && <p className="mt-2.5 ml-8 text-sm text-[var(--text-dim)]">{subtitle}</p>}
        </header>

        {children}
      </div>
    </section>
  );
}
