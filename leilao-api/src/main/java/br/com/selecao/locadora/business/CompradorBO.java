package br.com.selecao.locadora.business;

import br.com.selecao.locadora.entity.Comprador;
import br.com.selecao.locadora.entity.CompradorId;
import br.com.selecao.locadora.repository.CompradorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CompradorBO {

    @Autowired
    private CompradorRepository compradorRepository;

    public List<Comprador> buscarTodos() {
        return compradorRepository.findAll();
    }

    public Optional<Comprador> buscarPorId(Long empresa, Long leilao) {
        return compradorRepository.findById(new CompradorId(empresa, leilao));
    }

    public Comprador salvar(Comprador comprador) {
        return compradorRepository.save(comprador);
    }

    public boolean remover(Long empresa, Long leilao) {
        CompradorId compradorId = new CompradorId(empresa, leilao);
        return compradorRepository.findById(compradorId).map(comprador -> {
            compradorRepository.delete(comprador);
            return true;
        }).orElse(false);
    }
}