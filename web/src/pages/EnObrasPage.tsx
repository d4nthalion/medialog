import { Construction } from 'lucide-react';
import { Section } from '../components/Section';

/**
 * Marcador para películas y libros: la API todavía no expone esos tipos.
 *
 * Está aquí a propósito en vez de ocultar los enlaces del menú: deja visible
 * hacia dónde va el proyecto y evita que el enrutado dé un 404 confuso.
 */
export function EnObrasPage({ titulo, index }: { titulo: string; index: string }) {
  return (
    <Section index={index} title={titulo}>
      <div className="panel bracket rounded p-10 flex flex-col items-center gap-3 text-center">
        <Construction size={26} className="text-[var(--neon)]" />
        <p className="text-sm text-[var(--text-dim)]">
          Pendiente: falta el corte de {titulo.toLowerCase()} en la API.
        </p>
        <p className="font-mono text-xs text-[var(--text-dim)]">
          model · dto · repository · service · controller
        </p>
      </div>
    </Section>
  );
}
