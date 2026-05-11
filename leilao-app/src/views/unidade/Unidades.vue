<template>
  <div class="unidades-page container">
    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />
    <ConfirmDialog
      :visible="confirm.visible"
      title="Excluir Unidade"
      :message="`Deseja excluir '${confirm.nome}'? Esta ação não pode ser desfeita.`"
      @confirm="deletarConfirmado"
      @cancel="confirm.visible = false"
    />

    <div class="page-header animate-fade">
      <div>
        <h1 class="page-title">Unidades de Medida</h1>
        <p class="page-subtitle">Gerencie as unidades utilizadas nos produtos e lotes</p>
      </div>
      <div class="header-actions">
        <div class="stat-badge">
          <span class="stat-number">{{ rows.length }}</span>
          <span class="stat-text">unidades cadastradas</span>
        </div>
        <AppButton variant="primary" @click="adicionarLinha" size="lg">
          ➕ Nova Unidade
        </AppButton>
      </div>
    </div>

    <LoadingSkeleton v-if="loading" type="table" :rows="5" :columns="3" />

    <AppCard v-else class="animate-fade">
      <div class="toolbar">
        <div class="search-section">
          <div class="search-wrapper">
            <span class="search-icon">🔍</span>
            <input
              v-model="busca"
              type="text"
              class="search-input-custom"
              placeholder="Buscar unidade por nome ou ID..."
              @input="paginaAtual = 1"
            />
          </div>
        </div>
        <div class="view-options">
          <button 
            @click="modoVisualizacao = 'tabela'" 
            :class="['view-btn', { active: modoVisualizacao === 'tabela' }]"
            title="Visualização em tabela"
          >
            📊 Tabela
          </button>
          <button 
            @click="modoVisualizacao = 'cards'" 
            :class="['view-btn', { active: modoVisualizacao === 'cards' }]"
            title="Visualização em cards"
          >
            🃏 Cards
          </button>
        </div>
      </div>

      <div v-if="modoVisualizacao === 'tabela'" class="table-container">
        <table class="modern-table">
          <thead>
            <tr>
              <th @click="sortBy('id')" class="sortable col-id">
                ID <span class="sort-icon">{{ sortIcon('id') }}</span>
              </th>
              <th @click="sortBy('nome')" class="sortable">
                Nome da Unidade <span class="sort-icon">{{ sortIcon('nome') }}</span>
              </th>
              <th class="text-right">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="novaLinha" class="row-new">
              <td class="col-id">
                <span class="badge-new">NOVO</span>
              </td>
              <td>
                <div class="inline-edit">
                  <input
                    ref="novoNomeInput"
                    v-model="novaLinha.nome"
                    class="inline-input"
                    placeholder="Digite o nome da unidade..."
                    @keyup.enter="salvarNova"
                    @keyup.esc="cancelarNova"
                    autofocus
                  />
                </div>
              </td>
              <td class="text-right">
                <div class="action-buttons">
                  <button class="action-btn save" @click="salvarNova" title="Salvar (Enter)">
                    ✓ Salvar
                  </button>
                  <button class="action-btn cancel" @click="cancelarNova" title="Cancelar (Esc)">
                    ✕ Cancelar
                  </button>
                </div>
              </td>
            </tr>

            <tr
              v-for="row in paginatedRows"
              :key="row.id"
              :class="{ 'row-editing': row._editing, 'row-saving': row._saving }"
              class="table-row"
            >
              <td class="col-id">
                <span class="id-badge">#{{ row.id }}</span>
              </td>
              <td>
                <div v-if="row._editing" class="inline-edit">
                  <input
                    v-model="row._draft"
                    class="inline-input"
                    @keyup.enter="salvarEdicao(row)"
                    @keyup.esc="cancelarEdicao(row)"
                    @blur="salvarEdicao(row)"
                    autofocus
                  />
                </div>
                <div v-else class="unit-name" @dblclick="iniciarEdicao(row)">
                  <span class="unit-icon">📦</span>
                  <span class="unit-text">{{ row.nome }}</span>
                  <span class="edit-hint">✏️</span>
                </div>
              </td>
              <td class="text-right">
                <div class="action-buttons">
                  <template v-if="row._editing">
                    <button class="action-btn save" @click="salvarEdicao(row)" title="Salvar">
                      ✓ Salvar
                    </button>
                    <button class="action-btn cancel" @click="cancelarEdicao(row)" title="Cancelar">
                      ✕ Cancelar
                    </button>
                  </template>
                  <template v-else>
                    <button class="action-btn edit" @click="iniciarEdicao(row)" title="Editar (duplo clique)">
                      ✏️ Editar
                    </button>
                    <button class="action-btn delete" @click="confirmarDelecao(row)" title="Excluir">
                      🗑️ Excluir
                    </button>
                  </template>
                </div>
              </td>
            </tr>

            <tr v-if="filteredRows.length === 0 && !novaLinha">
              <td colspan="3" class="empty-state">
                <div class="empty-state-content">
                  <span class="empty-icon">📦</span>
                  <p>Nenhuma unidade encontrada</p>
                  <AppButton variant="primary" size="sm" @click="adicionarLinha">
                    Cadastrar primeira unidade
                  </AppButton>
                </div>
              </td>
            </tr>
          </tbody>
        </table>

        <div v-if="totalPages > 1" class="pagination">
          <button @click="paginaAtual--" :disabled="paginaAtual === 1" class="page-btn">
            ← Anterior
          </button>
          <div class="page-info">
            <span class="page-current">{{ paginaAtual }}</span>
            <span class="page-separator">/</span>
            <span class="page-total">{{ totalPages }}</span>
          </div>
          <button @click="paginaAtual++" :disabled="paginaAtual === totalPages" class="page-btn">
            Próxima →
          </button>
        </div>
      </div>

      <div v-else class="cards-grid">
        <div v-if="novaLinha" class="unit-card card-new">
          <div class="card-header">
            <div class="card-icon">✨</div>
            <h3>Nova Unidade</h3>
          </div>
          <div class="card-body">
            <input
              v-model="novaLinha.nome"
              class="card-input"
              placeholder="Nome da unidade"
              @keyup.enter="salvarNova"
              @keyup.esc="cancelarNova"
            />
          </div>
          <div class="card-footer">
            <button class="card-btn save" @click="salvarNova">✓ Salvar</button>
            <button class="card-btn cancel" @click="cancelarNova">✕ Cancelar</button>
          </div>
        </div>

        <div
          v-for="row in paginatedRows"
          :key="row.id"
          class="unit-card"
          :class="{ 'card-editing': row._editing }"
        >
          <div class="card-header">
            <div class="card-icon">📦</div>
            <div class="card-id">#{{ row.id }}</div>
          </div>
          <div class="card-body">
            <div v-if="row._editing" class="card-edit">
              <input
                v-model="row._draft"
                class="card-input"
                @keyup.enter="salvarEdicao(row)"
                @keyup.esc="cancelarEdicao(row)"
              />
            </div>
            <div v-else class="card-display">
              <h3 class="card-title">{{ row.nome }}</h3>
            </div>
          </div>
          <div class="card-footer">
            <template v-if="row._editing">
              <button class="card-btn save" @click="salvarEdicao(row)">✓ Salvar</button>
              <button class="card-btn cancel" @click="cancelarEdicao(row)">✕ Cancelar</button>
            </template>
            <template v-else>
              <button class="card-btn edit" @click="iniciarEdicao(row)">✏️ Editar</button>
              <button class="card-btn delete" @click="confirmarDelecao(row)">🗑️ Excluir</button>
            </template>
          </div>
        </div>

        <div v-if="filteredRows.length === 0 && !novaLinha" class="empty-cards">
          <div class="empty-state-content">
            <span class="empty-icon">📦</span>
            <p>Nenhuma unidade encontrada</p>
          </div>
        </div>
      </div>
    </AppCard>

    <div class="hint-bar">
      <span class="hint-icon">💡</span>
      <span class="hint-text">Dica: Clique duas vezes em qualquer unidade para editá-la rapidamente</span>
    </div>
  </div>
</template>

<script>
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import ToastNotification from '@/components/ToastNotification.vue'
import AppCard from '@/components/ui/AppCard.vue'
import AppButton from '@/components/ui/AppButton.vue'
import LoadingSkeleton from '@/components/ui/LoadingSkeleton.vue'

const API = 'http://localhost:8081/unidade'

export default {
  name: 'Unidades',
  components: { ConfirmDialog, ToastNotification, AppCard, AppButton, LoadingSkeleton },

  data() {
    return {
      rows: [],
      loading: true,
      busca: '',
      novaLinha: null,
      sortKey: 'id',
      sortDir: 'asc',
      modoVisualizacao: 'tabela',
      paginaAtual: 1,
      itensPorPagina: 10,
      toast: { visible: false, message: '', type: 'success' },
      confirm: { visible: false, nome: '', id: null }
    }
  },

  computed: {
    filteredRows() {
      let list = [...this.rows]
      
      if (this.busca) {
        const q = this.busca.toLowerCase()
        list = list.filter(r => 
          String(r.id).includes(q) || 
          r.nome.toLowerCase().includes(q)
        )
      }
      
      list = [...list].sort((a, b) => {
        let va = a[this.sortKey]
        let vb = b[this.sortKey]
        
        if (typeof va === 'string') {
          va = va.toLowerCase()
          vb = vb.toLowerCase()
        }
        
        if (va === vb) return 0
        const cmp = va < vb ? -1 : 1
        return this.sortDir === 'asc' ? cmp : -cmp
      })
      
      return list
    },
    
    paginatedRows() {
      const start = (this.paginaAtual - 1) * this.itensPorPagina
      const end = start + this.itensPorPagina
      return this.filteredRows.slice(start, end)
    },
    
    totalPages() {
      return Math.ceil(this.filteredRows.length / this.itensPorPagina)
    }
  },

  watch: {
    filteredRows() {
      this.paginaAtual = 1
    },
    
    busca() {
      this.paginaAtual = 1
    }
  },

  mounted() {
    this.buscarTodos()
  },

  methods: {
    async buscarTodos() {
      this.loading = true
      try {
        const res = await fetch(API)
        const data = await res.json()
        this.rows = data.map(u => ({ 
          ...u, 
          _editing: false, 
          _draft: '', 
          _saving: false 
        }))
        this.showToast(`${data.length} unidades carregadas`, 'success')
      } catch {
        this.showToast('Erro ao carregar unidades.', 'error')
      } finally {
        this.loading = false
      }
    },

    async salvarNova() {
      const nome = (this.novaLinha.nome || '').trim()
      if (!nome) { 
        this.showToast('Informe o nome da unidade.', 'error')
        return 
      }
      
      try {
        const res = await fetch(API, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ nome })
        })
        if (!res.ok) throw new Error()
        
        const criado = await res.json()
        this.rows.unshift({ ...criado, _editing: false, _draft: '', _saving: false })
        this.novaLinha = null
        this.showToast(`Unidade "${nome}" criada com sucesso!`, 'success')
      } catch {
        this.showToast('Erro ao criar unidade.', 'error')
      }
    },

    async salvarEdicao(row) {
      const nome = (row._draft || '').trim()
      if (!nome) { 
        this.showToast('O nome não pode ser vazio.', 'error')
        return 
      }
      
      row._saving = true
      try {
        const res = await fetch(`${API}/${row.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ nome })
        })
        if (!res.ok) throw new Error()
        
        row.nome = nome
        row._editing = false
        row._saving = false
        this.showToast(`Unidade atualizada para "${nome}"`, 'success')
      } catch {
        row._saving = false
        this.showToast('Erro ao atualizar unidade.', 'error')
      }
    },

    async deletarConfirmado() {
      this.confirm.visible = false
      const id = this.confirm.id
      const nome = this.confirm.nome
      
      try {
        const res = await fetch(`${API}/${id}`, { method: 'DELETE' })
        if (!res.ok) throw new Error()
        
        this.rows = this.rows.filter(r => r.id !== id)
        this.showToast(`Unidade "${nome}" excluída.`, 'success')
      } catch {
        this.showToast('Erro ao excluir unidade.', 'error')
      }
    },

    adicionarLinha() {
      this.novaLinha = { nome: '' }
      this.$nextTick(() => {
        if (this.$refs.novoNomeInput) {
          this.$refs.novoNomeInput.focus()
        }
      })
    },

    cancelarNova() { 
      this.novaLinha = null 
    },

    iniciarEdicao(row) {
      this.rows.forEach(r => { 
        if (r.id !== row.id) r._editing = false 
      })
      row._draft = row.nome
      row._editing = true
    },

    cancelarEdicao(row) { 
      row._editing = false 
    },

    confirmarDelecao(row) {
      this.confirm = { visible: true, nome: row.nome, id: row.id }
    },

    sortBy(key) {
      if (this.sortKey === key) {
        this.sortDir = this.sortDir === 'asc' ? 'desc' : 'asc'
      } else {
        this.sortKey = key
        this.sortDir = 'asc'
      }
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
.unidades-page {
  animation: fadeIn 0.5s ease;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: var(--spacing-lg);
  margin-bottom: var(--spacing-xl);
  flex-wrap: wrap;
  gap: var(--spacing-md);
}

.page-title {
  font-size: 2rem;
  font-weight: 700;
  background: linear-gradient(135deg, var(--primary), var(--secondary));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: var(--spacing-xs);
}

.page-subtitle {
  color: var(--gray-600);
}

.header-actions {
  display: flex;
  gap: var(--spacing-md);
  align-items: center;
}

.stat-badge {
  background: linear-gradient(135deg, var(--primary-light), var(--primary));
  padding: var(--spacing-sm) var(--spacing-lg);
  border-radius: var(--radius-lg);
  text-align: center;
  color: white;
}

.stat-number {
  display: block;
  font-size: 1.5rem;
  font-weight: 700;
  line-height: 1;
}

.stat-text {
  font-size: 0.75rem;
  opacity: 0.9;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-lg);
  gap: var(--spacing-md);
  flex-wrap: wrap;
}

.search-section {
  flex: 1;
  max-width: 400px;
}

.search-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 12px;
  font-size: 1rem;
  pointer-events: none;
  z-index: 1;
  opacity: 0.6;
}

.search-input-custom {
  width: 100%;
  padding: 10px 12px 10px 36px;
  border: 1.5px solid var(--gray-200);
  border-radius: var(--radius-md);
  font-size: 0.9375rem;
  transition: all 0.2s;
  background: white;
}

.search-input-custom:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.view-options {
  display: flex;
  gap: var(--spacing-xs);
  background: var(--gray-100);
  padding: 4px;
  border-radius: var(--radius-md);
}

.view-btn {
  padding: var(--spacing-sm) var(--spacing-md);
  border: none;
  background: transparent;
  cursor: pointer;
  border-radius: var(--radius-sm);
  font-size: 0.875rem;
  transition: all 0.2s;
}

.view-btn.active {
  background: white;
  box-shadow: var(--shadow-sm);
  color: var(--primary);
}

.view-btn:hover:not(.active) {
  background: var(--gray-200);
}

.table-container {
  overflow-x: auto;
}

.modern-table {
  width: 100%;
  border-collapse: collapse;
}

.modern-table th {
  text-align: left;
  padding: var(--spacing-md);
  background: var(--gray-50);
  font-weight: 600;
  font-size: 0.875rem;
  color: var(--gray-600);
  border-bottom: 2px solid var(--gray-200);
}

.sortable {
  cursor: pointer;
  user-select: none;
  transition: color 0.2s;
}

.sortable:hover {
  color: var(--primary);
}

.sort-icon {
  margin-left: var(--spacing-xs);
  font-size: 0.75rem;
}

.modern-table td {
  padding: var(--spacing-md);
  border-bottom: 1px solid var(--gray-200);
  transition: background 0.2s;
}

.table-row:hover {
  background: var(--gray-50);
}

.col-id {
  width: 100px;
}

.id-badge {
  display: inline-block;
  padding: 4px 8px;
  background: var(--gray-100);
  border-radius: var(--radius-sm);
  font-family: monospace;
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--gray-700);
}

.badge-new {
  display: inline-block;
  padding: 4px 8px;
  background: var(--secondary);
  border-radius: var(--radius-sm);
  font-size: 0.75rem;
  font-weight: 700;
  color: white;
}

.unit-name {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  cursor: pointer;
  padding: var(--spacing-xs);
  border-radius: var(--radius-sm);
  transition: all 0.2s;
}

.unit-name:hover {
  background: var(--gray-100);
}

.unit-name:hover .edit-hint {
  opacity: 1;
}

.unit-icon {
  font-size: 1.2rem;
}

.unit-text {
  font-weight: 500;
}

.edit-hint {
  margin-left: auto;
  font-size: 0.75rem;
  opacity: 0;
  transition: opacity 0.2s;
  color: var(--gray-400);
}

.inline-edit {
  width: 100%;
}

.inline-input {
  width: 100%;
  padding: var(--spacing-sm);
  border: 2px solid var(--primary);
  border-radius: var(--radius-md);
  font-size: 0.9375rem;
  outline: none;
  transition: all 0.2s;
}

.inline-input:focus {
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.action-buttons {
  display: flex;
  gap: var(--spacing-xs);
  justify-content: flex-end;
}

.action-btn {
  padding: var(--spacing-sm) var(--spacing-md);
  border: none;
  cursor: pointer;
  border-radius: var(--radius-sm);
  font-size: 0.875rem;
  transition: all 0.2s;
}

.action-btn.save {
  background: var(--secondary);
  color: white;
}

.action-btn.save:hover {
  background: var(--secondary-dark);
  transform: scale(1.05);
}

.action-btn.edit {
  background: var(--primary-light);
  color: white;
}

.action-btn.edit:hover {
  background: var(--primary);
  transform: scale(1.05);
}

.action-btn.delete {
  background: var(--danger);
  color: white;
}

.action-btn.delete:hover {
  background: #c0392b;
  transform: scale(1.05);
}

.action-btn.cancel {
  background: var(--gray-300);
  color: var(--gray-700);
}

.action-btn.cancel:hover {
  background: var(--gray-400);
  transform: scale(1.05);
}

.row-new {
  background: linear-gradient(90deg, rgba(16, 185, 129, 0.05), transparent);
}

.row-editing {
  background: linear-gradient(90deg, rgba(99, 102, 241, 0.05), transparent);
}

.row-saving {
  opacity: 0.6;
  pointer-events: none;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: var(--spacing-md);
  margin-top: var(--spacing-lg);
  padding: var(--spacing-md);
}

.page-btn {
  padding: var(--spacing-sm) var(--spacing-md);
  border: 1px solid var(--gray-300);
  background: white;
  cursor: pointer;
  border-radius: var(--radius-md);
  transition: all 0.2s;
}

.page-btn:hover:not(:disabled) {
  background: var(--primary);
  color: white;
  border-color: var(--primary);
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  font-size: 0.875rem;
}

.page-current {
  font-weight: 700;
  color: var(--primary);
  font-size: 1rem;
}

.page-separator {
  color: var(--gray-400);
}

.page-total {
  color: var(--gray-600);
}

.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: var(--spacing-lg);
}

.unit-card {
  background: white;
  border-radius: var(--radius-lg);
  overflow: hidden;
  transition: all 0.3s;
  box-shadow: var(--shadow-sm);
}

.unit-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.card-new {
  background: linear-gradient(135deg, var(--secondary-light), var(--secondary));
  color: white;
}

.card-new .card-header h3 {
  color: white;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-md);
  background: var(--gray-50);
  border-bottom: 1px solid var(--gray-200);
}

.card-icon {
  font-size: 2rem;
}

.card-id {
  font-family: monospace;
  font-size: 0.875rem;
  color: var(--gray-500);
}

.card-body {
  padding: var(--spacing-lg);
}

.card-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0;
  text-align: center;
}

.card-input {
  width: 100%;
  padding: var(--spacing-md);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: var(--radius-md);
  font-size: 1rem;
  background: rgba(255, 255, 255, 0.9);
  transition: all 0.2s;
}

.card-input:focus {
  outline: none;
  border-color: white;
  background: white;
}

.card-footer {
  display: flex;
  gap: var(--spacing-sm);
  padding: var(--spacing-md);
  background: var(--gray-50);
  border-top: 1px solid var(--gray-200);
}

.card-btn {
  flex: 1;
  padding: var(--spacing-sm);
  border: none;
  cursor: pointer;
  border-radius: var(--radius-sm);
  font-size: 0.875rem;
  transition: all 0.2s;
}

.card-btn.save {
  background: var(--secondary);
  color: white;
}

.card-btn.save:hover {
  background: var(--secondary-dark);
}

.card-btn.edit {
  background: var(--primary);
  color: white;
}

.card-btn.edit:hover {
  background: var(--primary-dark);
}

.card-btn.delete {
  background: var(--danger);
  color: white;
}

.card-btn.delete:hover {
  background: #c0392b;
}

.card-btn.cancel {
  background: var(--gray-300);
  color: var(--gray-700);
}

.card-btn.cancel:hover {
  background: var(--gray-400);
}

.empty-state {
  text-align: center;
  padding: var(--spacing-2xl) !important;
}

.empty-state-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-md);
}

.empty-icon {
  font-size: 4rem;
  opacity: 0.5;
}

.hint-bar {
  margin-top: var(--spacing-lg);
  padding: var(--spacing-md);
  background: var(--gray-100);
  border-radius: var(--radius-lg);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-sm);
}

.hint-icon {
  font-size: 1.2rem;
}

.hint-text {
  font-size: 0.875rem;
  color: var(--gray-600);
}

.text-right {
  text-align: right;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .header-actions {
    width: 100%;
    justify-content: space-between;
  }
  
  .toolbar {
    flex-direction: column;
  }
  
  .search-section {
    max-width: 100%;
    width: 100%;
  }
  
  .view-options {
    width: 100%;
    justify-content: center;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .cards-grid {
    grid-template-columns: 1fr;
  }
}
</style>