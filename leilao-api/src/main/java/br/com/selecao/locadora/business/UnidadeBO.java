package br.com.selecao.locadora.business;

import br.com.selecao.locadora.entity.Unidade;
import br.com.selecao.locadora.repository.UnidadeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class UnidadeBO {

    @Autowired
    private UnidadeRepository unidadeRepository;

    public List<Unidade> buscarTodos() {
        return unidadeRepository.findAll();
    }

    public Optional<Unidade> buscarPorId(Long id) {
        return unidadeRepository.findById(id);
    }

    public Unidade salvar(Unidade unidade) {
        unidade.setCreatedAt(LocalDateTime.now());
        unidade.setUpdatedAt(LocalDateTime.now());
        return unidadeRepository.save(unidade);
    }

    public Optional<Unidade> alterar(Long id, Unidade unidadeAtualizada) {
        return unidadeRepository.findById(id).map(unidade -> {
            unidade.setNome(unidadeAtualizada.getNome());
            unidade.setUpdatedAt(LocalDateTime.now());
            return unidadeRepository.save(unidade);
        });
    }

    public boolean remover(Long id) {
        return unidadeRepository.findById(id).map(unidade -> {
            unidadeRepository.delete(unidade);
            return true;
        }).orElse(false);
    }
}