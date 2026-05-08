package br.com.selecao.locadora.service;

import br.com.selecao.locadora.business.LeilaoBO;
import br.com.selecao.locadora.entity.Leilao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/leilao")
public class LeilaoService {

    @Autowired
    private LeilaoBO leilaoBO;

    @GetMapping
    public ResponseEntity<Object> buscarTodos() {
        return new ResponseEntity<>(leilaoBO.buscarTodos(), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Object> buscarPorId(@PathVariable Long id) {
        return leilaoBO.buscarPorId(id)
                .<ResponseEntity<Object>>map(l -> new ResponseEntity<>(l, HttpStatus.OK))
                .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    public ResponseEntity<Object> salvar(@RequestBody Leilao leilao) {
        return new ResponseEntity<>(leilaoBO.salvar(leilao), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Object> alterar(@PathVariable Long id, @RequestBody Leilao leilao) {
        return leilaoBO.alterar(id, leilao)
                .<ResponseEntity<Object>>map(l -> new ResponseEntity<>(l, HttpStatus.OK))
                .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Object> remover(@PathVariable Long id) {
        return leilaoBO.remover(id)
                ? new ResponseEntity<>(HttpStatus.NO_CONTENT)
                : new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
}