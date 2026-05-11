<template>
  <div id="app" :data-theme="theme">
    <header class="app-header" v-if="$route.path !== '/login'">
      <div class="container">
        <div class="header-content">
          <div class="logo" @click="goToHome">
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

          <div class="header-actions" v-if="isAuthenticated">
            <!-- Dropdown do usuário -->
            <div class="user-dropdown" @click="toggleUserMenu">
              <div class="user-info">
                <div class="user-avatar">
                  {{ userInitials }}
                </div>
                <span class="user-name">{{ userName }}</span>
                <span class="dropdown-arrow">▼</span>
              </div>
              
              <transition name="dropdown">
                <div v-if="showUserMenu" class="dropdown-menu">
                  <div class="dropdown-header">
                    <div class="dropdown-avatar">
                      {{ userInitials }}
                    </div>
                    <div class="dropdown-user-info">
                      <div class="dropdown-username">{{ userName }}</div>
                      <div class="dropdown-userrole">Usuário</div>
                    </div>
                  </div>
                  
                  <div class="dropdown-divider"></div>
                  
                  <button @click="goToProfile" class="dropdown-item">
                    <span class="item-icon">👤</span>
                    Meu Perfil
                  </button>
                  
                  <button @click="goToSettings" class="dropdown-item">
                    <span class="item-icon">⚙️</span>
                    Configurações
                  </button>
                  
                  <div class="dropdown-divider"></div>
                  
                  <button @click="confirmLogout" class="dropdown-item logout-item">
                    <span class="item-icon">🚪</span>
                    Sair do Sistema
                  </button>
                </div>
              </transition>
            </div>
            
            <button @click="toggleTheme" class="theme-toggle" :title="theme === 'dark' ? 'Modo claro' : 'Modo escuro'">
              {{ theme === 'dark' ? '☀️' : '🌙' }}
            </button>
          </div>
          
          <div class="header-actions" v-else>
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

    <footer class="app-footer" v-if="$route.path !== '/login'">
      <div class="container">
        <p>&copy; 2024 LeilãoPro - Sistema de Gerenciamento de Leilões</p>
      </div>
    </footer>

    <Modal 
      :visible="showLogoutModal" 
      @update:visible="showLogoutModal = $event"
      title="Confirmar Saída"
      size="sm"
    >
      <div class="logout-modal-content">
        <div class="logout-icon">🚪</div>
        <p>Tem certeza que deseja sair do sistema?</p>
        <p class="logout-warning">Você precisará fazer login novamente para acessar suas informações.</p>
      </div>
      
      <template #footer>
        <button @click="showLogoutModal = false" class="modal-cancel-btn">Cancelar</button>
        <button @click="handleLogout" class="modal-confirm-btn">Sair do Sistema</button>
      </template>
    </Modal>
  </div>
</template>

<script>
import authService from '@/services/auth'
import Modal from '@/components/ui/Modal.vue'

export default {
  name: 'App',
  components: { Modal },
  data() {
    return {
      theme: localStorage.getItem('theme') || 'light',
      showUserMenu: false,
      showLogoutModal: false,
      sessionTimeout: null
    }
  },
  computed: {
    isAuthenticated() {
      return authService.isAuthenticated()
    },
    user() {
      return authService.getUser()
    },
    userName() {
      return this.user?.username || 'Usuário'
    },
    userInitials() {
      if (!this.userName) return 'U'
      const parts = this.userName.split(/[._]/)
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase()
      }
      return this.userName.substring(0, 2).toUpperCase()
    }
  },
  mounted() {
    this.applyTheme()
    this.startSessionMonitor()
    this.setupEventListeners()
  },
  beforeDestroy() {
    this.clearSessionMonitor()
    this.removeEventListeners()
  },
  methods: {
    toggleTheme() {
      this.theme = this.theme === 'dark' ? 'light' : 'dark'
      localStorage.setItem('theme', this.theme)
      this.applyTheme()
    },
    applyTheme() {
      document.documentElement.setAttribute('data-theme', this.theme)
    },
    toggleUserMenu() {
      this.showUserMenu = !this.showUserMenu
    },
    closeUserMenu() {
      this.showUserMenu = false
    },
    goToHome() {
      this.$router.push('/')
      this.closeUserMenu()
    },
    goToProfile() {
      this.$router.push('/profile')
      this.closeUserMenu()
    },
    goToSettings() {
      this.$router.push('/settings')
      this.closeUserMenu()
    },
    confirmLogout() {
      this.showUserMenu = false
      this.showLogoutModal = true
    },
    async handleLogout() {
      this.showLogoutModal = false
      
      this.showToast('Saindo do sistema...', 'info')
      
      setTimeout(async () => {
        try {
          await authService.logoutServer()
        } catch (error) {
          console.error('Erro no logout:', error)
        } finally {
          this.$router.push('/login')
        }
      }, 500)
    },
    showToast(message, type) {
      window.dispatchEvent(new CustomEvent('show-toast', { 
        detail: { message, type } 
      }))
    },
    startSessionMonitor() {

      let inactivityTimer
    
      const resetTimer = () => {
        if (inactivityTimer) clearTimeout(inactivityTimer)
        inactivityTimer = setTimeout(() => {
          if (this.isAuthenticated && this.$route.path !== '/login') {
            this.autoLogout()
          }
        }, 30 * 60 * 1000)
      }
    
      const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart']
      events.forEach(event => {
        window.addEventListener(event, resetTimer)
      })
    
      resetTimer()
    
      this.$once('hook:beforeDestroy', () => {
        events.forEach(event => {
          window.removeEventListener(event, resetTimer)
        })
        if (inactivityTimer) clearTimeout(inactivityTimer)
      })
    },
    autoLogout() {
      this.showToast('Sessão expirada por inatividade', 'warning')
      setTimeout(() => {
        authService.logout()
        this.$router.push('/login')
      }, 1500)
    },
    clearSessionMonitor() {
      if (this.sessionTimeout) {
        clearTimeout(this.sessionTimeout)
      }
    },
    setupEventListeners() {
      document.addEventListener('click', (e) => {
        if (!e.target.closest('.user-dropdown')) {
          this.showUserMenu = false
        }
      })
      
      window.addEventListener('user-logout', () => {
        this.$router.push('/login')
      })
    },
    removeEventListeners() {
      document.removeEventListener('click', this.closeUserMenu)
      window.removeEventListener('user-logout', this.handleLogout)
    }
  },
  watch: {
    '$route'() {
      this.closeUserMenu()
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

.header-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

/* User Dropdown */
.user-dropdown {
  position: relative;
  cursor: pointer;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: var(--gray-700);
  border-radius: 0.5rem;
  color: white;
  transition: all 0.2s;
}

.user-info:hover {
  background: var(--gray-600);
}

.user-avatar {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, var(--primary-light), var(--primary));
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.875rem;
  font-weight: 600;
}

.user-name {
  font-size: 0.875rem;
  font-weight: 500;
}

.dropdown-arrow {
  font-size: 0.7rem;
  transition: transform 0.2s;
}

.user-dropdown:hover .dropdown-arrow {
  transform: rotate(180deg);
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 0.5rem;
  background: white;
  border-radius: 0.5rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  min-width: 250px;
  z-index: 1000;
  overflow: hidden;
  animation: slideDown 0.2s ease;
}

[data-theme="dark"] .dropdown-menu {
  background: var(--gray-800);
  border: 1px solid var(--gray-700);
}

.dropdown-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: var(--gray-50);
}

[data-theme="dark"] .dropdown-header {
  background: var(--gray-700);
}

.dropdown-avatar {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, var(--primary-light), var(--primary));
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
  font-weight: 700;
  color: white;
}

.dropdown-user-info {
  flex: 1;
}

.dropdown-username {
  font-weight: 600;
  color: var(--gray-800);
  font-size: 0.9375rem;
}

[data-theme="dark"] .dropdown-username {
  color: white;
}

.dropdown-userrole {
  font-size: 0.75rem;
  color: var(--gray-500);
  margin-top: 0.25rem;
}

.dropdown-divider {
  height: 1px;
  background: var(--gray-200);
  margin: 0.5rem 0;
}

[data-theme="dark"] .dropdown-divider {
  background: var(--gray-700);
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 0.75rem 1rem;
  background: transparent;
  border: none;
  cursor: pointer;
  text-align: left;
  transition: all 0.2s;
  font-size: 0.875rem;
  color: var(--gray-700);
}

[data-theme="dark"] .dropdown-item {
  color: var(--gray-300);
}

.dropdown-item:hover {
  background: var(--gray-50);
}

[data-theme="dark"] .dropdown-item:hover {
  background: var(--gray-700);
}

.logout-item {
  color: var(--danger);
}

.logout-item:hover {
  background: #fee2e2;
  color: #dc2626;
}

[data-theme="dark"] .logout-item:hover {
  background: rgba(220, 38, 38, 0.2);
}

.dropdown-enter-active,
.dropdown-leave-active {
  transition: all 0.2s ease;
}

.dropdown-enter,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
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

.logout-modal-content {
  text-align: center;
  padding: 1rem;
}

.logout-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.logout-modal-content p {
  margin-bottom: 0.5rem;
  color: var(--gray-700);
}

.logout-warning {
  font-size: 0.75rem;
  color: var(--gray-500);
}

.modal-cancel-btn {
  padding: 0.5rem 1.5rem;
  background: var(--gray-200);
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.2s;
}

.modal-cancel-btn:hover {
  background: var(--gray-300);
}

.modal-confirm-btn {
  padding: 0.5rem 1.5rem;
  background: var(--danger);
  color: white;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.2s;
}

.modal-confirm-btn:hover {
  background: #c0392b;
  transform: translateY(-2px);
}

.app-main {
  min-height: calc(100vh - 130px);
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
  
  .user-name {
    display: none;
  }
  
  .user-info {
    padding: 0.5rem;
  }
  
  .dropdown-menu {
    min-width: 200px;
    right: -50px;
  }
}
</style>