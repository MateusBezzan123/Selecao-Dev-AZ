<template>
  <div class="empresas-page container">
    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />
    <ConfirmDialog
      :visible="confirm.visible"
      title="Excluir Empresa"
      :message="`Deseja excluir '${confirm.nome}'? Esta ação não pode ser desfeita.`"
      @confirm="deletarConfirmado"
      @cancel="confirm.visible = false"
    />

    <Modal 
      :visible="modalVisible" 
      @update:visible="modalVisible = $event"
      :title="`Detalhes da Empresa`"
      size="lg"
    >
      <div v-if="empresaSelecionada" class="modal-details">
        <div class="company-header">
          <div class="company-avatar">🏢</div>
          <div class="company-name-detail">
            <h2>{{ empresaSelecionada.razaoSocial }}</h2>
            <span class="company-id">ID: {{ empresaSelecionada.id }}</span>
          </div>
        </div>
        
        <div class="details-grid">
          <div class="detail-group">
            <label>CNPJ</label>
            <p class="detail-value">{{ formatarCNPJ(empresaSelecionada.cnpj) }}</p>
          </div>
          <div class="detail-group">
            <label>Telefone</label>
            <p class="detail-value">{{ formatarTelefone(empresaSelecionada.telefone) || '—' }}</p>
          </div>
          <div class="detail-group">
            <label>E-mail</label>
            <p class="detail-value">
              <a :href="`mailto:${empresaSelecionada.email}`" v-if="empresaSelecionada.email">
                {{ empresaSelecionada.email }}
              </a>
              <span v-else>—</span>
            </p>
          </div>
          <div class="detail-group">
            <label>Site</label>
            <p class="detail-value">
              <a :href="empresaSelecionada.site" target="_blank" v-if="empresaSelecionada.site">
                {{ empresaSelecionada.site }}
              </a>
              <span v-else>—</span>
            </p>
          </div>
        </div>
        
        <div class="address-section">
          <h4>📍 Endereço</h4>
          <div class="details-grid">
            <div class="detail-group">
              <label>CEP</label>
              <p class="detail-value">{{ empresaSelecionada.cep || '—' }}</p>
            </div>
            <div class="detail-group full-width">
              <label>Logradouro</label>
              <p class="detail-value">{{ empresaSelecionada.logradouro || '—' }}, {{ empresaSelecionada.numero || 'S/N' }}</p>
            </div>
            <div class="detail-group">
              <label>Complemento</label>
              <p class="detail-value">{{ empresaSelecionada.complemento || '—' }}</p>
            </div>
            <div class="detail-group">
              <label>Bairro</label>
              <p class="detail-value">{{ empresaSelecionada.bairro || '—' }}</p>
            </div>
            <div class="detail-group">
              <label>Cidade/UF</label>
              <p class="detail-value">{{ empresaSelecionada.municipio || '—' }}{{ empresaSelecionada.uf ? `/${empresaSelecionada.uf}` : '' }}</p>
            </div>
          </div>
        </div>
      </div>
      
      <template #footer>
        <button @click="modalVisible = false" class="modal-close-btn">Fechar</button>
        <button @click="editarEmpresa(empresaSelecionada.id)" class="modal-edit-btn">✏️ Editar Empresa</button>
      </template>
    </Modal>

    <div class="page-header animate-fade">
      <div>
        <h1 class="page-title">Empresas</h1>
        <p class="page-subtitle">Gerencie todas as empresas parceiras</p>
      </div>
      <div class="header-actions">
        <div class="stat-badge">
          <span class="stat-number">{{ rows.length }}</span>
          <span class="stat-text">empresas ativas</span>
        </div>
        <AppButton variant="primary" @click="irParaNovaEmpresa" size="lg">
          ➕ Nova Empresa
        </AppButton>
      </div>
    </div>

    <LoadingSkeleton v-if="loading" type="table" :rows="5" :columns="5" />

    <AppCard v-else class="animate-fade">
      <div class="toolbar">
        <div class="search-section">
          <div class="search-wrapper">
            <span class="search-icon">🔍</span>
            <input
              v-model="searchTerm"
              type="text"
              class="search-input-custom"
              placeholder="Buscar empresas por nome, CNPJ ou e-mail..."
              @input="paginaAtual = 1"
            />
          </div>
          <AppButton variant="outline" @click="alternarFiltros" size="md">
            {{ mostrarFiltros ? 'Ocultar filtros ▲' : 'Mostrar filtros ▼' }}
          </AppButton>
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
          
          <!-- Botão de Exportação -->
          <ExportButton
            :data="filteredRows"
            :columns="exportColumns"
            filename="empresas"
            title="Relatório de Empresas"
            @toast="showToastMessage"
          />
        </div>
      </div>

      <transition name="slide">
        <div v-if="mostrarFiltros" class="filters-panel">
          <div class="filters-grid">
            <div class="filter-group">
              <label class="filter-label">CNPJ</label>
              <input v-model="filtros.cnpj" class="filter-input" placeholder="Digite o CNPJ" />
            </div>
            <div class="filter-group">
              <label class="filter-label">Razão Social</label>
              <input v-model="filtros.razaoSocial" class="filter-input" placeholder="Digite a razão social" />
            </div>
            <div class="filter-group">
              <label class="filter-label">Telefone</label>
              <input v-model="filtros.telefone" class="filter-input" placeholder="Digite o telefone" />
            </div>
            <div class="filter-group">
              <label class="filter-label">E-mail</label>
              <input v-model="filtros.email" class="filter-input" placeholder="Digite o e-mail" />
            </div>
            <div class="filter-group">
              <label class="filter-label">Cidade</label>
              <input v-model="filtros.cidade" class="filter-input" placeholder="Digite a cidade" />
            </div>
          </div>
          <div class="filters-actions">
            <AppButton variant="outline" @click="limparFiltros" size="sm">
              🗑️ Limpar todos
            </AppButton>
            <span class="filter-result">{{ filteredRows.length }} resultados</span>
          </div>
        </div>
      </transition>

      <div v-if="modoVisualizacao === 'tabela'" class="table-container">
        <table class="modern-table">
          <thead>
            <tr>
              <th @click="sortBy('cnpj')" class="sortable">
                CNPJ <span class="sort-icon">{{ sortIcon('cnpj') }}</span>
              </th>
              <th @click="sortBy('razaoSocial')" class="sortable">
                Razão Social <span class="sort-icon">{{ sortIcon('razaoSocial') }}</span>
              </th>
              <th @click="sortBy('telefone')" class="sortable">
                Telefone <span class="sort-icon">{{ sortIcon('telefone') }}</span>
              </th>
              <th @click="sortBy('email')" class="sortable">
                E-mail <span class="sort-icon">{{ sortIcon('email') }}</span>
              </th>
              <th @click="sortBy('municipio')" class="sortable">
                Cidade <span class="sort-icon">{{ sortIcon('municipio') }}</span>
              </th>
              <th class="text-right">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedRows" :key="row.id" class="table-row">
              <td>
                <span class="cnpj-badge">{{ formatarCNPJ(row.cnpj) }}</span>
              </td>
              <td class="company-name">{{ row.razaoSocial }}</td>
              <td>{{ formatarTelefone(row.telefone) }}</td>
              <td>
                <a :href="`mailto:${row.email}`" class="email-link" v-if="row.email">
                  {{ row.email }}
                </a>
                <span v-else class="empty-value">—</span>
              </td>
              <td>
                <span class="city-badge">
                  📍 {{ row.municipio || 'Não informado' }}
                </span>
              </td>
              <td class="text-right">
                <div class="action-buttons">
                  <button class="action-btn edit" @click="editarEmpresa(row.id)" title="Editar">
                    ✏️
                  </button>
                  <button class="action-btn view" @click="verDetalhes(row)" title="Visualizar">
                    👁️
                  </button>
                  <button class="action-btn delete" @click="confirmarDelecao(row)" title="Excluir">
                    🗑️
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="filteredRows.length === 0">
              <td colspan="6" class="empty-state">
                <div class="empty-state-content">
                  <span class="empty-icon">🏢</span>
                  <p>Nenhuma empresa encontrada</p>
                  <AppButton variant="primary" size="sm" @click="irParaNovaEmpresa">
                    Cadastrar primeira empresa
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
        <div 
          v-for="row in paginatedRows" 
          :key="row.id" 
          class="company-card"
          @click="verDetalhes(row)"
        >
          <div class="card-header">
            <div class="card-icon">🏢</div>
            <div class="card-actions">
              <button @click.stop="editarEmpresa(row.id)" class="card-action" title="Editar">
                ✏️
              </button>
              <button @click.stop="confirmarDelecao(row)" class="card-action" title="Excluir">
                🗑️
              </button>
            </div>
          </div>
          <div class="card-body">
            <h3 class="card-title">{{ row.razaoSocial }}</h3>
            <div class="card-info">
              <span class="info-label">CNPJ:</span>
              <span>{{ formatarCNPJ(row.cnpj) }}</span>
            </div>
            <div class="card-info" v-if="row.telefone">
              <span class="info-label">📞:</span>
              <span>{{ formatarTelefone(row.telefone) }}</span>
            </div>
            <div class="card-info" v-if="row.email">
              <span class="info-label">📧:</span>
              <span class="email-text">{{ row.email }}</span>
            </div>
            <div class="card-info" v-if="row.municipio">
              <span class="info-label">📍:</span>
              <span>{{ row.municipio }}{{ row.uf ? `/${row.uf}` : '' }}</span>
            </div>
          </div>
          <div class="card-footer">
            <span class="badge-id">ID: {{ row.id }}</span>
          </div>
        </div>
        
        <div v-if="filteredRows.length === 0" class="empty-cards">
          <div class="empty-state-content">
            <span class="empty-icon">🏢</span>
            <p>Nenhuma empresa encontrada</p>
          </div>
        </div>
      </div>
    </AppCard>
  </div>
</template>

<script>
import ToastNotification from '@/components/ToastNotification.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import AppCard from '@/components/ui/AppCard.vue'
import AppButton from '@/components/ui/AppButton.vue'
import LoadingSkeleton from '@/components/ui/LoadingSkeleton.vue'
import Modal from '@/components/ui/Modal.vue'
import ExportButton from '@/components/ui/ExportButton.vue'

const API = 'http://localhost:8081/empresa'

export default {
  name: 'Empresas',
  components: { 
    ToastNotification, 
    ConfirmDialog, 
    AppCard, 
    AppButton, 
    LoadingSkeleton, 
    Modal,
    ExportButton
  },

  data() {
    return {
      rows: [],
      loading: true,
      sortKey: 'razaoSocial',
      sortDir: 'asc',
      searchTerm: '',
      mostrarFiltros: false,
      modoVisualizacao: 'tabela',
      paginaAtual: 1,
      itensPorPagina: 10,
      toast: { visible: false, message: '', type: 'success' },
      confirm: { visible: false, nome: '', id: null },
      filtros: { cnpj: '', razaoSocial: '', telefone: '', email: '', cidade: '' },
      modalVisible: false,
      empresaSelecionada: null
    }
  },

  computed: {
    filteredRows() {
      let list = [...this.rows]
      
      if (this.searchTerm) {
        const term = this.searchTerm.toLowerCase()
        list = list.filter(r => 
          r.razaoSocial.toLowerCase().includes(term) ||
          (r.cnpj && r.cnpj.includes(term)) ||
          (r.email && r.email.toLowerCase().includes(term))
        )
      }
      
      if (this.filtros.cnpj) {
        const q = this.filtros.cnpj.replace(/\D/g, '')
        list = list.filter(r => (r.cnpj || '').replace(/\D/g, '').includes(q))
      }
      if (this.filtros.razaoSocial) {
        const q = this.filtros.razaoSocial.toLowerCase()
        list = list.filter(r => (r.razaoSocial || '').toLowerCase().includes(q))
      }
      if (this.filtros.telefone) {
        const q = this.filtros.telefone.replace(/\D/g, '')
        list = list.filter(r => (r.telefone || '').replace(/\D/g, '').includes(q))
      }
      if (this.filtros.email) {
        const q = this.filtros.email.toLowerCase()
        list = list.filter(r => (r.email || '').toLowerCase().includes(q))
      }
      if (this.filtros.cidade) {
        const q = this.filtros.cidade.toLowerCase()
        list = list.filter(r => (r.municipio || '').toLowerCase().includes(q))
      }
      
      return [...list].sort((a, b) => {
        let va = (a[this.sortKey] || '').toLowerCase()
        let vb = (b[this.sortKey] || '').toLowerCase()
        if (typeof a[this.sortKey] === 'number') {
          va = a[this.sortKey] || 0
          vb = b[this.sortKey] || 0
        }
        if (va === vb) return 0
        return (va < vb ? -1 : 1) * (this.sortDir === 'asc' ? 1 : -1)
      })
    },
    
    paginatedRows() {
      const start = (this.paginaAtual - 1) * this.itensPorPagina
      const end = start + this.itensPorPagina
      return this.filteredRows.slice(start, end)
    },
    
    totalPages() {
      return Math.ceil(this.filteredRows.length / this.itensPorPagina)
    },
    
    exportColumns() {
      return [
        { key: 'id', label: 'ID' },
        { key: 'cnpj', label: 'CNPJ' },
        { key: 'razaoSocial', label: 'Razão Social' },
        { key: 'telefone', label: 'Telefone' },
        { key: 'email', label: 'E-mail' },
        { key: 'municipio', label: 'Cidade' },
        { key: 'uf', label: 'UF' },
        { key: 'site', label: 'Site' }
      ]
    }
  },

  watch: {
    filteredRows() {
      this.paginaAtual = 1
    },
    
    searchTerm() {
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
        this.rows = await res.json()
        this.showToast(`${this.rows.length} empresas carregadas`, 'success')
      } catch {
        this.showToast('Erro ao carregar empresas.', 'error')
      } finally {
        this.loading = false
      }
    },

    alternarFiltros() {
      this.mostrarFiltros = !this.mostrarFiltros
    },

    limparFiltros() {
      this.filtros = { cnpj: '', razaoSocial: '', telefone: '', email: '', cidade: '' }
      this.searchTerm = ''
      this.showToast('Filtros limpos', 'info')
    },

    confirmarDelecao(row) {
      this.confirm = { visible: true, nome: row.razaoSocial, id: row.id }
    },

    async deletarConfirmado() {
      this.confirm.visible = false
      try {
        const res = await fetch(`${API}/${this.confirm.id}`, { method: 'DELETE' })
        if (!res.ok) throw new Error()
        this.rows = this.rows.filter(r => r.id !== this.confirm.id)
        this.showToast('Empresa excluída com sucesso!', 'success')
      } catch {
        this.showToast('Erro ao excluir empresa.', 'error')
      }
    },

    sortBy(key) {
      this.sortDir = this.sortKey === key && this.sortDir === 'asc' ? 'desc' : 'asc'
      this.sortKey = key
    },

    sortIcon(key) {
      if (this.sortKey !== key) return '⇅'
      return this.sortDir === 'asc' ? '↑' : '↓'
    },

    formatarCNPJ(cnpj) {
      if (!cnpj) return '—'
      const n = cnpj.replace(/\D/g, '')
      return n.length === 14 ? n.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/, '$1.$2.$3/$4-$5') : cnpj
    },

    formatarTelefone(tel) {
      if (!tel) return '—'
      const n = tel.replace(/\D/g, '')
      if (n.length === 11) return n.replace(/^(\d{2})(\d{5})(\d{4})$/, '($1) $2-$3')
      if (n.length === 10) return n.replace(/^(\d{2})(\d{4})(\d{4})$/, '($1) $2-$3')
      return tel
    },

    irParaNovaEmpresa() {
      this.$router.push('/empresa')
    },

    editarEmpresa(id) {
      this.modalVisible = false
      this.$router.push(`/empresa/${id}`)
    },

    verDetalhes(row) {
      this.empresaSelecionada = row
      this.modalVisible = true
    },

    showToast(message, type = 'success') {
      this.toast = { visible: true, message, type }
      setTimeout(() => { this.toast.visible = false }, 3200)
    },
    
    showToastMessage({ message, type }) {
      this.showToast(message, type)
    }
  }
}
</script>

<style scoped>
.empresas-page {
  animation: fadeIn 0.5s ease;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.page-title {
  font-size: 2rem;
  font-weight: 700;
  background: linear-gradient(135deg, #6366f1, #10b981);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 0.25rem;
}

.page-subtitle {
  color: #6b7280;
}

.header-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.stat-badge {
  background: linear-gradient(135deg, #818cf8, #6366f1);
  padding: 0.5rem 1.5rem;
  border-radius: 0.75rem;
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
  margin-bottom: 1.5rem;
  gap: 1rem;
  flex-wrap: wrap;
}

.search-section {
  display: flex;
  gap: 1rem;
  flex: 1;
  max-width: 500px;
}

.search-wrapper {
  position: relative;
  flex: 1;
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
  border: 1.5px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 0.9375rem;
  transition: all 0.2s;
  background: white;
}

.search-input-custom:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.view-options {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.view-btn {
  padding: 0.5rem 1rem;
  border: none;
  background: #f3f4f6;
  cursor: pointer;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.2s;
}

.view-btn.active {
  background: white;
  box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  color: #6366f1;
}

.view-btn:hover:not(.active) {
  background: #e5e7eb;
}

.filters-panel {
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  background: #f9fafb;
  border-radius: 0.75rem;
  animation: slideIn 0.3s ease;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.filters-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.filter-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #374151;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.filter-input {
  padding: 0.5rem;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  transition: all 0.2s;
}

.filter-input:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.filters-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.filter-result {
  font-size: 0.875rem;
  color: #6b7280;
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
  padding: 1rem;
  background: #f9fafb;
  font-weight: 600;
  font-size: 0.875rem;
  color: #6b7280;
  border-bottom: 2px solid #e5e7eb;
}

.sortable {
  cursor: pointer;
  user-select: none;
  transition: color 0.2s;
}

.sortable:hover {
  color: #6366f1;
}

.sort-icon {
  margin-left: 0.25rem;
  font-size: 0.75rem;
}

.modern-table td {
  padding: 1rem;
  border-bottom: 1px solid #e5e7eb;
  transition: background 0.2s;
}

.table-row:hover {
  background: #f9fafb;
}

.cnpj-badge {
  font-family: monospace;
  font-size: 0.875rem;
  font-weight: 600;
  color: #6366f1;
}

.company-name {
  font-weight: 500;
}

.email-link {
  color: #6366f1;
  text-decoration: none;
  transition: color 0.2s;
}

.email-link:hover {
  color: #4f46e5;
  text-decoration: underline;
}

.city-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  background: #f3f4f6;
  border-radius: 0.375rem;
  font-size: 0.875rem;
}

.empty-value {
  color: #9ca3af;
}

.action-buttons {
  display: flex;
  gap: 0.25rem;
  justify-content: flex-end;
}

.action-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  cursor: pointer;
  border-radius: 0.375rem;
  font-size: 1rem;
  transition: all 0.2s;
}

.action-btn.edit:hover {
  background: #818cf8;
  transform: scale(1.1);
  color: white;
}

.action-btn.view:hover {
  background: #3b82f6;
  transform: scale(1.1);
  color: white;
}

.action-btn.delete:hover {
  background: #ef4444;
  transform: scale(1.1);
  color: white;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin-top: 1.5rem;
  padding: 1rem;
}

.page-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  background: white;
  cursor: pointer;
  border-radius: 0.5rem;
  transition: all 0.2s;
}

.page-btn:hover:not(:disabled) {
  background: #6366f1;
  color: white;
  border-color: #6366f1;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-info {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.875rem;
}

.page-current {
  font-weight: 700;
  color: #6366f1;
  font-size: 1rem;
}

.page-separator {
  color: #9ca3af;
}

.page-total {
  color: #6b7280;
}

.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
  margin-top: 1.5rem;
}

.company-card {
  background: white;
  border-radius: 0.75rem;
  overflow: hidden;
  transition: all 0.3s;
  cursor: pointer;
  box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
}

.company-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: linear-gradient(135deg, #818cf8, #6366f1);
  color: white;
}

.card-icon {
  font-size: 2rem;
}

.card-actions {
  display: flex;
  gap: 0.25rem;
}

.card-action {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 0.375rem;
  font-size: 1rem;
  transition: all 0.2s;
}

.card-action:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: scale(1.05);
}

.card-body {
  padding: 1rem;
}

.card-title {
  font-size: 1.1rem;
  font-weight: 600;
  margin-bottom: 1rem;
  color: #1f2937;
}

.card-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
}

.info-label {
  font-weight: 600;
  color: #6b7280;
}

.email-text {
  color: #6366f1;
  word-break: break-all;
  text-align: right;
}

.card-footer {
  padding: 0.5rem 1rem;
  background: #f9fafb;
  border-top: 1px solid #e5e7eb;
}

.badge-id {
  font-size: 0.75rem;
  color: #9ca3af;
  font-family: monospace;
}

.empty-cards {
  grid-column: 1 / -1;
}

.empty-state {
  text-align: center;
  padding: 3rem !important;
}

.empty-state-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.empty-icon {
  font-size: 4rem;
  opacity: 0.5;
}

.slide-enter-active, .slide-leave-active {
  transition: all 0.3s ease;
  max-height: 500px;
  overflow: hidden;
}

.slide-enter, .slide-leave-to {
  max-height: 0;
  opacity: 0;
}

.text-right {
  text-align: right;
}

.modal-details {
  padding: 0.5rem;
}

.company-header {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.company-avatar {
  width: 70px;
  height: 70px;
  background: linear-gradient(135deg, #818cf8, #6366f1);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
}

.company-name-detail h2 {
  margin: 0 0 0.25rem 0;
  color: #1f2937;
}

.company-id {
  font-size: 0.75rem;
  color: #9ca3af;
  font-family: monospace;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.detail-group {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.detail-group.full-width {
  grid-column: 1 / -1;
}

.detail-group label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-value {
  font-size: 0.9375rem;
  color: #1f2937;
  margin: 0;
  word-break: break-word;
}

.detail-value a {
  color: #6366f1;
  text-decoration: none;
}

.detail-value a:hover {
  text-decoration: underline;
}

.address-section {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.address-section h4 {
  margin-bottom: 1rem;
  color: #374151;
}

.modal-close-btn {
  padding: 0.5rem 1.5rem;
  background: #e5e7eb;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.2s;
}

.modal-close-btn:hover {
  background: #d1d5db;
}

.modal-edit-btn {
  padding: 0.5rem 1.5rem;
  background: #6366f1;
  color: white;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.2s;
}

.modal-edit-btn:hover {
  background: #4f46e5;
  transform: translateY(-2px);
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
    flex-direction: column;
  }
  
  .view-options {
    width: 100%;
    justify-content: center;
  }
  
  .cards-grid {
    grid-template-columns: 1fr;
  }
  
  .filters-grid {
    grid-template-columns: 1fr;
  }
  
  .filters-actions {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .company-header {
    flex-direction: column;
    text-align: center;
  }
  
  .details-grid {
    grid-template-columns: 1fr;
  }
}
</style>