package br.com.selecao.locadora.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@Entity
@Table(name = "TB_LOTE")
@SequenceGenerator(name = "seq_lote", sequenceName = "seq_lote", allocationSize = 1)
public class Lote implements Serializable {

    @Id
    @Column(name = "ID")
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "seq_lote")
    @EqualsAndHashCode.Include
    private Long id;

    @Column(name = "NUMEROLOTE", nullable = false)
    private Integer numeroLote;

    @Column(name = "DESCRICAO", nullable = false, length = 60)
    private String descricao;

    @Column(name = "QUANTIDADE", nullable = false)
    private BigDecimal quantidade;

    @Column(name = "VALORINICIAL", nullable = false)
    private BigDecimal valorInicial;

    @Column(name = "UNIDADE", nullable = false, length = 128)
    private String unidade;

    @Column(name = "LEILAO", nullable = false)
    private Long leilao;

    @Column(name = "CREATEDAT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "UPDATEDAT", nullable = false)
    private LocalDateTime updatedAt;
}