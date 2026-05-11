<template>
  <div class="leiloes-page container">
    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />

    <Modal :visible="modalVisible" @update:visible="modalVisible = $event"
      :title="`Detalhes do Leilão ${leilaoSelecionado?.codigo || ''}`" size="lg">
      <div v-if="leilaoSelecionado" class="modal-details">
        <div class="details-grid">
          <div class="detail-group">
            <label>Código</label>
            <p class="detail-value">{{ leilaoSelecionado.codigo }}</p>
          </div>
          <div class="detail-group full-width">
            <label>Descrição</label>
            <p class="detail-value">{{ leilaoSelecionado.descricao }}</p>
          </div>
          <div class="detail-group">
            <label>Vendedor</label>
            <p class="detail-value">{{ leilaoSelecionado._vendedorNome || '—' }}</p>
          </div>
          <div class="detail-group">
            <label>Total do Leilão</label>
            <p class="detail-value highlight">{{ formatarMoeda(leilaoSelecionado._total) }}</p>
          </div>
          <div class="detail-group">
            <label>Início Previsto</label>
            <p class="detail-value">{{ formatarData(leilaoSelecionado.inicioPrevisto) }}</p>
          </div>
          <div class="detail-group">
            <label>Status</label>
            <p class="detail-value">
              <span :class="['status-badge', getStatusClass(leilaoSelecionado)]">
                {{ getStatus(leilaoSelecionado) }}
              </span>
            </p>
          </div>
        </div>
      </div>

      <template #footer>
        <button @click="modalVisible = false" class="modal-close-btn">Fechar</button>
        <button @click="editarLeilao(leilaoSelecionado)" class="modal-edit-btn">✏️ Editar Leilão</button>
      </template>
    </Modal>

    <div class="page-header animate-fade">
      <div>
        <h1 class="page-title">Leilões</h1>
        <p class="page-subtitle">Gerencie e acompanhe todos os leilões do sistema</p>
      </div>
      <div class="stats-cards">
        <div class="stat-card">
          <span class="stat-value">{{ rows.length }}</span>
          <span class="stat-label">Total de Leilões</span>
        </div>
        <div class="stat-card">
          <span class="stat-value">{{ formatarMoeda(totalGeralLeiloes) }}</span>
          <span class="stat-label">Valor Total</span>
        </div>
      </div>
    </div>

    <LoadingSkeleton v-if="loading" type="table" />

    <AppCard v-else class="animate-fade">
      <div class="filters-section">
        <div class="filters-grid">
          <div class="search-wrapper">
            <span class="search-icon">🔍</span>
            <input v-model="filtros.vendedor" type="text" class="filter-input-custom"
              placeholder="Filtrar por vendedor..." />
            <button v-if="filtros.vendedor" @click="filtros.vendedor = ''" class="clear-field-btn"
              title="Limpar filtro">
              ✕
            </button>
          </div>

          <div class="search-wrapper">
            <span class="search-icon">📝</span>
            <input v-model="filtros.descricao" type="text" class="filter-input-custom"
              placeholder="Filtrar por descrição..." />
            <button v-if="filtros.descricao" @click="filtros.descricao = ''" class="clear-field-btn"
              title="Limpar filtro">
              ✕
            </button>
          </div>

          <div class="date-filters">
            <div class="date-wrapper">
              <span class="date-icon">📅</span>
              <input type="date" v-model="filtros.dataInicio" class="date-input" placeholder="Data inicial" />
              <button v-if="filtros.dataInicio" @click="filtros.dataInicio = ''" class="clear-field-btn date-clear"
                title="Limpar data">
                ✕
              </button>
            </div>
            <span class="date-separator">até</span>
            <div class="date-wrapper">
              <span class="date-icon">📅</span>
              <input type="date" v-model="filtros.dataFim" class="date-input" placeholder="Data final" />
              <button v-if="filtros.dataFim" @click="filtros.dataFim = ''" class="clear-field-btn date-clear"
                title="Limpar data">
                ✕
              </button>
            </div>
          </div>

          <div class="export-wrapper">
            <ExportButton :data="filteredRows" :columns="exportColumns" filename="leiloes" title="Relatório de Leilões"
              @toast="showToastMessage" />
          </div>
        </div>

        <div v-if="hasActiveFilters" class="filter-actions-bar">
          <div class="active-filters">
            <span class="filter-label">Filtros aplicados:</span>
            <span v-if="filtros.vendedor" class="filter-tag">
              Vendedor: {{ filtros.vendedor }}
              <button @click="filtros.vendedor = ''" class="remove-tag">✕</button>
            </span>
            <span v-if="filtros.descricao" class="filter-tag">
              Descrição: {{ filtros.descricao }}
              <button @click="filtros.descricao = ''" class="remove-tag">✕</button>
            </span>
            <span v-if="filtros.dataInicio" class="filter-tag">
              Início: {{ formatarDataBR(filtros.dataInicio) }}
              <button @click="filtros.dataInicio = ''" class="remove-tag">✕</button>
            </span>
            <span v-if="filtros.dataFim" class="filter-tag">
              Fim: {{ formatarDataBR(filtros.dataFim) }}
              <button @click="filtros.dataFim = ''" class="remove-tag">✕</button>
            </span>
          </div>
          <button @click="limparFiltros" class="btn-clear-all">
            🗑️ Limpar todos
          </button>
        </div>
      </div>

      <div class="table-container">
        <table class="modern-table">
          <thead>
            <tr>
              <th @click="sortBy('codigo')" class="sortable">
                Código
                <span class="sort-icon">{{ sortIcon('codigo') }}</span>
              </th>
              <th @click="sortBy('descricao')" class="sortable">
                Descrição
                <span class="sort-icon">{{ sortIcon('descricao') }}</span>
              </th>
              <th @click="sortBy('_vendedorNome')" class="sortable">
                Vendedor
                <span class="sort-icon">{{ sortIcon('_vendedorNome') }}</span>
              </th>
              <th @click="sortBy('inicioPrevisto')" class="sortable">
                Início Previsto
                <span class="sort-icon">{{ sortIcon('inicioPrevisto') }}</span>
              </th>
              <th @click="sortBy('_total')" class="sortable text-right">
                Total
                <span class="sort-icon">{{ sortIcon('_total') }}</span>
              </th>
              <th class="text-right">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedRows" :key="row.id" class="table-row">
              <td><span class="badge">{{ row.codigo }}</span></td>
              <td class="descricao-cell" :title="row.descricao">{{ row.descricao }}</td>
              <td>{{ row._vendedorNome || '—' }}</td>
              <td>{{ formatarData(row.inicioPrevisto) }}</td>
              <td class="text-right highlight">{{ formatarMoeda(row._total) }}</td>
              <td class="text-right">
                <div class="action-buttons">
                  <button class="action-btn view" title="Ver detalhes" @click="verDetalhes(row)">👁️</button>
                  <button class="action-btn edit" title="Editar" @click="editarLeilao(row)">✏️</button>
                </div>
              </td>
            </tr>
            <tr v-if="filteredRows.length === 0">
              <td :colspan="6" class="empty-state">
                <div class="empty-state-content">
                  <span class="empty-icon">🔍</span>
                  <p>Nenhum leilão encontrado</p>
                  <button @click="limparFiltros" class="btn-clear-all empty-state-btn">
                    🗑️ Limpar todos os filtros
                  </button>
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

      <div class="table-footer">
        <div class="footer-info">
          <span>Mostrando <strong>{{ paginatedRows.length }}</strong> de <strong>{{ filteredRows.length }}</strong>
            leilões</span>
        </div>
        <div class="footer-total">
          <span>Total filtrado:</span>
          <strong>{{ formatarMoeda(totalGeral) }}</strong>
        </div>
      </div>
    </AppCard>
  </div>
</template>

<script>
import ToastNotification from '@/components/ToastNotification.vue'
import AppCard from '@/components/ui/AppCard.vue'
import LoadingSkeleton from '@/components/ui/LoadingSkeleton.vue'
import Modal from '@/components/ui/Modal.vue'
import ExportButton from '@/components/ui/ExportButton.vue'

const API_LEILAO = 'http://localhost:8081/leilao'
const API_EMPRESA = 'http://localhost:8081/empresa'
const API_LOTE = 'http://localhost:8081/lote'

export default {
  name: 'Leiloes',
  components: { ToastNotification, AppCard, LoadingSkeleton, Modal, ExportButton },

  data() {
    return {
      rows: [],
      loading: true,
      sortKey: 'inicioPrevisto',
      sortDir: 'asc',
      paginaAtual: 1,
      itensPorPagina: 10,
      toast: { visible: false, message: '', type: 'success' },
      filtros: { vendedor: '', descricao: '', dataInicio: '', dataFim: '' },
      modalVisible: false,
      leilaoSelecionado: null
    }
  },

  computed: {
    filteredRows() {
      let list = [...this.rows]
      if (this.filtros.vendedor) {
        const q = this.filtros.vendedor.toLowerCase()
        list = list.filter(r => (r._vendedorNome || '').toLowerCase().includes(q))
      }
      if (this.filtros.descricao) {
        const q = this.filtros.descricao.toLowerCase()
        list = list.filter(r => (r.descricao || '').toLowerCase().includes(q))
      }
      if (this.filtros.dataInicio) {
        const di = new Date(this.filtros.dataInicio)
        list = list.filter(r => new Date(r.inicioPrevisto) >= di)
      }
      if (this.filtros.dataFim) {
        const df = new Date(this.filtros.dataFim)
        df.setHours(23, 59, 59)
        list = list.filter(r => new Date(r.inicioPrevisto) <= df)
      }
      return [...list].sort((a, b) => {
        let va = a[this.sortKey] ?? '', vb = b[this.sortKey] ?? ''
        if (typeof va === 'string') { va = va.toLowerCase(); vb = vb.toLowerCase() }
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

    totalGeral() {
      return this.filteredRows.reduce((s, r) => s + (r._total || 0), 0)
    },

    totalGeralLeiloes() {
      return this.rows.reduce((s, r) => s + (r._total || 0), 0)
    },

    hasActiveFilters() {
      return !!(this.filtros.vendedor || this.filtros.descricao || this.filtros.dataInicio || this.filtros.dataFim)
    },

    exportColumns() {
      return [
        { key: 'codigo', label: 'Código' },
        { key: 'descricao', label: 'Descrição' },
        { key: '_vendedorNome', label: 'Vendedor' },
        { key: 'inicioPrevisto', label: 'Início Previsto', format: 'date' },
        { key: '_total', label: 'Total do Leilão', format: 'currency' }
      ]
    }
  },

  watch: {
    filteredRows() {
      this.paginaAtual = 1
    },

    'filtros.vendedor'() {
      this.paginaAtual = 1
    },

    'filtros.descricao'() {
      this.paginaAtual = 1
    },

    'filtros.dataInicio'() {
      this.paginaAtual = 1
    },

    'filtros.dataFim'() {
      this.paginaAtual = 1
    }
  },

  mounted() {
    this.carregarDados()
  },

  methods: {
    async carregarDados() {
      this.loading = true
      try {
        const [leiloes, empresas, lotes] = await Promise.all([
          fetch(API_LEILAO).then(r => r.json()),
          fetch(API_EMPRESA).then(r => r.json()),
          fetch(API_LOTE).then(r => r.json())
        ])
        const empresaMap = {}
        empresas.forEach(e => { empresaMap[e.id] = e })
        const totalPorLeilao = {}
        lotes.forEach(l => {
          const sub = Number(l.quantidade) * Number(l.valorInicial)
          totalPorLeilao[l.leilao] = (totalPorLeilao[l.leilao] || 0) + sub
        })
        this.rows = leiloes.map(l => ({
          ...l,
          _vendedorNome: empresaMap[l.vendedor]?.razaoSocial || `Empresa #${l.vendedor}`,
          _total: totalPorLeilao[l.id] || 0
        }))
        this.showToast(`${leiloes.length} leilões carregados`, 'success')
      } catch (err) {
        this.showToast('Erro ao carregar dados dos leilões.', 'error')
      } finally {
        this.loading = false
      }
    },

    limparFiltros() {
      this.filtros = { vendedor: '', descricao: '', dataInicio: '', dataFim: '' }
      this.showToast('Todos os filtros foram removidos', 'info')
    },

    sortBy(key) {
      this.sortDir = this.sortKey === key && this.sortDir === 'asc' ? 'desc' : 'asc'
      this.sortKey = key
    },

    sortIcon(key) {
      if (this.sortKey !== key) return '⇅'
      return this.sortDir === 'asc' ? '↑' : '↓'
    },

    formatarData(valor) {
      if (!valor) return '—'
      const d = new Date(valor)
      return isNaN(d) ? valor : d.toLocaleDateString('pt-BR', {
        day: '2-digit', month: '2-digit', year: 'numeric',
        hour: '2-digit', minute: '2-digit'
      })
    },

    formatarDataBR(valor) {
      if (!valor) return ''
      const d = new Date(valor)
      return isNaN(d) ? valor : d.toLocaleDateString('pt-BR')
    },

    formatarMoeda(valor) {
      return Number(valor || 0).toLocaleString('pt-BR', {
        style: 'currency',
        currency: 'BRL'
      })
    },

    showToast(message, type = 'success') {
      this.toast = { visible: true, message, type }
      setTimeout(() => { this.toast.visible = false }, 3200)
    },

    showToastMessage({ message, type }) {
      this.showToast(message, type)
    },

    verDetalhes(row) {
      this.leilaoSelecionado = row
      this.modalVisible = true
    },

    editarLeilao(row) {
      this.modalVisible = false
      this.showToast(`Editar leilão ${row.codigo}`, 'info')
    },

    getStatus(row) {
      const dataInicio = new Date(row.inicioPrevisto)
      const agora = new Date()
      if (dataInicio > agora) return 'Agendado'
      if (dataInicio <= agora) return 'Em Andamento'
      return 'Finalizado'
    },

    getStatusClass(row) {
      const status = this.getStatus(row)
      if (status === 'Agendado') return 'status-scheduled'
      if (status === 'Em Andamento') return 'status-progress'
      return 'status-finished'
    }
  }
}
</script>

<style scoped>
.leiloes-page {
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

.stats-cards {
  display: flex;
  gap: 1rem;
}

.stat-card {
  background: #f3f4f6;
  padding: 1rem 1.5rem;
  border-radius: 0.75rem;
  text-align: center;
  min-width: 140px;
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.stat-value {
  display: block;
  font-size: 1.5rem;
  font-weight: 700;
  color: #6366f1;
}

.stat-label {
  font-size: 0.75rem;
  color: #6b7280;
  margin-top: 4px;
}

.filters-section {
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.filters-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  align-items: end;
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

.filter-input-custom {
  width: 100%;
  padding: 10px 12px 10px 36px;
  border: 1.5px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 0.9375rem;
  transition: all 0.2s;
  background: white;
}

.filter-input-custom:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.clear-field-btn {
  position: absolute;
  right: 8px;
  width: 24px;
  height: 24px;
  border: none;
  background: #e5e7eb;
  border-radius: 50%;
  cursor: pointer;
  font-size: 0.75rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  color: #6b7280;
}

.clear-field-btn:hover {
  background: #ef4444;
  color: white;
  transform: scale(1.1);
}

.date-clear {
  right: 4px;
}

.date-filters {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.date-wrapper {
  position: relative;
  flex: 1;
  display: flex;
  align-items: center;
}

.date-icon {
  position: absolute;
  left: 10px;
  font-size: 0.875rem;
  pointer-events: none;
  z-index: 1;
  opacity: 0.6;
}

.date-input {
  width: 100%;
  padding: 10px 12px 10px 32px;
  border: 1.5px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  transition: all 0.2s;
  background: white;
  font-family: inherit;
}

.date-input:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.date-separator {
  color: #9ca3af;
  font-size: 0.875rem;
  font-weight: 600;
}

.export-wrapper {
  display: flex;
  justify-content: flex-end;
}

.filter-actions-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.active-filters {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}

.filter-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #6b7280;
}

.filter-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 8px 4px 12px;
  background: #818cf8;
  color: white;
  border-radius: 20px;
  font-size: 0.75rem;
}

.remove-tag {
  background: rgba(255, 255, 255, 0.3);
  border: none;
  border-radius: 50%;
  width: 18px;
  height: 18px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 0.7rem;
  transition: all 0.2s;
}

.remove-tag:hover {
  background: rgba(255, 255, 255, 0.5);
  transform: scale(1.1);
}

.btn-clear-all {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: transparent;
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  font-size: 0.75rem;
  cursor: pointer;
  transition: all 0.2s;
  color: #6b7280;
}

.btn-clear-all:hover {
  background: #ef4444;
  border-color: #ef4444;
  color: white;
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
  white-space: nowrap;
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

.badge {
  display: inline-block;
  padding: 4px 10px;
  background: linear-gradient(135deg, #818cf8, #6366f1);
  color: white;
  border-radius: 0.375rem;
  font-size: 0.75rem;
  font-weight: 600;
  font-family: monospace;
}

.descricao-cell {
  max-width: 250px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.highlight {
  font-weight: 700;
  color: #10b981;
}

.text-right {
  text-align: right;
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

.action-btn.view:hover {
  background: #3b82f6;
  transform: scale(1.1);
  color: white;
}

.action-btn.edit:hover {
  background: #818cf8;
  transform: scale(1.1);
  color: white;
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

.empty-state-btn {
  background: #f3f4f6;
  border: 1px solid #d1d5db;
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
  font-size: 0.875rem;
}

.page-btn:hover:not(:disabled) {
  background: #6366f1;
  color: white;
  border-color: #6366f1;
  transform: translateY(-2px);
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

.table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: #f9fafb;
  border-top: 1px solid #e5e7eb;
  margin-top: 1rem;
  border-radius: 0.5rem;
}

.footer-info {
  font-size: 0.875rem;
  color: #6b7280;
}

.footer-info strong {
  color: #6366f1;
}

.footer-total {
  font-weight: 600;
  font-size: 0.875rem;
}

.footer-total strong {
  color: #10b981;
  margin-left: 0.5rem;
  font-size: 1rem;
}

.modal-details {
  padding: 0.5rem;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
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
  font-size: 1rem;
  color: #1f2937;
  margin: 0;
  word-break: break-word;
}

.detail-value.highlight {
  font-size: 1.25rem;
  font-weight: 700;
  color: #10b981;
}

.status-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
}

.status-scheduled {
  background: #3b82f6;
  color: white;
}

.status-progress {
  background: #f59e0b;
  color: white;
}

.status-finished {
  background: #9ca3af;
  color: white;
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

  .stats-cards {
    width: 100%;
  }

  .stat-card {
    flex: 1;
  }

  .filters-grid {
    grid-template-columns: 1fr;
  }

  .date-filters {
    flex-direction: column;
  }

  .date-separator {
    display: none;
  }

  .date-wrapper {
    width: 100%;
  }

  .export-wrapper {
    justify-content: stretch;
  }

  .export-wrapper .btn-export {
    width: 100%;
    justify-content: center;
  }

  .table-footer {
    flex-direction: column;
    gap: 0.5rem;
    text-align: center;
  }

  .pagination {
    flex-wrap: wrap;
  }

  .descricao-cell {
    max-width: 150px;
  }

  .filter-actions-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .active-filters {
    justify-content: center;
  }

  .btn-clear-all {
    justify-content: center;
  }

  .details-grid {
    grid-template-columns: 1fr;
  }
}
</style>