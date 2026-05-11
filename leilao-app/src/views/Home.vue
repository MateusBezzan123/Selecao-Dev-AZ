<template>
  <div class="home-page">
    <div class="hero-section animate-fade">
      <div class="hero-content">
        <h1 class="hero-title">
          Bem-vindo ao
          <span class="gradient-text">LeilãoPro</span>
        </h1>
        <p class="hero-subtitle">
          Sistema completo para gerenciamento de leilões, empresas e unidades de medida
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
      <div class="features-section">
        <h2 class="section-title">Módulos do Sistema</h2>
        <div class="features-grid">
          <div 
            v-for="feature in features" 
            :key="feature.title"
            class="feature-card"
            @click="$router.push(feature.route)"
          >
            <div class="feature-icon">{{ feature.icon }}</div>
            <h3 class="feature-title">{{ feature.title }}</h3>
            <p class="feature-description">{{ feature.description }}</p>
            <div class="feature-footer">
              <span class="feature-link">Acessar →</span>
            </div>
          </div>
        </div>
      </div>

      <div class="info-section">
        <div class="info-card">
          <h3>📊 Resumo Rápido</h3>
          <div class="info-stats">
            <div class="info-stat">
              <span class="info-label">Total de Empresas</span>
              <span class="info-number">{{ stats[0]?.value || 0 }}</span>
            </div>
            <div class="info-stat">
              <span class="info-label">Leilões Ativos</span>
              <span class="info-number">{{ leiloesAtivos }}</span>
            </div>
            <div class="info-stat">
              <span class="info-label">Unidades</span>
              <span class="info-number">{{ stats[2]?.value || 0 }}</span>
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
const API_EMPRESA = 'http://localhost:8081/empresa'
const API_UNIDADE = 'http://localhost:8081/unidade'
const API_LEILAO = 'http://localhost:8081/leilao'

export default {
  name: 'Home',
  data() {
    return {
      stats: [
        { label: 'Empresas', value: 0, icon: '🏢' },
        { label: 'Leilões', value: 0, icon: '🔖' },
        { label: 'Unidades', value: 0, icon: '📦' }
      ],
      leiloesAtivos: 0,
      features: [
        {
          icon: '🏢',
          title: 'Empresas',
          description: 'Gerencie todas as empresas parceiras, cadastre novos fornecedores e mantenha os dados atualizados.',
          route: '/empresas'
        },
        {
          icon: '🔖',
          title: 'Leilões',
          description: 'Acompanhe todos os leilões, visualize lances, participantes e históricos completos.',
          route: '/leiloes'
        },
        {
          icon: '📦',
          title: 'Unidades',
          description: 'Controle as unidades de medida utilizadas nos produtos e lotes dos leilões.',
          route: '/unidades'
        }
      ]
    }
  },
  mounted() {
    this.carregarStats()
  },
  methods: {
    async carregarStats() {
      try {
        const [empresas, leiloes, unidades] = await Promise.all([
          fetch(API_EMPRESA).then(r => r.json()),
          fetch(API_LEILAO).then(r => r.json()),
          fetch(API_UNIDADE).then(r => r.json())
        ])
        
        this.stats[0].value = empresas.length
        this.stats[1].value = leiloes.length
        this.stats[2].value = unidades.length
        this.leiloesAtivos = leiloes.filter(l => new Date(l.inicioPrevisto) > new Date()).length
      } catch (error) {
        console.error('Erro ao carregar estatísticas:', error)
      }
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
  min-height: calc(100vh - 70px);
}

.hero-section {
  background: linear-gradient(135deg, var(--gray-900) 0%, var(--gray-800) 100%);
  color: white;
  padding: var(--spacing-2xl) var(--spacing-lg);
  /* REMOVIDO margin-bottom: var(--spacing-2xl); */
  margin-bottom: 0; /* ← GARANTIR QUE NÃO TENHA MARGEM */
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
  font-size: 3rem;
  font-weight: 800;
  margin-bottom: var(--spacing-md);
}

.gradient-text {
  background: linear-gradient(135deg, var(--primary-light), var(--secondary));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero-subtitle {
  font-size: 1.125rem;
  color: var(--gray-300);
  margin-bottom: var(--spacing-xl);
}

.hero-stats {
  display: flex;
  justify-content: center;
  gap: var(--spacing-xl);
  margin-top: var(--spacing-xl);
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: var(--primary-light);
}

.stat-label {
  font-size: 0.875rem;
  color: var(--gray-400);
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 var(--spacing-lg);
}

.section-title {
  font-size: 2rem;
  font-weight: 700;
  text-align: center;
  margin-bottom: var(--spacing-xl);
  color: var(--gray-800);
}

.features-section {
  margin-bottom: var(--spacing-2xl);
  margin-top: var(--spacing-2xl);
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: var(--spacing-lg);
  margin-top: var(--spacing-lg);
}

.feature-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: var(--spacing-xl);
  transition: all 0.3s;
  cursor: pointer;
  text-align: center;
  box-shadow: var(--shadow-sm);
}

.feature-card:hover {
  transform: translateY(-8px);
  box-shadow: var(--shadow-xl);
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: var(--spacing-md);
}

.feature-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: var(--spacing-sm);
  color: var(--gray-800);
}

.feature-description {
  color: var(--gray-600);
  line-height: 1.6;
  margin-bottom: var(--spacing-md);
}

.feature-footer {
  margin-top: var(--spacing-md);
}

.feature-link {
  color: var(--primary);
  font-weight: 600;
  text-decoration: none;
}

.info-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: var(--spacing-lg);
  margin-top: var(--spacing-xl);
  margin-bottom: var(--spacing-2xl);
}

.info-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: var(--spacing-lg);
  box-shadow: var(--shadow-sm);
}

.info-card h3 {
  margin-bottom: var(--spacing-md);
  font-size: 1.125rem;
  color: var(--gray-800);
}

.info-stats {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
}

.info-stat {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-sm) 0;
  border-bottom: 1px solid var(--gray-200);
}

.info-label {
  color: var(--gray-600);
}

.info-number {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--primary);
}

.quick-actions {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-sm);
}

.quick-action {
  padding: var(--spacing-md);
  background: var(--gray-50);
  border: 1px solid var(--gray-200);
  border-radius: var(--radius-md);
  cursor: pointer;
  text-align: left;
  transition: all 0.2s;
}

.quick-action:hover {
  background: var(--primary);
  color: white;
  transform: translateX(4px);
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }
  
  .hero-stats {
    flex-direction: column;
    gap: var(--spacing-md);
  }
  
  .features-grid {
    grid-template-columns: 1fr;
  }
  
  .info-section {
    grid-template-columns: 1fr;
  }
  
  .container {
    padding: 0 var(--spacing-md);
  }
}
</style>