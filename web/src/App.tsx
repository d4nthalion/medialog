import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { useTheme } from './hooks/useTheme';
import { useReveal } from './hooks/useReveal';
import { Navbar } from './components/Navbar';
import { Footer } from './components/Footer';
import { SeriesPage } from './pages/SeriesPage';
import { SerieDetallePage } from './pages/SerieDetallePage';
import { TemporadaDetallePage } from './pages/TemporadaDetallePage';
import { EpisodioDetallePage } from './pages/EpisodioDetallePage';
import { EnObrasPage } from './pages/EnObrasPage';
import { NoEncontradaPage } from './pages/NoEncontradaPage';

function Layout() {
  const { theme, toggleTheme } = useTheme();
  useReveal();

  return (
    <>
      {/* Capas de fondo */}
      <div className="backdrop" aria-hidden="true" />
      <div
        className="glow-orb"
        aria-hidden="true"
        style={{
          width: 480,
          height: 480,
          top: '-14%',
          right: '-8%',
          background: 'var(--neon)',
          opacity: 0.13,
        }}
      />
      <div
        className="glow-orb"
        aria-hidden="true"
        style={{
          width: 400,
          height: 400,
          bottom: '4%',
          left: '-12%',
          background: 'var(--neon-alt)',
          opacity: 0.08,
        }}
      />

      <Navbar theme={theme} onToggleTheme={toggleTheme} />

      <main className="relative z-10 pt-16 min-h-[70vh]">
        <Routes>
          <Route path="/" element={<Navigate to="/series" replace />} />
          <Route path="/series" element={<SeriesPage />} />
          <Route path="/series/:id" element={<SerieDetallePage />} />
          <Route path="/temporadas/:id" element={<TemporadaDetallePage />} />
          <Route path="/episodios/:id" element={<EpisodioDetallePage />} />
          <Route path="/peliculas" element={<EnObrasPage index="02" titulo="Películas" />} />
          <Route path="/libros" element={<EnObrasPage index="03" titulo="Libros" />} />
          <Route path="*" element={<NoEncontradaPage />} />
        </Routes>
      </main>

      <div className="relative z-10">
        <Footer />
      </div>
    </>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Layout />
    </BrowserRouter>
  );
}
