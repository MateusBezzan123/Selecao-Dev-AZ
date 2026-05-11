<template>
  <div class="leiloes-page container">
    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />

    <div class="page-header animate-fade">
      <div>
        <h1 class="page-title">Leilões</h1>
        <p class="page-subtitle">Gerencie e acompanhe todos os leilões do sistema</p>
      </div>
      <div class="stats-cards">
        <div class="stat-card">
          <span class="stat-value">{{ rows.length }}</span>
          <span class="stat-label">Total</span>
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
          <AppInput
            v-model="filtros.vendedor"
            placeholder="Filtrar por vendedor..."
            icon="🔍"
          />
          <AppInput
            v-model="filtros.descricao"
            placeholder="Filtrar por descrição..."
            icon="📝"
          />
          <div class="date-filters">
            <input type="date" v-model="filtros.dataInicio" class="date-input" placeholder="Data inicial" />
            <span class="date-separator">até</span>
            <input type="date" v-model="filtros.dataFim" class="date-input" placeholder="Data final" />
          </div>
          <AppButton variant="outline" @click="limparFiltros" size="sm">
            ✕ Limpar filtros
          </AppButton>
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
            <tr v-for="row in filteredRows" :key="row.id" class="table-row">
              <td><span class="badge">{{ row.codigo }}</span></td>
              <td class="descricao-cell">{{ row.descricao }}</td>
              <td>{{ row._vendedorNome || '—' }}</td>
              <td>{{ formatarData(row.inicioPrevisto) }}</td>
              <td class="text-right highlight">{{ formatarMoeda(row._total) }}</td>
              <td class="text-right">
                <button class="action-btn view" title="Ver detalhes" @click="verDetalhes(row)">
                  👁️
                </button>
                <button class="action-btn edit" title="Editar" @click="editarLeilao(row)">
                  ✏️
                </button>
              </td>
            </tr>
            <tr v-if="filteredRows.length === 0">
              <td colspan="6" class="empty-state">
                <div class="empty-state-content">
                  <span class="empty-icon">🔍</span>
                  <p>Nenhum leilão encontrado</p>
                  <AppButton variant="outline" size="sm" @click="limparFiltros">
                    Limpar filtros
                  </AppButton>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="table-footer">
        <div class="footer-info">
          <span>Mostrando <strong>{{ filteredRows.length }}</strong> de <strong>{{ rows.length }}</strong> leilões</span>
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
import AppButton from '@/components/ui/AppButton.vue'
import AppInput from '@/components/ui/AppInput.vue'
import LoadingSkeleton from '@/components/ui/LoadingSkeleton.vue'

const API_LEILAO = 'http://localhost:8081/leilao'
const API_EMPRESA = 'http://localhost:8081/empresa'
const API_LOTE = 'http://localhost:8081/lote'

export default {
  name: 'Leiloes',
  components: { ToastNotification, AppCard, AppButton, AppInput, LoadingSkeleton },
  
  data() {
    return {
      rows: [],
      loading: true,
      sortKey: 'inicioPrevisto',
      sortDir: 'asc',
      toast: { visible: false, message: '', type: 'success' },
      filtros: { vendedor: '', descricao: '', dataInicio: '', dataFim: '' }
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
    totalGeral() {
      return this.filteredRows.reduce((s, r) => s + (r._total || 0), 0)
    },
    totalGeralLeiloes() {
      return this.rows.reduce((s, r) => s + (r._total || 0), 0)
    }
  },

  mounted() { this.carregarDados() },

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
      } catch (err) {
        this.showToast('Erro ao carregar dados dos leilões.', 'error')
      } finally {
        this.loading = false
      }
    },

    limparFiltros() {
      this.filtros = { vendedor: '', descricao: '', dataInicio: '', dataFim: '' }
      this.showToast('Filtros removidos', 'info')
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

    formatarMoeda(valor) {
      return Number(valor || 0).toLocaleString('pt-BR', { 
        style: 'currency', 
        currency: 'BRL' 
      })
    },

    showToast(msg, type = 'success') {
      this.toast = { visible: true, message: msg, type }
      setTimeout(() => { this.toast.visible = false }, 3200)
    },

    verDetalhes(row) {
      this.showToast(`Visualizando detalhes do leilão ${row.codigo}`, 'info')
    },

    editarLeilao(row) {
      this.showToast(`Editar leilão ${row.codigo}`, 'info')
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

.stats-cards {
  display: flex;
  gap: var(--spacing-md);
}

.stat-card {
  background: var(--gray-100);
  padding: var(--spacing-md) var(--spacing-lg);
  border-radius: var(--radius-lg);
  text-align: center;
  min-width: 120px;
}

.stat-value {
  display: block;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary);
}

.stat-label {
  font-size: 0.875rem;
  color: var(--gray-600);
}

.filters-section {
  margin-bottom: var(--spacing-lg);
  padding-bottom: var(--spacing-lg);
  border-bottom: 1px solid var(--gray-200);
}

.filters-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--spacing-md);
}

.date-filters {
  display: flex;
  gap: var(--spacing-sm);
  align-items: center;
}

.date-input {
  flex: 1;
  padding: var(--spacing-sm);
  border: 1px solid var(--gray-300);
  border-radius: var(--radius-md);
  font-size: 0.875rem;
  transition: all 0.2s;
}

.date-input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.date-separator {
  color: var(--gray-500);
  font-size: 0.875rem;
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

.badge {
  display: inline-block;
  padding: 4px 8px;
  background: var(--primary-light);
  color: white;
  border-radius: var(--radius-sm);
  font-size: 0.75rem;
  font-weight: 600;
}

.descricao-cell {
  max-width: 250px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.highlight {
  font-weight: 600;
  color: var(--secondary);
}

.text-right {
  text-align: right;
}

.action-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1.1rem;
  padding: var(--spacing-xs);
  margin: 0 2px;
  transition: transform 0.2s;
}

.action-btn:hover {
  transform: scale(1.1);
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
  font-size: 3rem;
  opacity: 0.5;
}

.table-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-md);
  background: var(--gray-50);
  border-top: 1px solid var(--gray-200);
  margin-top: var(--spacing-md);
}

.footer-total {
  font-weight: 600;
}

.footer-total strong {
  color: var(--secondary);
  margin-left: var(--spacing-sm);
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
  
  .table-footer {
    flex-direction: column;
    gap: var(--spacing-sm);
    text-align: center;
  }
}
</style>