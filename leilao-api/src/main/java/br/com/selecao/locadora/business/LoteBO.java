package br.com.selecao.locadora.business;

import br.com.selecao.locadora.entity.Lote;
import br.com.selecao.locadora.repository.LoteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class LoteBO {

    @Autowired
    private LoteRepository loteRepository;

    public List<Lote> buscarTodos() {
        return loteRepository.findAll();
    }

    public Optional<Lote> buscarPorId(Long id) {
        return loteRepository.findById(id);
    }

    public Lote salvar(Lote lote) {
        lote.setCreatedAt(LocalDateTime.now());
        lote.setUpdatedAt(LocalDateTime.now());
        return loteRepository.save(lote);
    }

    public Optional<Lote> alterar(Long id, Lote loteAtualizado) {
        return loteRepository.findById(id).map(lote -> {
            lote.setNumeroLote(loteAtualizado.getNumeroLote());
            lote.setDescricao(loteAtualizado.getDescricao());
            lote.setQuantidade(loteAtualizado.getQuantidade());
            lote.setValorInicial(loteAtualizado.getValorInicial());
            lote.setUnidade(loteAtualizado.getUnidade());
            lote.setLeilao(loteAtualizado.getLeilao());
            lote.setUpdatedAt(LocalDateTime.now());
            return loteRepository.save(lote);
        });
    }

    public boolean remover(Long id) {
        return loteRepository.findById(id).map(lote -> {
            loteRepository.delete(lote);
            return true;
        }).orElse(false);
    }
}