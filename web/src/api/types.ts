/**
 * Espejo de los DTOs de la API (com.medialog.api.dto).
 *
 * Se mantienen a mano a proposito: son pocos y explicitos, y generarlos desde
 * OpenAPI ataria el build del front a que la API este levantada.
 */

export type TipoDatoValor =
  | 'TEXTO'
  | 'TEXTO_LARGO'
  | 'ENTERO'
  | 'DECIMAL'
  | 'FECHA'
  | 'BOOL'
  | 'OPCION'
  | 'IDIOMA'
  | 'PAIS';

/**
 * Un dato EAV ya resuelto.
 *
 * La API es generica y dirigida por metadatos: devuelve una LISTA de datos con
 * su descripcion, no campos con nombre fijo. Por eso el front puede pintar un
 * atributo nuevo del catalogo sin tocar codigo.
 */
export interface Dato {
  codigo: string;
  nombre: string;
  grupo: string | null;
  unidad: string | null;
  tipo: TipoDatoValor;
  /** Valor en bruto; su tipo real depende de `tipo`. */
  valor: string | number | boolean | null;
  /** Texto legible cuando el valor es una referencia (opcion, idioma, pais). */
  etiqueta: string | null;
  posicion: number;
}

export interface SerieResumen {
  id: number;
  titulo: string;
  anio: number | null;
  portadaUrl: string | null;
}

export interface TemporadaResumen {
  id: number;
  numero: number;
  titulo: string;
}

export interface EpisodioResumen {
  id: number;
  numero: number;
  titulo: string;
}

export interface Serie extends SerieResumen {
  numTemporadas: number;
  datos: Dato[];
  temporadas: TemporadaResumen[];
}

export interface Temporada {
  id: number;
  serieId: number;
  serieTitulo: string;
  numero: number;
  titulo: string;
  anio: number | null;
  portadaUrl: string | null;
  episodios: EpisodioResumen[];
}

export interface Episodio {
  id: number;
  temporadaId: number;
  temporadaNumero: number;
  numero: number;
  titulo: string;
  anio: number | null;
  portadaUrl: string | null;
  datos: Dato[];
}

/** Forma de Page<T> de Spring Data. */
export interface Pagina<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
  first: boolean;
  last: boolean;
  empty: boolean;
}
