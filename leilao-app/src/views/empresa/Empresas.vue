<template>
  <div class="empresas-page">

    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />

    <div class="page-header">
      <div class="page-title">
        <span class="page-icon">🏢</span>
        <div>
          <h1>Empresas</h1>
          <p>Gerencie as empresas cadastradas no sistema</p>
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
          <input
            v-model="filtros.cnpj"
            class="filter-input"
            placeholder="🔍 CNPJ"
          />
          <input
            v-model="filtros.razaoSocial"
            class="filter-input"
            placeholder="🔍 Razão Social"
          />
          <input
            v-model="filtros.telefone"
            class="filter-input"
            placeholder="🔍 Telefone"
          />
          <input
            v-model="filtros.email"
            class="filter-input"
            placeholder="🔍 E-mail"
          />
        </div>
        <span class="total-badge">{{ filteredRows.length }} registro(s)</span>
      </div>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
            <tr>
              <th class="col-cnpj" @click="sortBy('cnpj')">
                CNPJ <span class="sort-icon">{{ sortIcon('cnpj') }}</span>
              </th>
              <th class="col-razao" @click="sortBy('razaoSocial')">
                Razão Social <span class="sort-icon">{{ sortIcon('razaoSocial') }}</span>
              </th>
              <th class="col-telefone" @click="sortBy('telefone')">
                Telefone <span class="sort-icon">{{ sortIcon('telefone') }}</span>
              </th>
              <th class="col-email" @click="sortBy('email')">
                E-mail <span class="sort-icon">{{ sortIcon('email') }}</span>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="row in filteredRows"
              :key="row.id"
            >
              <td class="col-cnpj">{{ formatarCNPJ(row.cnpj) }}</td>
              <td class="col-razao">{{ row.razaoSocial }}</td>
              <td class="col-telefone">{{ formatarTelefone(row.telefone) }}</td>
              <td class="col-email">{{ row.email || '-' }}</td>
            </tr>

            <tr v-if="filteredRows.length === 0">
              <td colspan="4" class="empty-state">Nenhuma empresa encontrada.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <p class="hint">💡 Dica: utilize os filtros para buscar empresas específicas.</p>
  </div>
</template>

<script>
import ToastNotification from '@/components/ToastNotification.vue'

const API = 'http://localhost:8081/empresa'

export default {
  name: 'Empresas',
  components: { ToastNotification },

  data() {
    return {
      rows: [],
      loading: true,
      sortKey: 'razaoSocial',
      sortDir: 'asc',
      toast: { visible: false, message: '', type: 'success' },
      filtros: {
        cnpj: '',
        razaoSocial: '',
        telefone: '',
        email: ''
      }
    }
  },

  computed: {
    filteredRows() {
      let list = [...this.rows]

      if (this.filtros.cnpj) {
        const cnpjBusca = this.filtros.cnpj.replace(/\D/g, '')
        list = list.filter(r => (r.cnpj || '').replace(/\D/g, '').includes(cnpjBusca))
      }

      if (this.filtros.razaoSocial) {
        const busca = this.filtros.razaoSocial.toLowerCase()
        list = list.filter(r => (r.razaoSocial || '').toLowerCase().includes(busca))
      }

      if (this.filtros.telefone) {
        const telefoneBusca = this.filtros.telefone.replace(/\D/g, '')
        list = list.filter(r => (r.telefone || '').replace(/\D/g, '').includes(telefoneBusca))
      }

      if (this.filtros.email) {
        const busca = this.filtros.email.toLowerCase()
        list = list.filter(r => (r.email || '').toLowerCase().includes(busca))
      }

      list = [...list].sort((a, b) => {
        let va = a[this.sortKey] || ''
        let vb = b[this.sortKey] || ''
        
        if (typeof va === 'string') {
          va = va.toLowerCase()
          vb = vb.toLowerCase()
        }
        
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
    async buscarTodos() {
      this.loading = true
      try {
        const res = await fetch(API)
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        const data = await res.json()
        this.rows = data
        console.log('Empresas carregadas:', this.rows.length)
      } catch (error) {
        console.error('Erro ao carregar empresas:', error)
        this.showToast('Erro ao carregar empresas.', 'error')
      } finally {
        this.loading = false
      }
    },


    limparFiltros() {
      this.filtros = {
        cnpj: '',
        razaoSocial: '',
        telefone: '',
        email: ''
      }
      this.showToast('Filtros limpos', 'info')
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

    formatarCNPJ(cnpj) {
      if (!cnpj) return '-'
      const numeros = cnpj.replace(/\D/g, '')
      if (numeros.length !== 14) return cnpj
      return numeros.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/, '$1.$2.$3/$4-$5')
    },

    formatarTelefone(telefone) {
      if (!telefone) return '-'
      const numeros = telefone.replace(/\D/g, '')
      if (numeros.length === 10) {
        return numeros.replace(/^(\d{2})(\d{4})(\d{4})$/, '($1) $2-$3')
      } else if (numeros.length === 11) {
        return numeros.replace(/^(\d{2})(\d{5})(\d{4})$/, '($1) $2-$3')
      }
      return telefone
    },

    showToast(message, type = 'success') {
      this.toast = { visible: true, message, type }
      setTimeout(() => { this.toast.visible = false }, 3200)
    }
  }
}
</script>

<style scoped>
.empresas-page { max-width: 1200px; margin: 0 auto; }

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
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
}
.filters-wrap {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}
.filter-input {
  padding: 8px 12px;
  border: 1.5px solid #e0e0e0;
  border-radius: 7px;
  font-size: 0.85rem;
  width: 150px;
  outline: none;
  transition: all 0.2s;
}
.filter-input:focus {
  border-color: #42b983;
  box-shadow: 0 0 0 2px rgba(66, 185, 131, 0.1);
}

.total-badge {
  font-size: 0.82rem;
  color: #95a5a6;
  background: #f5f5f5;
  padding: 4px 12px;
  border-radius: 20px;
  white-space: nowrap;
}

.table-wrapper { overflow-x: auto; }


.data-table { width: 100%; border-collapse: collapse; font-size: 0.92rem; }

.data-table thead tr { background: #f8f9fa; }
.data-table th {
  padding: 13px 16px;
  text-align: left;
  font-size: 0.78rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: .06em;
  color: #95a5a6;
  border-bottom: 2px solid #ecf0f1;
  cursor: pointer;
  user-select: none;
  white-space: nowrap;
}
.data-table th:hover { color: #2c3e50; }
.sort-icon { font-size: 0.75rem; margin-left: 4px; }

.data-table td {
  padding: 12px 16px;
  border-bottom: 1px solid #f4f4f4;
  color: #34495e;
  vertical-align: middle;
}
.data-table tbody tr:hover { background: #fafffe; }
.data-table tbody tr:last-child td { border-bottom: none; }

.col-cnpj { width: 160px; }
.col-razao { min-width: 250px; }
.col-telefone { width: 140px; }
.col-email { min-width: 220px; }


.empty-state {
  text-align: center;
  color: #bdc3c7;
  font-style: italic;
  padding: 40px !important;
}

.hint {
  margin-top: 14px;
  font-size: 0.8rem;
  color: #bdc3c7;
  text-align: center;
}

@media (max-width: 768px) {
  .empresas-page { margin: 0 16px; }
  .filter-input { width: 100%; }
  .filters-wrap { width: 100%; }

}
</style>