package br.com.selecao.locadora.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import javax.persistence.Embeddable;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class CompradorId implements Serializable {

    @Column(name = "EMPRESA", nullable = false)
    private Long empresa;

    @Column(name = "LEILAO", nullable = false)
    private Long leilao;
}