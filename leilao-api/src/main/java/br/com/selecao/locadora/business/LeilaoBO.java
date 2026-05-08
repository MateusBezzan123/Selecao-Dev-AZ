package br.com.selecao.locadora.business;

import br.com.selecao.locadora.entity.Leilao;
import br.com.selecao.locadora.repository.LeilaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class LeilaoBO {

    @Autowired
    private LeilaoRepository leilaoRepository;

    public List<Leilao> buscarTodos() {
        return leilaoRepository.findAll();
    }

    public Optional<Leilao> buscarPorId(Long id) {
        return leilaoRepository.findById(id);
    }

    public Leilao salvar(Leilao leilao) {
        leilao.setCreatedAt(LocalDateTime.now());
        leilao.setUpdatedAt(LocalDateTime.now());
        return leilaoRepository.save(leilao);
    }

    public Optional<Leilao> alterar(Long id, Leilao leilaoAtualizado) {
        return leilaoRepository.findById(id).map(leilao -> {
            leilao.setCodigo(leilaoAtualizado.getCodigo());
            leilao.setDescricao(leilaoAtualizado.getDescricao());
            leilao.setVendedor(leilaoAtualizado.getVendedor());
            leilao.setInicioPrevisto(leilaoAtualizado.getInicioPrevisto());
            leilao.setUpdatedAt(LocalDateTime.now());
            return leilaoRepository.save(leilao);
        });
    }

    public boolean remover(Long id) {
        return leilaoRepository.findById(id).map(leilao -> {
            leilaoRepository.delete(leilao);
            return true;
        }).orElse(false);
    }
}