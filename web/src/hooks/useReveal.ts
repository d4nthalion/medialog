import { useEffect } from 'react';

/**
 * Anade la clase `in` a cada `.reveal` cuando entra en pantalla.
 *
 * El MutationObserver es imprescindible aqui, mas que en el portfolio: las
 * tarjetas llegan por fetch despues del montaje, asi que sin observar el DOM
 * quedarian invisibles para siempre.
 */
export function useReveal() {
  useEffect(() => {
    // Sin IntersectionObserver, los .reveal se quedarian en opacity 0 para
    // siempre. En una web de catalogo eso es la pagina entera en blanco, asi
    // que se muestran todos y se renuncia a la animacion.
    if (!('IntersectionObserver' in window)) {
      document.querySelectorAll('.reveal').forEach(el => el.classList.add('in'));
      return;
    }

    const io = new IntersectionObserver(
      entries => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            entry.target.classList.add('in');
            io.unobserve(entry.target);
          }
        }
      },
      { threshold: 0.12, rootMargin: '0px 0px -8% 0px' }
    );

    const observeAll = () => {
      document.querySelectorAll('.reveal:not(.in)').forEach(el => io.observe(el));
    };

    observeAll();

    const mo = new MutationObserver(observeAll);
    mo.observe(document.body, { childList: true, subtree: true });

    return () => {
      io.disconnect();
      mo.disconnect();
    };
  }, []);
}
