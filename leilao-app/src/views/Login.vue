<template>
  <div class="login-container">
    <div class="login-card animate-fade">
      <div class="login-header">
        <div class="logo">🔨 LeilãoPro</div>
        <h2>Acesso ao Sistema</h2>
        <p>Digite suas credenciais para continuar</p>
      </div>

      <form @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label>Usuário</label>
          <div class="input-wrapper">
            <span class="input-icon">👤</span>
            <input
              v-model="username"
              type="text"
              placeholder="Digite seu usuário"
              required
              :disabled="loading"
            />
          </div>
        </div>

        <div class="form-group">
          <label>Senha</label>
          <div class="input-wrapper">
            <span class="input-icon">🔒</span>
            <input
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="Digite sua senha"
              required
              :disabled="loading"
            />
            <button type="button" class="toggle-password" @click="showPassword = !showPassword">
              {{ showPassword ? '🙈' : '👁️' }}
            </button>
          </div>
        </div>

        <div v-if="errorMessage" class="error-message">
          <span class="error-icon">⚠️</span>
          {{ errorMessage }}
        </div>

        <button type="submit" class="btn-login" :disabled="loading">
          <span v-if="loading" class="spinner"></span>
          <span v-else>🔓 Entrar no Sistema</span>
        </button>
      </form>

      <div class="login-footer">
        <p>Sistema de Gerenciamento de Leilões</p>
        <small>© 2024 - Todos os direitos reservados</small>
      </div>
    </div>
  </div>
</template>

<script>
import authService from '@/services/auth'

export default {
  name: 'Login',
  data() {
    return {
      username: '',
      password: '',
      showPassword: false,
      loading: false,
      errorMessage: ''
    }
  },
  mounted() {
    // Se já estiver logado, redirecionar para home
    if (authService.isAuthenticated()) {
      this.$router.push('/')
    }
  },
  methods: {
    async handleLogin() {
      if (!this.username || !this.password) {
        this.errorMessage = 'Preencha todos os campos'
        return
      }

      this.loading = true
      this.errorMessage = ''

      try {
        await authService.login(this.username, this.password)
        this.$router.push('/')
      } catch (error) {
        this.errorMessage = error.message || 'Erro ao fazer login. Verifique suas credenciais.'
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  background: white;
  border-radius: 1rem;
  padding: 2rem;
  max-width: 450px;
  width: 100%;
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
}

.logo {
  font-size: 2rem;
  font-weight: bold;
  color: #4f46e5;
  margin-bottom: 1rem;
}

.login-header h2 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
  color: #1f2937;
}

.login-header p {
  color: #6b7280;
  font-size: 0.875rem;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-size: 0.875rem;
  font-weight: 600;
  color: #374151;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-icon {
  position: absolute;
  left: 12px;
  font-size: 1rem;
  opacity: 0.6;
}

.input-wrapper input {
  width: 100%;
  padding: 10px 12px 10px 36px;
  border: 1.5px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 0.9375rem;
  transition: all 0.2s;
}

.input-wrapper input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.toggle-password {
  position: absolute;
  right: 12px;
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1rem;
}

.error-message {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px;
  background: #fee2e2;
  border-radius: 0.5rem;
  color: #dc2626;
  font-size: 0.875rem;
}

.btn-login {
  background: linear-gradient(135deg, #4f46e5, #7c3aed);
  color: white;
  border: none;
  border-radius: 0.5rem;
  padding: 12px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-login:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.btn-login:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.login-footer {
  text-align: center;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
  font-size: 0.75rem;
  color: #9ca3af;
}

.login-footer p {
  margin-bottom: 0.25rem;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade {
  animation: fadeIn 0.5s ease;
}
</style>