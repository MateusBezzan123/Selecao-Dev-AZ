<template>
  <div class="leiloes-page">
    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />

    <div class="page-header">
      <div class="page-title">
        <span class="page-icon">🔖</span>
        <div>
          <h1>Leilões</h1>
          <p>Consulta dos leilões cadastrados no sistema</p>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-wrap">
      <div class="spinner"></div>
      <span>Carregando...</span>
    </div>

    <div v-else class="table-card">
      <div class="table-toolbar">
        <div class="filters-wrap">
          <input v-model="filtros.vendedor"   class="filter-input" placeholder="🔍 Vendedor" />
          <input v-model="filtros.descricao"  class="filter-input" placeholder="🔍 Descrição" />
          <input v-model="filtros.dataInicio" class="filter-input" type="date" title="Data início a partir de" />
          <input v-model="filtros.dataFim"    class="filter-input" type="date" title="Data início até" />
          <button class="btn-limpar" @click="limparFiltros">✕ Limpar</button>
        </div>
        <span class="total-badge">{{ filteredRows.length }} registro(s)</span>
      </div>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
            <tr>
              <th @click="sortBy('codigo')">
                Código <span class="sort-icon">{{ sortIcon('codigo') }}</span>
              </th>
              <th @click="sortBy('descricao')">
                Descrição <span class="sort-icon">{{ sortIcon('descricao') }}</span>
              </th>
              <th @click="sortBy('_vendedorNome')">
                Vendedor <span class="sort-icon">{{ sortIcon('_vendedorNome') }}</span>
              </th>
              <th @click="sortBy('inicioPrevisto')">
                Início Previsto <span class="sort-icon">{{ sortIcon('inicioPrevisto') }}</span>
              </th>
              <th class="th-total" @click="sortBy('_total')">
                Total do Leilão <span class="sort-icon">{{ sortIcon('_total') }}</span>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in filteredRows" :key="row.id">
              <td><span class="badge-cod">{{ row.codigo }}</span></td>
              <td>{{ row.descricao }}</td>
              <td><span class="vendedor-nome">{{ row._vendedorNome || '—' }}</span></td>
              <td>{{ formatarData(row.inicioPrevisto) }}</td>
              <td class="td-total">{{ formatarMoeda(row._total) }}</td>
            </tr>
            <tr v-if="filteredRows.length === 0">
              <td colspan="5" class="empty-state">Nenhum leilão encontrado.</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-if="filteredRows.length > 0" class="table-footer">
        <span>Total geral filtrado:</span>
        <strong>{{ formatarMoeda(totalGeral) }}</strong>
      </div>
    </div>

    <p class="hint">💡 Filtre por período usando as datas de início e fim.</p>
  </div>
</template>

<script>
import ToastNotification from '@/components/ToastNotification.vue'

const API_LEILAO  = 'http://localhost:8081/leilao'
const API_EMPRESA = 'http://localhost:8081/empresa'
const API_LOTE    = 'http://localhost:8081/lote'

export default {
  name: 'Leiloes',
  components: { ToastNotification },

  data() {
    return {
      rows:    [],
      loading: true,
      sortKey: 'inicioPrevisto',
      sortDir: 'asc',
      toast:   { visible: false, message: '', type: 'success' },
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
        const df = new Date(this.filtros.dataFim); df.setHours(23, 59, 59)
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
          _total:        totalPorLeilao[l.id] || 0
        }))
      } catch (err) {
        this.showToast('Erro ao carregar dados dos leilões.', 'error')
      } finally {
        this.loading = false
      }
    },

    limparFiltros() {
      this.filtros = { vendedor: '', descricao: '', dataInicio: '', dataFim: '' }
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
      return Number(valor || 0).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
    },

    showToast(msg, type = 'success') {
      this.toast = { visible: true, message: msg, type }
      setTimeout(() => { this.toast.visible = false }, 3200)
    }
  }
}
</script>

<style scoped>
.leiloes-page { max-width: 1100px; margin: 0 auto; }

.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
.page-title  { display: flex; align-items: center; gap: 14px; }
.page-icon   { font-size: 2.2rem; }
.page-title h1 { font-size: 1.6rem; font-weight: 700; color: #2c3e50; margin: 0; }
.page-title p  { font-size: 0.85rem; color: #95a5a6; margin: 2px 0 0; }

.loading-wrap  { display: flex; align-items: center; justify-content: center; gap: 14px; padding: 60px; color: #7f8c8d; }

.spinner { width: 28px; height: 28px; border: 3px solid #ddd; border-top-color: #42b983; border-radius: 50%; animation: spin .7s linear infinite; }

@keyframes spin { to { transform: rotate(360deg); } }
.table-card { background: #fff; border-radius: 12px; box-shadow: 0 2px 16px rgba(0,0,0,0.08); overflow: hidden; }
.table-toolbar { padding: 16px 20px; border-bottom: 1px solid #f0f0f0; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }

.filters-wrap  { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
.filter-input  { padding: 8px 12px; border: 1.5px solid #e0e0e0; border-radius: 7px; font-size: 0.85rem; width: 150px; outline: none; transition: all .2s; }
.filter-input:focus { border-color: #42b983; box-shadow: 0 0 0 2px rgba(66,185,131,.1); }

.btn-limpar { padding: 8px 14px; background: #f5f5f5; border: 1.5px solid #e0e0e0; border-radius: 7px; font-size: 0.82rem; cursor: pointer; color: #7f8c8d; transition: all .2s; }
.btn-limpar:hover { background: #ecf0f1; }

.total-badge { font-size: 0.82rem; color: #95a5a6; background: #f5f5f5; padding: 4px 12px; border-radius: 20px; }

.table-wrapper { overflow-x: auto; }

.data-table { width: 100%; border-collapse: collapse; font-size: 0.92rem; }
.data-table thead tr { background: #f8f9fa; }
.data-table th { padding: 13px 16px; text-align: left; font-size: 0.78rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: #95a5a6; border-bottom: 2px solid #ecf0f1; cursor: pointer; user-select: none; white-space: nowrap; }
.data-table th:hover { color: #2c3e50; }

.th-total { text-align: right; }

.sort-icon { font-size: 0.75rem; margin-left: 4px; }

.data-table td { padding: 13px 16px; border-bottom: 1px solid #f4f4f4; color: #34495e; vertical-align: middle; }
.data-table tbody tr:hover { background: #fafffe; }
.data-table tbody tr:last-child td { border-bottom: none; }

.badge-cod { display: inline-block; background: #eaf7f1; color: #27ae60; padding: 2px 10px; border-radius: 12px; font-weight: 700; font-size: 0.82rem; }

.vendedor-nome { font-weight: 500; }

.td-total { text-align: right; font-weight: 700; color: #27ae60; }

.table-footer { display: flex; align-items: center; justify-content: flex-end; gap: 12px; padding: 14px 20px; background: #f8f9fa; border-top: 2px solid #ecf0f1; font-size: 0.9rem; color: #555; }
.table-footer strong { color: #27ae60; font-size: 1rem; }

.empty-state { text-align: center; color: #bdc3c7; font-style: italic; padding: 40px !important; }

.hint { margin-top: 14px; font-size: 0.8rem; color: #bdc3c7; text-align: center; }
</style>