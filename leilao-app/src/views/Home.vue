<template>
  <div class="home-page">
    <div class="hero-section animate-fade">
      <div class="hero-content">
        <h1 class="hero-title">
          Bem-vindo, <span class="gradient-text">{{ userName }}</span>
        </h1>
        <p class="hero-subtitle">
          {{ welcomeMessage }}
        </p>
        <div class="hero-stats">
          <div class="stat-item" v-for="stat in stats" :key="stat.label">
            <div class="stat-value">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        </div>
      </div>
    </div>

    <div class="container">
      <div class="section-header">
        <h2 class="section-title">📅 Próximos Leilões</h2>
        <router-link to="/leiloes" class="view-all">Ver todos →</router-link>
      </div>
      
      <div class="leiloes-grid">
        <div v-for="leilao in proximosLeiloes" :key="leilao.id" class="leilao-card" @click="verDetalhes(leilao)">
          <div class="card-status" :class="getStatusClass(leilao)">
            {{ getStatus(leilao) }}
          </div>
          <div class="card-code">#{{ leilao.codigo }}</div>
          <h3 class="card-title">{{ leilao.descricao }}</h3>
          <div class="card-info">
            <div class="info-row">
              <span class="info-label">📅 Data:</span>
              <span class="info-value">{{ formatarData(leilao.inicioPrevisto) }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">🏢 Vendedor:</span>
              <span class="info-value">{{ leilao._vendedorNome }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">💰 Total:</span>
              <span class="info-value highlight">{{ formatarMoeda(leilao._total) }}</span>
            </div>
          </div>
          <div class="card-footer">
            <span class="lotes-count">{{ leilao.lotesCount || 0 }} lotes</span>
            <button class="btn-details">Ver detalhes →</button>
          </div>
        </div>
        
        <div v-if="proximosLeiloes.length === 0" class="empty-leiloes">
          <span class="empty-icon">📭</span>
          <p>Nenhum leilão programado nos próximos dias</p>
        </div>
      </div>

      <div class="info-section">
        <div class="info-card">
          <h3>📊 Resumo do Sistema</h3>
          <div class="info-stats">
            <div class="info-stat">
              <span class="info-label">Total de Empresas</span>
              <span class="info-number">{{ stats[0]?.value || 0 }}</span>
            </div>
            <div class="info-stat">
              <span class="info-label">Leilões Realizados</span>
              <span class="info-number">{{ leiloesRealizados }}</span>
            </div>
            <div class="info-stat">
              <span class="info-label">Leilões em Andamento</span>
              <span class="info-number">{{ leiloesEmAndamento }}</span>
            </div>
            <div class="info-stat">
              <span class="info-label">Total Arrecadado</span>
              <span class="info-number">{{ formatarMoeda(totalArrecadado) }}</span>
            </div>
          </div>
        </div>

        <div class="info-card">
          <h3>⚡ Ações Rápidas</h3>
          <div class="quick-actions">
            <button @click="criarNovaEmpresa" class="quick-action">
              ➕ Nova Empresa
            </button>
            <button @click="criarNovoLeilao" class="quick-action">
              🔖 Novo Leilão
            </button>
            <button @click="novaUnidade" class="quick-action">
              📦 Nova Unidade
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import authService from '@/services/auth'

const API_EMPRESA = 'http://localhost:8081/empresa'
const API_UNIDADE = 'http://localhost:8081/unidade'
const API_LEILAO = 'http://localhost:8081/leilao'
const API_LOTE = 'http://localhost:8081/lote'

export default {
  name: 'Home',
  data() {
    return {
      stats: [
        { label: 'Empresas', value: 0, icon: '🏢' },
        { label: 'Leilões', value: 0, icon: '🔖' },
        { label: 'Unidades', value: 0, icon: '📦' }
      ],
      leiloes: [],
      leiloesRealizados: 0,
      leiloesEmAndamento: 0,
      totalArrecadado: 0,
      welcomeMessages: [
        'Bem-vindo de volta! 👋',
        'Que bom ver você por aqui! 😊',
        'Pronto para mais um dia de trabalho? 💪',
        'O sistema está pronto para você! 🚀'
      ]
    }
  },
  computed: {
    userName() {
      const user = authService.getUser()
      return user?.username || 'Usuário'
    },
    welcomeMessage() {
      const randomIndex = Math.floor(Math.random() * this.welcomeMessages.length)
      return this.welcomeMessages[randomIndex]
    },
    proximosLeiloes() {
      const agora = new Date()
      return this.leiloes
        .filter(l => new Date(l.inicioPrevisto) > agora)
        .sort((a, b) => new Date(a.inicioPrevisto) - new Date(b.inicioPrevisto))
        .slice(0, 6)
    }
  },
  mounted() {
    this.carregarStats()
  },
  methods: {
    async carregarStats() {
      try {
        const [empresas, leiloes, unidades, lotes] = await Promise.all([
          fetch(API_EMPRESA).then(r => r.json()),
          fetch(API_LEILAO).then(r => r.json()),
          fetch(API_UNIDADE).then(r => r.json()),
          fetch(API_LOTE).then(r => r.json())
        ])
        
        const totalPorLeilao = {}
        lotes.forEach(l => {
          const sub = Number(l.quantidade) * Number(l.valorInicial)
          totalPorLeilao[l.leilao] = (totalPorLeilao[l.leilao] || 0) + sub
        })
        
        const empresaMap = {}
        empresas.forEach(e => { empresaMap[e.id] = e })

        this.leiloes = leiloes.map(l => ({
          ...l,
          _vendedorNome: empresaMap[l.vendedor]?.razaoSocial || `Empresa #${l.vendedor}`,
          _total: totalPorLeilao[l.id] || 0,
          lotesCount: lotes.filter(lote => lote.leilao === l.id).length
        }))
        
        // Calcular estatísticas
        const agora = new Date()
        this.leiloesEmAndamento = leiloes.filter(l => new Date(l.inicioPrevisto) <= agora).length
        this.leiloesRealizados = leiloes.filter(l => new Date(l.inicioPrevisto) < agora).length
        this.totalArrecadado = this.leiloes.reduce((sum, l) => sum + (l._total || 0), 0)
        
        this.stats[0].value = empresas.length
        this.stats[1].value = leiloes.length
        this.stats[2].value = unidades.length
        
      } catch (error) {
        console.error('Erro ao carregar estatísticas:', error)
      }
    },
    
    formatarData(valor) {
      if (!valor) return '—'
      const d = new Date(valor)
      return d.toLocaleDateString('pt-BR', {
        day: '2-digit', month: '2-digit', year: 'numeric',
        hour: '2-digit', minute: '2-digit'
      })
    },
    
    formatarMoeda(valor) {
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
      }).format(valor || 0)
    },
    
    getStatus(leilao) {
      const dataInicio = new Date(leilao.inicioPrevisto)
      const agora = new Date()
      if (dataInicio > agora) return 'AGENDADO'
      if (dataInicio <= agora) return 'EM ANDAMENTO'
      return 'FINALIZADO'
    },
    
    getStatusClass(leilao) {
      const status = this.getStatus(leilao)
      if (status === 'AGENDADO') return 'status-scheduled'
      if (status === 'EM ANDAMENTO') return 'status-progress'
      return 'status-finished'
    },
    
    verDetalhes(leilao) {
      this.$router.push('/leiloes')
    },
    
    criarNovaEmpresa() {
      this.$router.push('/empresa')
    },
    
    criarNovoLeilao() {
      this.$router.push('/leiloes')
    },
    
    novaUnidade() {
      this.$router.push('/unidades')
    }
  }
}
</script>

<style scoped>
.home-page {
  animation: fadeIn 0.5s ease;
}

.hero-section {
  background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
  color: white;
  padding: 3rem 2rem;
  margin-bottom: 2rem;
  position: relative;
  overflow: hidden;
}

.hero-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320"><path fill="rgba(99,102,241,0.1)" d="M0,96L48,112C96,128,192,160,288,160C384,160,480,128,576,122.7C672,117,768,139,864,154.7C960,170,1056,179,1152,165.3C1248,152,1344,117,1392,101.3L1440,85L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path></svg>') no-repeat bottom;
  background-size: cover;
  opacity: 0.1;
}

.hero-content {
  max-width: 800px;
  margin: 0 auto;
  text-align: center;
  position: relative;
  z-index: 1;
}

.hero-title {
  font-size: 2.5rem;
  font-weight: 800;
  margin-bottom: 1rem;
}

.gradient-text {
  background: linear-gradient(135deg, #818cf8, #10b981);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero-subtitle {
  font-size: 1.125rem;
  color: #9ca3af;
  margin-bottom: 2rem;
}

.hero-stats {
  display: flex;
  justify-content: center;
  gap: 2rem;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: #818cf8;
}

.stat-label {
  font-size: 0.875rem;
  color: #9ca3af;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1.5rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.section-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1f2937;
}

[data-theme="dark"] .section-title {
  color: white;
}

.view-all {
  color: #6366f1;
  text-decoration: none;
  font-weight: 500;
}

.view-all:hover {
  text-decoration: underline;
}

.leiloes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.leilao-card {
  background: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  transition: all 0.3s;
  cursor: pointer;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  position: relative;
}

[data-theme="dark"] .leilao-card {
  background: #1f2937;
}

.leilao-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.card-status {
  position: absolute;
  top: 1rem;
  right: 1rem;
  padding: 0.25rem 0.75rem;
  border-radius: 2rem;
  font-size: 0.7rem;
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

.card-code {
  font-family: monospace;
  font-size: 0.75rem;
  color: #6b7280;
  margin-bottom: 0.5rem;
}

.card-title {
  font-size: 1.1rem;
  font-weight: 600;
  margin-bottom: 1rem;
  color: #1f2937;
}

[data-theme="dark"] .card-title {
  color: white;
}

.card-info {
  margin-bottom: 1rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
}

.info-label {
  color: #6b7280;
}

.info-value {
  color: #1f2937;
  font-weight: 500;
}

[data-theme="dark"] .info-value {
  color: #e5e7eb;
}

.highlight {
  color: #10b981;
  font-weight: 700;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

[data-theme="dark"] .card-footer {
  border-top-color: #374151;
}

.lotes-count {
  font-size: 0.75rem;
  color: #6b7280;
}

.btn-details {
  background: none;
  border: none;
  color: #6366f1;
  cursor: pointer;
  font-weight: 500;
}

.empty-leiloes {
  text-align: center;
  padding: 3rem;
  background: #f9fafb;
  border-radius: 0.75rem;
  color: #6b7280;
}

.empty-icon {
  font-size: 3rem;
  display: block;
  margin-bottom: 1rem;
}

.info-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-top: 2rem;
  margin-bottom: 2rem;
}

.info-card {
  background: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}

[data-theme="dark"] .info-card {
  background: #1f2937;
}

.info-card h3 {
  margin-bottom: 1rem;
  font-size: 1.125rem;
  color: #1f2937;
}

[data-theme="dark"] .info-card h3 {
  color: white;
}

.info-stats {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.info-stat {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid #e5e7eb;
}

[data-theme="dark"] .info-stat {
  border-bottom-color: #374151;
}

.info-label {
  color: #6b7280;
}

.info-number {
  font-size: 1.125rem;
  font-weight: 700;
  color: #6366f1;
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.quick-action {
  padding: 0.75rem;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  cursor: pointer;
  text-align: left;
  transition: all 0.2s;
}

[data-theme="dark"] .quick-action {
  background: #374151;
  border-color: #4b5563;
  color: white;
}

.quick-action:hover {
  background: #6366f1;
  color: white;
  transform: translateX(4px);
  border-color: #6366f1;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade {
  animation: fadeIn 0.5s ease;
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 1.75rem;
  }
  
  .hero-stats {
    flex-direction: column;
    gap: 1rem;
  }
  
  .leiloes-grid {
    grid-template-columns: 1fr;
  }
  
  .info-section {
    grid-template-columns: 1fr;
  }
}
</style>