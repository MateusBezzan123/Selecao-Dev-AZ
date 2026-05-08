package br.com.selecao.locadora.business;

import br.com.selecao.locadora.entity.Empresa;
import br.com.selecao.locadora.repository.EmpresaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class EmpresaBO {

    @Autowired
    private EmpresaRepository empresaRepository;

    public List<Empresa> buscarTodos() {
        return empresaRepository.findAll();
    }

    public Optional<Empresa> buscarPorId(Long id) {
        return empresaRepository.findById(id);
    }

    public Empresa salvar(Empresa empresa) {
        empresa.setCreatedAt(LocalDateTime.now());
        empresa.setUpdatedAt(LocalDateTime.now());
        return empresaRepository.save(empresa);
    }

    public Optional<Empresa> alterar(Long id, Empresa empresaAtualizada) {
        return empresaRepository.findById(id).map(empresa -> {
            empresa.setRazaoSocial(empresaAtualizada.getRazaoSocial());
            empresa.setCnpj(empresaAtualizada.getCnpj());
            empresa.setLogradouro(empresaAtualizada.getLogradouro());
            empresa.setMunicipio(empresaAtualizada.getMunicipio());
            empresa.setNumero(empresaAtualizada.getNumero());
            empresa.setComplemento(empresaAtualizada.getComplemento());
            empresa.setBairro(empresaAtualizada.getBairro());
            empresa.setCep(empresaAtualizada.getCep());
            empresa.setTelefone(empresaAtualizada.getTelefone());
            empresa.setEmail(empresaAtualizada.getEmail());
            empresa.setSite(empresaAtualizada.getSite());
            empresa.setUsuario(empresaAtualizada.getUsuario());
            empresa.setSenha(empresaAtualizada.getSenha());
            empresa.setUpdatedAt(LocalDateTime.now());
            return empresaRepository.save(empresa);
        });
    }

    public boolean remover(Long id) {
        return empresaRepository.findById(id).map(empresa -> {
            empresaRepository.delete(empresa);
            return true;
        }).orElse(false);
    }
}