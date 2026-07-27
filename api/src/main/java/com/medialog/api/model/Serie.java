package com.medialog.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

/**
 * Serie de television. Comparte clave primaria con {@link Obra}.
 *
 * <p>Sin columnas propias: todo lo variable (estado de emision, generos,
 * fechas, paises) esta en {@link DatoSerie}.
 *
 * <p>El numero de temporadas y de episodios NO se guarda: son datos derivados
 * y se cuentan sobre {@code dat_temporada} y {@code dat_episodio}. Almacenarlos
 * garantizaria que algun dia se desincronicen.
 */
@Entity
@Table(name = "dat_serie")
public class Serie extends Auditable {

    @Id
    @Column(name = "obra_id")
    private Long obraId;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "obra_id")
    private Obra obra;

    public Long getObraId() {
        return obraId;
    }

    public Obra getObra() {
        return obra;
    }

    public void setObra(Obra obra) {
        this.obra = obra;
    }
}
