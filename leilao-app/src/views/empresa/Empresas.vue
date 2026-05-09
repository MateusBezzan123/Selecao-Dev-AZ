<template>
  <div class="empresas-page">
    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />
    <ConfirmDialog
      :visible="confirm.visible"
      title="Excluir Empresa"
      :message="`Deseja excluir '${confirm.nome}'? Esta ação não pode ser desfeita.`"
      @confirm="deletarConfirmado"
      @cancel="confirm.visible = false"
    />

    <div class="page-header">
      <div class="page-title">
        <span class="page-icon">🏢</span>
        <div>
          <h1>Empresas</h1>
          <p>Gerencie as empresas cadastradas no sistema</p>
        </div>
      </div>
      <router-link to="/empresa" class="btn-new">+ Nova Empresa</router-link>
    </div>

    <div v-if="loading" class="loading-wrap">
      <div class="spinner"></div>
      <span>Carregando...</span>
    </div>

    <div v-else class="table-card">
      <div class="table-toolbar">
        <div class="filters-wrap">
          <input v-model="filtros.cnpj"        class="filter-input" placeholder="🔍 CNPJ" />
          <input v-model="filtros.razaoSocial"  class="filter-input" placeholder="🔍 Razão Social" />
          <input v-model="filtros.telefone"     class="filter-input" placeholder="🔍 Telefone" />
          <input v-model="filtros.email"        class="filter-input" placeholder="🔍 E-mail" />
        </div>
        <span class="total-badge">{{ filteredRows.length }} registro(s)</span>
      </div>

      <div class="table-wrapper">
        <table class="data-table">
          <thead>
            <tr>
              <th @click="sortBy('cnpj')">CNPJ <span class="sort-icon">{{ sortIcon('cnpj') }}</span></th>
              <th @click="sortBy('razaoSocial')">Razão Social <span class="sort-icon">{{ sortIcon('razaoSocial') }}</span></th>
              <th @click="sortBy('telefone')">Telefone <span class="sort-icon">{{ sortIcon('telefone') }}</span></th>
              <th @click="sortBy('email')">E-mail <span class="sort-icon">{{ sortIcon('email') }}</span></th>
              <th class="col-acoes">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in filteredRows" :key="row.id">
              <td>{{ formatarCNPJ(row.cnpj) }}</td>
              <td>{{ row.razaoSocial }}</td>
              <td>{{ formatarTelefone(row.telefone) }}</td>
              <td>{{ row.email || '—' }}</td>
              <td class="col-acoes">
                <router-link :to="`/empresa/${row.id}`" class="btn-edit" title="Editar">✏️</router-link>
                <button class="btn-delete" title="Excluir" @click="confirmarDelecao(row)">🗑️</button>
              </td>
            </tr>
            <tr v-if="filteredRows.length === 0">
              <td colspan="5" class="empty-state">Nenhuma empresa encontrada.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <p class="hint">💡 Utilize os filtros para buscar empresas específicas.</p>
  </div>
</template>

<script>
import ToastNotification from '@/components/ToastNotification.vue'
import ConfirmDialog     from '@/components/ConfirmDialog.vue'

const API = 'http://localhost:8081/empresa'

export default {
  name: 'Empresas',
  components: { ToastNotification, ConfirmDialog },

  data() {
    return {
      rows:    [],
      loading: true,
      sortKey: 'razaoSocial',
      sortDir: 'asc',
      toast:   { visible: false, message: '', type: 'success' },
      confirm: { visible: false, nome: '', id: null },
      filtros: { cnpj: '', razaoSocial: '', telefone: '', email: '' }
    }
  },

  computed: {
    filteredRows() {
      let list = [...this.rows]
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
      return [...list].sort((a, b) => {
        let va = (a[this.sortKey] || '').toLowerCase()
        let vb = (b[this.sortKey] || '').toLowerCase()
        if (va === vb) return 0
        return (va < vb ? -1 : 1) * (this.sortDir === 'asc' ? 1 : -1)
      })
    }
  },

  mounted() { this.buscarTodos() },

  methods: {
    async buscarTodos() {
      this.loading = true
      try {
        const res = await fetch(API)
        this.rows = await res.json()
      } catch {
        this.showToast('Erro ao carregar empresas.', 'error')
      } finally {
        this.loading = false
      }
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
        this.showToast('Empresa excluída com sucesso.', 'success')
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

    showToast(msg, type = 'success') {
      this.toast = { visible: true, message: msg, type }
      setTimeout(() => { this.toast.visible = false }, 3200)
    }
  }
}
</script>

<style scoped>
.empresas-page { max-width: 1200px; margin: 0 auto; }

.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
.page-title  { display: flex; align-items: center; gap: 14px; }
.page-icon   { font-size: 2.2rem; }
.page-title h1 { font-size: 1.6rem; font-weight: 700; color: #2c3e50; margin: 0; }
.page-title p  { font-size: 0.85rem; color: #95a5a6; margin: 2px 0 0; }

.btn-new { display: inline-block; padding: 10px 22px; background: #42b983; color: #fff; text-decoration: none; border-radius: 7px; font-size: 0.92rem; font-weight: 700; transition: background .2s; }
.btn-new:hover { background: #369870; }

.loading-wrap { display: flex; align-items: center; justify-content: center; gap: 14px; padding: 60px; color: #7f8c8d; }
.spinner { width: 28px; height: 28px; border: 3px solid #ddd; border-top-color: #42b983; border-radius: 50%; animation: spin .7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

.table-card { background: #fff; border-radius: 12px; box-shadow: 0 2px 16px rgba(0,0,0,0.08); overflow: hidden; }
.table-toolbar { padding: 16px 20px; border-bottom: 1px solid #f0f0f0; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }

.filters-wrap  { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
.filter-input  { padding: 8px 12px; border: 1.5px solid #e0e0e0; border-radius: 7px; font-size: 0.85rem; width: 150px; outline: none; transition: all .2s; }
.filter-input:focus { border-color: #42b983; box-shadow: 0 0 0 2px rgba(66,185,131,.1); }

.total-badge { font-size: 0.82rem; color: #95a5a6; background: #f5f5f5; padding: 4px 12px; border-radius: 20px; }

.table-wrapper { overflow-x: auto; }

.data-table { width: 100%; border-collapse: collapse; font-size: 0.92rem; }
.data-table thead tr { background: #f8f9fa; }
.data-table th { padding: 13px 16px; text-align: left; font-size: 0.78rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: #95a5a6; border-bottom: 2px solid #ecf0f1; cursor: pointer; user-select: none; white-space: nowrap; }
.data-table th:hover { color: #2c3e50; }

.sort-icon { font-size: 0.75rem; margin-left: 4px; }

.data-table td { padding: 12px 16px; border-bottom: 1px solid #f4f4f4; color: #34495e; vertical-align: middle; }
.data-table tbody tr:hover { background: #fafffe; }
.data-table tbody tr:last-child td { border-bottom: none; }

.col-acoes { width: 100px; text-align: center; }

.btn-edit   { display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; background: #eaf7f1; border-radius: 6px; text-decoration: none; font-size: 0.88rem; margin: 0 2px; transition: background .2s; }
.btn-edit:hover { background: #d0f0e2; }
.btn-delete { width: 32px; height: 32px; background: #fdecea; border: none; border-radius: 6px; cursor: pointer; font-size: 0.88rem; margin: 0 2px; transition: background .2s; }
.btn-delete:hover { background: #f9c9c5; }

.empty-state { text-align: center; color: #bdc3c7; font-style: italic; padding: 40px !important; }

.hint { margin-top: 14px; font-size: 0.8rem; color: #bdc3c7; text-align: center; }
</style>