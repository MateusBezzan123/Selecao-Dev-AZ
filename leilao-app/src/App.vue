<template>
  <div id="app" :data-theme="theme">
    <header class="app-header">
      <div class="container">
        <div class="header-content">
          <div class="logo" @click="$router.push('/')">
            <span class="logo-icon">🔨</span>
            <span class="logo-text">LeilãoPro</span>
          </div>
          
          <nav class="main-nav">
            <router-link to="/" class="nav-link" exact>
              <span class="nav-icon">🏠</span>
              <span>Início</span>
            </router-link>
            <router-link to="/unidades" class="nav-link">
              <span class="nav-icon">📦</span>
              <span>Unidades</span>
            </router-link>
            <router-link to="/empresas" class="nav-link">
              <span class="nav-icon">🏢</span>
              <span>Empresas</span>
            </router-link>
            <router-link to="/leiloes" class="nav-link">
              <span class="nav-icon">🔖</span>
              <span>Leilões</span>
            </router-link>
          </nav>

          <div class="header-actions">
            <button @click="toggleTheme" class="theme-toggle" :title="theme === 'dark' ? 'Modo claro' : 'Modo escuro'">
              {{ theme === 'dark' ? '☀️' : '🌙' }}
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="app-main">
      <transition name="fade" mode="out-in">
        <router-view />
      </transition>
    </main>

    <footer class="app-footer">
      <div class="container">
        <p>&copy; 2024 LeilãoPro - Sistema de Gerenciamento de Leilões</p>
      </div>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      theme: localStorage.getItem('theme') || 'light'
    }
  },
  mounted() {
    this.applyTheme()
  },
  methods: {
    toggleTheme() {
      this.theme = this.theme === 'dark' ? 'light' : 'dark'
      localStorage.setItem('theme', this.theme)
      this.applyTheme()
    },
    applyTheme() {
      document.documentElement.setAttribute('data-theme', this.theme)
    }
  }
}
</script>

<style scoped>
.app-header {
  background: var(--gray-800);
  border-bottom: 1px solid var(--gray-700);
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(10px);
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 70px;
  gap: var(--spacing-lg);
}

.logo {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  cursor: pointer;
  font-size: 1.25rem;
  font-weight: bold;
  color: white;
  transition: transform 0.2s;
}

.logo:hover {
  transform: scale(1.05);
}

.logo-icon {
  font-size: 1.5rem;
}

.main-nav {
  display: flex;
  gap: var(--spacing-sm);
  flex: 1;
  justify-content: center;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  padding: var(--spacing-sm) var(--spacing-md);
  color: var(--gray-300);
  text-decoration: none;
  border-radius: var(--radius-md);
  transition: all 0.2s;
  position: relative;
}

.nav-link:hover {
  background: var(--gray-700);
  color: white;
}

.nav-link.router-link-active {
  background: var(--primary);
  color: white;
}

.nav-icon {
  font-size: 1.1rem;
}

.theme-toggle {
  background: var(--gray-700);
  border: none;
  padding: var(--spacing-sm);
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.2s;
}

.theme-toggle:hover {
  background: var(--gray-600);
  transform: rotate(15deg);
}

/* REMOVIDO O PADDING DO MAIN - AGORA SEM ESPAÇAMENTO */
.app-main {
  min-height: calc(100vh - 130px);
  /* padding: var(--spacing-2xl) 0;  ← REMOVER ESTA LINHA */
}

.app-footer {
  background: var(--gray-800);
  color: var(--gray-400);
  text-align: center;
  padding: var(--spacing-lg) 0;
  margin-top: auto;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter,
.fade-leave-to {
  opacity: 0;
}

@media (max-width: 768px) {
  .nav-text {
    display: none;
  }
  
  .nav-link {
    padding: var(--spacing-sm);
  }
  
  .nav-icon {
    font-size: 1.2rem;
  }
  
  .logo-text {
    display: none;
  }
}
</style>