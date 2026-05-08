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
@Table(name = "TB_EMPRESA")
@SequenceGenerator(name = "seq_empresa", sequenceName = "seq_empresa", allocationSize = 1)
public class Empresa implements Serializable {

    @Id
    @Column(name = "ID")
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "seq_empresa")
    @EqualsAndHashCode.Include
    private Long id;

    @Column(name = "RAZAOSOCIAL", nullable = false, length = 64)
    private String razaoSocial;

    @Column(name = "CNPJ", nullable = false, unique = true, length = 32)
    private String cnpj;

    @Column(name = "LOGRADOURO", length = 64)
    private String logradouro;

    @Column(name = "MUNICIPIO", length = 64)
    private String municipio;

    @Column(name = "NUMERO", length = 10)
    private String numero;

    @Column(name = "COMPLEMENTO", length = 64)
    private String complemento;

    @Column(name = "BAIRRO", length = 64)
    private String bairro;

    @Column(name = "CEP", length = 16)
    private String cep;

    @Column(name = "TELEFONE", length = 32)
    private String telefone;

    @Column(name = "EMAIL", length = 254)
    private String email;

    @Column(name = "SITE", length = 254)
    private String site;

    @Column(name = "USUARIO", nullable = false, unique = true, length = 20)
    private String usuario;

    @Column(name = "SENHA", length = 128)
    private String senha;

    @Column(name = "CREATEDAT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "UPDATEDAT", nullable = false)
    private LocalDateTime updatedAt;
}