import { Link, NavLink } from 'react-router-dom';
import { Moon, Sun, Clapperboard } from 'lucide-react';
import type { Theme } from '../hooks/useTheme';

interface Props {
  theme: Theme;
  onToggleTheme: () => void;
}

const enlaces = [
  { to: '/series', label: 'Series' },
  { to: '/peliculas', label: 'Películas' },
  { to: '/libros', label: 'Libros' },
];

export function Navbar({ theme, onToggleTheme }: Props) {
  return (
    <header className="fixed top-0 inset-x-0 z-50 border-b border-[var(--border)] bg-[color-mix(in_srgb,var(--bg)_88%,transparent)] backdrop-blur-md">
      <nav className="max-w-6xl mx-auto px-5 sm:px-8 h-16 flex items-center gap-6">
        <Link
          to="/"
          className="flex items-center gap-2 font-mono font-bold tracking-tight text-[var(--text-hi)]"
        >
          <Clapperboard size={18} className="text-[var(--neon)]" />
          <span>
            media<span className="neon-text">log</span>
          </span>
        </Link>

        <ul className="flex items-center gap-1 sm:gap-2 ml-auto">
          {enlaces.map(({ to, label }) => (
            <li key={to}>
              <NavLink
                to={to}
                className={({ isActive }) =>
                  `px-2.5 sm:px-3 py-1.5 rounded text-sm font-medium transition-colors ${
                    isActive
                      ? 'text-[var(--neon)] bg-[var(--surface-hi)]'
                      : 'text-[var(--text-dim)] hover:text-[var(--text-hi)]'
                  }`
                }
              >
                {label}
              </NavLink>
            </li>
          ))}
        </ul>

        <button
          type="button"
          onClick={onToggleTheme}
          aria-label={theme === 'dark' ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro'}
          className="p-2 rounded border border-[var(--border)] text-[var(--text-dim)] hover:text-[var(--neon)] hover:border-[var(--border-hi)] transition-colors"
        >
          {theme === 'dark' ? <Sun size={16} /> : <Moon size={16} />}
        </button>
      </nav>
    </header>
  );
}
