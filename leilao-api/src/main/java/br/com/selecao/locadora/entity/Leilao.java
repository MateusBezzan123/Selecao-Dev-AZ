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
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@Entity
@Table(name = "TB_LEILAO")
@SequenceGenerator(name = "seq_leilao", sequenceName = "seq_leilao", allocationSize = 1)
public class Leilao implements Serializable {

    @Id
    @Column(name = "ID")
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "seq_leilao")
    @EqualsAndHashCode.Include
    private Long id;

    @Column(name = "CODIGO", nullable = false)
    private Integer codigo;

    @Column(name = "DESCRICAO", nullable = false, length = 60)
    private String descricao;

    @Column(name = "VENDEDOR", nullable = false)
    private Long vendedor;

    @Column(name = "INICIOPREVISTO", nullable = false)
    private LocalDateTime inicioPrevisto;

    @Column(name = "CREATEDAT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "UPDATEDAT", nullable = false)
    private LocalDateTime updatedAt;
}