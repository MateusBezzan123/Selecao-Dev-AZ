package br.com.selecao.locadora.service;

import br.com.selecao.locadora.business.CompradorBO;
import br.com.selecao.locadora.entity.Comprador;
import br.com.selecao.locadora.entity.CompradorId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/comprador")
public class CompradorService {

    @Autowired
    private CompradorBO compradorBO;

    @GetMapping
    public ResponseEntity<Object> buscarTodos() {
        return new ResponseEntity<>(compradorBO.buscarTodos(), HttpStatus.OK);
    }

    @GetMapping("/{empresa}/{leilao}")
    public ResponseEntity<Object> buscarPorId(@PathVariable Long empresa,
                                              @PathVariable Long leilao) {
        return compradorBO.buscarPorId(empresa, leilao)
                .<ResponseEntity<Object>>map(c -> new ResponseEntity<>(c, HttpStatus.OK))
                .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    public ResponseEntity<Object> salvar(@RequestBody CompradorId compradorId) {
        Comprador comprador = Comprador.builder().id(compradorId).build();
        return new ResponseEntity<>(compradorBO.salvar(comprador), HttpStatus.CREATED);
    }

    @DeleteMapping("/{empresa}/{leilao}")
    public ResponseEntity<Object> remover(@PathVariable Long empresa,
                                          @PathVariable Long leilao) {
        return compradorBO.remover(empresa, leilao)
                ? new ResponseEntity<>(HttpStatus.NO_CONTENT)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
}