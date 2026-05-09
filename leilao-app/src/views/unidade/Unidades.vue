<template>
  <div class="unidades-page">

    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />

    <ConfirmDialog
      :visible="confirm.visible"
      title="Excluir Unidade"
      :message="`Deseja excluir '${confirm.nome}'? Esta ação não pode ser desfeita.`"
      @confirm="deletarConfirmado"
      @cancel="confirm.visible = false"
    />

    <div class="page-header">
      <div class="page-title">
        <span class="page-icon">📦</span>
        <div>
          <h1>Unidades</h1>
          <p>Gerencie as unidades de medida do sistema</p>
        </div>
      </div>
      <button class="btn-new" @click="adicionarLinha">+ Nova Unidade</button>
    </div>

    <div v-if="loading" class="loading-wrap">
      <div class="spinner"></div>
      <span>Carregando...</span>
    </div>

    <div v-else class="table-card">

      <div class="table-toolbar">
        <input
          v-model="busca"
          class="search-input"
          placeholder="🔍  Buscar unidade..."
        />
        <span class="total-badge">{{ filteredRows.length }} registro(s)</span>
      </div>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
            <tr>
              <th class="col-id"   @click="sortBy('id')">
                ID <span class="sort-icon">{{ sortIcon('id') }}</span>
              </th>
              <th class="col-nome" @click="sortBy('nome')">
                Nome <span class="sort-icon">{{ sortIcon('nome') }}</span>
              </th>
              <th class="col-acoes">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="novaLinha" class="row-new">
              <td class="col-id">—</td>
              <td class="col-nome">
                <input
                  ref="novoNomeInput"
                  v-model="novaLinha.nome"
                  class="cell-input"
                  placeholder="Nome da unidade"
                  @keyup.enter="salvarNova"
                  @keyup.esc="cancelarNova"
                />
              </td>
              <td class="col-acoes">
                <button class="btn-save"   @click="salvarNova"   title="Salvar (Enter)">✓</button>
                <button class="btn-cancel-row" @click="cancelarNova" title="Cancelar (Esc)">✕</button>
              </td>
            </tr>

            <tr
              v-for="row in filteredRows"
              :key="row.id"
              :class="{ 'row-editing': row._editing, 'row-saving': row._saving }"
            >
              <td class="col-id">{{ row.id }}</td>

              <td class="col-nome">
                <input
                  v-if="row._editing"
                  v-model="row._draft"
                  class="cell-input"
                  @keyup.enter="salvarEdicao(row)"
                  @keyup.esc="cancelarEdicao(row)"
                />
                <span v-else class="cell-text" @dblclick="iniciarEdicao(row)" :title="'Duplo clique para editar'">{{ row.nome }}</span>
              </td>

              <td class="col-acoes">
                <template v-if="row._editing">
                  <button class="btn-save"       @click="salvarEdicao(row)"   title="Salvar">✓</button>
                  <button class="btn-cancel-row" @click="cancelarEdicao(row)" title="Cancelar">✕</button>
                </template>
                <template v-else>
                  <button class="btn-edit"   @click="iniciarEdicao(row)"    title="Editar">✏️</button>
                  <button class="btn-delete" @click="confirmarDelecao(row)" title="Excluir">🗑️</button>
                </template>
              </td>
            </tr>

            <tr v-if="filteredRows.length === 0 && !novaLinha">
              <td colspan="3" class="empty-state">Nenhuma unidade encontrada.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <p class="hint">Dica: clique duas vezes em um nome para editá-lo diretamente na tabela.</p>
  </div>
</template>

<script>
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import ToastNotification from '@/components/ToastNotification.vue'

const API = 'http://localhost:8081/unidade'

export default {
  name: 'Unidades',
  components: { ConfirmDialog, ToastNotification },

  data() {
    return {
      rows:      [],
      loading:   true,
      busca:     '',
      novaLinha: null,
      sortKey:   'id',
      sortDir:   'asc',
      toast:   { visible: false, message: '', type: 'success' },
      confirm: { visible: false, nome: '', id: null }
    }
  },

  computed: {
    filteredRows() {
      const q = this.busca.toLowerCase()
      let list = this.rows.filter(r =>
        String(r.id).includes(q) || r.nome.toLowerCase().includes(q)
      )
      list = [...list].sort((a, b) => {
        const va = a[this.sortKey], vb = b[this.sortKey]
        if (va === vb) return 0
        const cmp = va < vb ? -1 : 1
        return this.sortDir === 'asc' ? cmp : -cmp
      })
      return list
    }
  },

  mounted() {
    this.buscarTodos()
  },

  methods: {
      limparFiltros() {
      this.filtros = {
        nome: '',
      }
      this.showToast('Filtros limpos', 'info')
    },

    async buscarTodos() {
      this.loading = true
      try {
        const res  = await fetch(API)
        const data = await res.json()
        this.rows  = data.map(u => ({ ...u, _editing: false, _draft: '', _saving: false }))
      } catch {
        this.showToast('Erro ao carregar unidades.', 'error')
      } finally {
        this.loading = false
      }
    },

    async salvarNova() {
      const nome = (this.novaLinha.nome || '').trim()
      if (!nome) { this.showToast('Informe o nome da unidade.', 'error'); return }
      try {
        const res = await fetch(API, {
          method:  'POST',
          headers: { 'Content-Type': 'application/json' },
          body:    JSON.stringify({ nome })
        })
        if (!res.ok) throw new Error()
        const criado = await res.json()
        this.rows.push({ ...criado, _editing: false, _draft: '', _saving: false })
        this.novaLinha = null
        this.showToast('Unidade criada com sucesso!', 'success')
      } catch {
        this.showToast('Erro ao criar unidade.', 'error')
      }
    },

    async salvarEdicao(row) {
      const nome = (row._draft || '').trim()
      if (!nome) { this.showToast('O nome não pode ser vazio.', 'error'); return }
      row._saving = true
      try {
        const res = await fetch(`${API}/${row.id}`, {
          method:  'PUT',
          headers: { 'Content-Type': 'application/json' },
          body:    JSON.stringify({ nome })
        })
        if (!res.ok) throw new Error()
        row.nome     = nome
        row._editing = false
        row._saving  = false
        this.showToast('Unidade atualizada!', 'success')
      } catch {
        row._saving = false
        this.showToast('Erro ao atualizar unidade.', 'error')
      }
    },

    async deletarConfirmado() {
      this.confirm.visible = false
      const id = this.confirm.id
      try {
        const res = await fetch(`${API}/${id}`, { method: 'DELETE' })
        if (!res.ok) throw new Error()
        this.rows = this.rows.filter(r => r.id !== id)
        this.showToast('Unidade excluída.', 'success')
      } catch {
        this.showToast('Erro ao excluir unidade.', 'error')
      }
    },

    adicionarLinha() {
      this.novaLinha = { nome: '' }
      this.$nextTick(() => {
        if (this.$refs.novoNomeInput) this.$refs.novoNomeInput.focus()
      })
    },

    cancelarNova() { this.novaLinha = null },

    iniciarEdicao(row) {
      this.rows.forEach(r => { r._editing = false })
      row._draft   = row.nome
      row._editing = true
    },

    cancelarEdicao(row) { row._editing = false },

    confirmarDelecao(row) {
      this.confirm = { visible: true, nome: row.nome, id: row.id }
    },

    sortBy(key) {
      if (this.sortKey === key) this.sortDir = this.sortDir === 'asc' ? 'desc' : 'asc'
      else { this.sortKey = key; this.sortDir = 'asc' }
    },

    sortIcon(key) {
      if (this.sortKey !== key) return '⇅'
      return this.sortDir === 'asc' ? '↑' : '↓'
    },

    showToast(message, type = 'success') {
      this.toast = { visible: true, message, type }
      setTimeout(() => { this.toast.visible = false }, 3200)
    }
  }
}
</script>

<style scoped>
.unidades-page { max-width: 860px; margin: 0 auto; }

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 12px;
}
.page-title { display: flex; align-items: center; gap: 14px; }
.page-icon  { font-size: 2.2rem; }
.page-title h1 { font-size: 1.6rem; font-weight: 700; color: #2c3e50; margin: 0; }
.page-title p  { font-size: 0.85rem; color: #95a5a6; margin: 2px 0 0; }

.btn-new {
  padding: 10px 22px;
  background: #42b983;
  color: #fff;
  border: none;
  border-radius: 7px;
  font-size: 0.92rem;
  font-weight: 700;
  cursor: pointer;
  transition: background .2s, transform .1s;
  white-space: nowrap;
}
.btn-new:hover  { background: #369870; }
.btn-new:active { transform: scale(0.97); }

.loading-wrap {
  display: flex; align-items: center; justify-content: center;
  gap: 14px; padding: 60px; color: #7f8c8d; font-size: 0.95rem;
}
.spinner {
  width: 28px; height: 28px;
  border: 3px solid #ddd; border-top-color: #42b983;
  border-radius: 50%;
  animation: spin .7s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

.table-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.08);
  overflow: hidden;
}

.table-toolbar {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px 20px; border-bottom: 1px solid #f0f0f0;
  flex-wrap: wrap; gap: 10px;
}
.search-input {
  padding: 8px 14px;
  border: 1.5px solid #e0e0e0; border-radius: 7px;
  font-size: 0.9rem; width: 240px; outline: none;
  transition: border-color .2s;
}
.search-input:focus { border-color: #42b983; }
.total-badge {
  font-size: 0.82rem; 
  color: #95a5a6;
  background: #f5f5f5; 
  padding: 4px 12px; 
  border-radius: 20px;
}

.table-wrapper { overflow-x: auto; }


.data-table { width: 100%; border-collapse: collapse; font-size: 0.92rem; }

.data-table thead tr { background: #f8f9fa; }
.data-table th {
  padding: 13px 16px; text-align: left;
  font-size: 0.78rem; font-weight: 700;
  text-transform: uppercase; letter-spacing: .06em;
  color: #95a5a6; border-bottom: 2px solid #ecf0f1;
  cursor: pointer; user-select: none; white-space: nowrap;
}
.data-table th:hover { color: #2c3e50; }
.sort-icon { font-size: 0.75rem; margin-left: 4px; }

.data-table td {
  padding: 11px 16px; border-bottom: 1px solid #f4f4f4;
  color: #34495e; vertical-align: middle;
}
.data-table tbody tr { transition: background .15s; }
.data-table tbody tr:hover { background: #fafffe; }
.data-table tbody tr:last-child td { border-bottom: none; }

.col-id    { width: 80px; }
.col-acoes { width: 110px; text-align: center; }


.row-new     { background: #f0fff8 !important; }
.row-editing { background: #fffdf0 !important; }
.row-saving  { opacity: .6; pointer-events: none; }

.cell-input {
  width: 100%; padding: 6px 10px;
  border: 1.5px solid #42b983; border-radius: 5px;
  font-size: 0.92rem; outline: none; background: #fff; color: #2c3e50;
  box-shadow: 0 0 0 3px rgba(66,185,131,.12);
}
.cell-text {
  display: block; cursor: text;
  border-radius: 4px; padding: 2px 4px;
  transition: background .15s;
}
.cell-text:hover { background: #f0fff8; }

.col-acoes button {
  width: 32px; height: 32px;
  border: none; border-radius: 6px;
  cursor: pointer; font-size: 0.88rem;
  transition: background .2s, transform .1s;
  margin: 0 2px;
}
.col-acoes button:active { transform: scale(0.92); }
.btn-edit        { background: #eaf7f1; }
.btn-edit:hover  { background: #d0f0e2; }
.btn-delete      { background: #fdecea; }
.btn-delete:hover{ background: #f9c9c5; }
.btn-save        { background: #42b983; color: #fff; font-weight: 700; font-size: 1rem; }
.btn-save:hover  { background: #369870; }
.btn-cancel-row        { background: #ecf0f1; color: #7f8c8d; font-size: 1rem; }
.btn-cancel-row:hover  { background: #d5dbdb; }


.empty-state { text-align: center; color: #bdc3c7; font-style: italic; padding: 40px !important; }
.hint { margin-top: 14px; font-size: 0.8rem; color: #bdc3c7; text-align: center; }

 .btn-clear {
  padding: 8px 16px;
  border: none;
  border-radius: 7px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-clear {
  background: #ecf0f1;
  color: #7f8c8d;
}
.btn-clear:hover {
  background: #d5dbdb;
}
</style>