<template>
  <div class="profile-page container">
    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />

    <div class="page-header animate-fade">
      <div>
        <h1 class="page-title">Meu Perfil</h1>
        <p class="page-subtitle">Gerencie suas informações pessoais</p>
      </div>
      <div class="header-actions">
        <div class="profile-badge">
          <span class="badge-role">{{ userRole }}</span>
        </div>
      </div>
    </div>

    <div class="profile-container">
      <div class="profile-sidebar animate-fade">
        <div class="profile-avatar">
          <div class="avatar-large">
            {{ userInitials }}
          </div>
          <h3>{{ user?.razaoSocial || user?.username }}</h3>
          <p class="user-role">{{ userRole }}</p>
          <p class="user-since">Membro desde {{ formatDate(user?.createdAt) }}</p>
        </div>
        
        <div class="profile-stats">
          <div class="stat-item">
            <span class="stat-label">Último acesso</span>
            <span class="stat-value">{{ formatDate(lastLogin) }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Status</span>
            <span class="stat-value status-active">Ativo</span>
          </div>
        </div>
        
        <div class="profile-menu">
          <button @click="activeTab = 'info'" :class="['menu-item', { active: activeTab === 'info' }]">
            📋 Informações Pessoais
          </button>
          <button @click="activeTab = 'security'" :class="['menu-item', { active: activeTab === 'security' }]">
            🔒 Segurança
          </button>
          <button @click="activeTab = 'address'" :class="['menu-item', { active: activeTab === 'address' }]">
            📍 Endereço
          </button>
        </div>
      </div>

      <div class="profile-content animate-fade">
        <!-- Aba Informações Pessoais -->
        <div v-if="activeTab === 'info'" class="profile-card">
          <h2>📋 Informações Pessoais</h2>
          <form @submit.prevent="updateProfile" class="profile-form">
            <div class="form-grid">
              <div class="form-group full">
                <label>Razão Social *</label>
                <input v-model="form.razaoSocial" type="text" required />
              </div>
              
              <div class="form-group">
                <label>CNPJ *</label>
                <input v-model="form.cnpj" type="text" disabled class="field-disabled" />
              </div>
              
              <div class="form-group">
                <label>Usuário *</label>
                <input v-model="form.usuario" type="text" disabled class="field-disabled" />
              </div>
              
              <div class="form-group">
                <label>Telefone</label>
                <input v-model="form.telefone" type="text" placeholder="(00) 00000-0000" />
              </div>
              
              <div class="form-group">
                <label>E-mail</label>
                <input v-model="form.email" type="email" placeholder="contato@empresa.com" />
              </div>
              
              <div class="form-group full">
                <label>Site</label>
                <input v-model="form.site" type="url" placeholder="https://www.empresa.com" />
              </div>
            </div>
            
            <div class="form-actions">
              <button type="button" @click="cancelChanges" class="btn-cancel">Cancelar</button>
              <button type="submit" class="btn-save" :disabled="saving">
                {{ saving ? 'Salvando...' : 'Salvar Alterações' }}
              </button>
            </div>
          </form>
        </div>

        <!-- Aba Segurança -->
        <div v-if="activeTab === 'security'" class="profile-card">
          <h2>🔒 Alterar Senha</h2>
          <form @submit.prevent="updatePassword" class="profile-form">
            <div class="form-grid">
              <div class="form-group full">
                <label>Senha Atual *</label>
                <div class="password-wrapper">
                  <input :type="showCurrentPassword ? 'text' : 'password'" v-model="passwordForm.currentPassword" required />
                  <button type="button" class="toggle-password" @click="showCurrentPassword = !showCurrentPassword">
                    {{ showCurrentPassword ? '🙈' : '👁️' }}
                  </button>
                </div>
              </div>
              
              <div class="form-group full">
                <label>Nova Senha *</label>
                <div class="password-wrapper">
                  <input :type="showNewPassword ? 'text' : 'password'" v-model="passwordForm.newPassword" required />
                  <button type="button" class="toggle-password" @click="showNewPassword = !showNewPassword">
                    {{ showNewPassword ? '🙈' : '👁️' }}
                  </button>
                </div>
                <span class="password-hint">Mínimo 6 caracteres</span>
              </div>
              
              <div class="form-group full">
                <label>Confirmar Nova Senha *</label>
                <div class="password-wrapper">
                  <input :type="showConfirmPassword ? 'text' : 'password'" v-model="passwordForm.confirmPassword" required />
                  <button type="button" class="toggle-password" @click="showConfirmPassword = !showConfirmPassword">
                    {{ showConfirmPassword ? '🙈' : '👁️' }}
                  </button>
                </div>
              </div>
            </div>
            
            <div class="form-actions">
              <button type="button" @click="cancelPassword" class="btn-cancel">Cancelar</button>
              <button type="submit" class="btn-save" :disabled="updatingPassword">
                {{ updatingPassword ? 'Atualizando...' : 'Atualizar Senha' }}
              </button>
            </div>
          </form>
        </div>

        <!-- Aba Endereço -->
        <div v-if="activeTab === 'address'" class="profile-card">
          <h2>📍 Endereço</h2>
          <form @submit.prevent="updateAddress" class="profile-form">
            <div class="form-grid">
              <div class="form-group">
                <label>CEP</label>
                <div class="cep-wrapper">
                  <input v-model="form.cep" type="text" placeholder="00000-000" @blur="buscarCEP" />
                  <button type="button" class="btn-cep" @click="buscarCEP">🔍 Buscar</button>
                </div>
              </div>
              
              <div class="form-group full">
                <label>Logradouro</label>
                <input v-model="form.logradouro" type="text" />
              </div>
              
              <div class="form-group">
                <label>Número</label>
                <input v-model="form.numero" type="text" placeholder="Nº" />
              </div>
              
              <div class="form-group">
                <label>Complemento</label>
                <input v-model="form.complemento" type="text" placeholder="Sala, Andar..." />
              </div>
              
              <div class="form-group">
                <label>Bairro</label>
                <input v-model="form.bairro" type="text" />
              </div>
              
              <div class="form-group">
                <label>Município</label>
                <input v-model="form.municipio" type="text" />
              </div>
              
              <div class="form-group">
                <label>UF</label>
                <select v-model="form.uf">
                  <option value="">Selecione</option>
                  <option v-for="uf in ufs" :key="uf.sigla" :value="uf.sigla">
                    {{ uf.sigla }} - {{ uf.nome }}
                  </option>
                </select>
              </div>
            </div>
            
            <div class="form-actions">
              <button type="button" @click="cancelAddress" class="btn-cancel">Cancelar</button>
              <button type="submit" class="btn-save" :disabled="savingAddress">
                {{ savingAddress ? 'Salvando...' : 'Salvar Endereço' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ToastNotification from '@/components/ToastNotification.vue'
import authService from '@/services/auth'
import apiService from '@/services/api'

const API = 'http://localhost:8081/empresa'
const API_CEP = 'https://viacep.com.br/ws'

export default {
  name: 'Profile',
  components: { ToastNotification },
  data() {
    return {
      loading: true,
      saving: false,
      updatingPassword: false,
      savingAddress: false,
      activeTab: 'info',
      showCurrentPassword: false,
      showNewPassword: false,
      showConfirmPassword: false,
      toast: { visible: false, message: '', type: 'success' },
      user: null,
      form: {
        id: null,
        razaoSocial: '',
        cnpj: '',
        usuario: '',
        telefone: '',
        email: '',
        site: '',
        logradouro: '',
        numero: '',
        complemento: '',
        bairro: '',
        cep: '',
        municipio: '',
        uf: ''
      },
      passwordForm: {
        currentPassword: '',
        newPassword: '',
        confirmPassword: ''
      },
      lastLogin: new Date(),
      ufs: [
        { sigla: 'AC', nome: 'Acre' }, { sigla: 'AL', nome: 'Alagoas' },
        { sigla: 'AP', nome: 'Amapá' }, { sigla: 'AM', nome: 'Amazonas' },
        { sigla: 'BA', nome: 'Bahia' }, { sigla: 'CE', nome: 'Ceará' },
        { sigla: 'DF', nome: 'Distrito Federal' }, { sigla: 'ES', nome: 'Espírito Santo' },
        { sigla: 'GO', nome: 'Goiás' }, { sigla: 'MA', nome: 'Maranhão' },
        { sigla: 'MT', nome: 'Mato Grosso' }, { sigla: 'MS', nome: 'Mato Grosso do Sul' },
        { sigla: 'MG', nome: 'Minas Gerais' }, { sigla: 'PA', nome: 'Pará' },
        { sigla: 'PB', nome: 'Paraíba' }, { sigla: 'PR', nome: 'Paraná' },
        { sigla: 'PE', nome: 'Pernambuco' }, { sigla: 'PI', nome: 'Piauí' },
        { sigla: 'RJ', nome: 'Rio de Janeiro' }, { sigla: 'RN', nome: 'Rio Grande do Norte' },
        { sigla: 'RS', nome: 'Rio Grande do Sul' }, { sigla: 'RO', nome: 'Rondônia' },
        { sigla: 'RR', nome: 'Roraima' }, { sigla: 'SC', nome: 'Santa Catarina' },
        { sigla: 'SP', nome: 'São Paulo' }, { sigla: 'SE', nome: 'Sergipe' },
        { sigla: 'TO', nome: 'Tocantins' }
      ]
    }
  },
  computed: {
    userInitials() {
      const name = this.form.razaoSocial || this.form.usuario || 'U'
      return name.substring(0, 2).toUpperCase()
    },
    userRole() {
      return this.user?.role === 'ADMIN' ? 'Administrador' : 'Usuário'
    }
  },
  mounted() {
    this.loadUserData()
  },
  methods: {
    async loadUserData() {
      this.loading = true
      try {
        const userData = authService.getUser()
        if (userData?.id) {
          const response = await apiService.get(`/empresa/${userData.id}`)
          this.user = response
          this.form = { ...response }
        }
      } catch (error) {
        this.showToast('Erro ao carregar dados do usuário', 'error')
      } finally {
        this.loading = false
      }
    },
    
    async updateProfile() {
      this.saving = true
      try {
        await apiService.put(`/empresa/${this.form.id}`, this.form)
        this.showToast('Perfil atualizado com sucesso!', 'success')
        this.loadUserData()
      } catch (error) {
        this.showToast('Erro ao atualizar perfil', 'error')
      } finally {
        this.saving = false
      }
    },
    
    async updatePassword() {
      if (this.passwordForm.newPassword !== this.passwordForm.confirmPassword) {
        this.showToast('As senhas não coincidem', 'error')
        return
      }
      
      if (this.passwordForm.newPassword.length < 6) {
        this.showToast('A nova senha deve ter no mínimo 6 caracteres', 'error')
        return
      }
      
      this.updatingPassword = true
      try {
        const payload = { ...this.form }
        payload.senha = this.passwordForm.newPassword
        await apiService.put(`/empresa/${this.form.id}`, payload)
        this.showToast('Senha atualizada com sucesso!', 'success')
        this.passwordForm = { currentPassword: '', newPassword: '', confirmPassword: '' }
      } catch (error) {
        this.showToast('Erro ao atualizar senha', 'error')
      } finally {
        this.updatingPassword = false
      }
    },
    
    async updateAddress() {
      this.savingAddress = true
      try {
        await apiService.put(`/empresa/${this.form.id}`, this.form)
        this.showToast('Endereço atualizado com sucesso!', 'success')
      } catch (error) {
        this.showToast('Erro ao atualizar endereço', 'error')
      } finally {
        this.savingAddress = false
      }
    },
    
    async buscarCEP() {
      const cep = this.form.cep.replace(/\D/g, '')
      if (cep.length !== 8) {
        this.showToast('CEP inválido', 'error')
        return
      }
      
      try {
        const response = await fetch(`${API_CEP}/${cep}/json/`)
        const data = await response.json()
        
        if (!data.erro) {
          this.form.logradouro = data.logradouro
          this.form.bairro = data.bairro
          this.form.municipio = data.localidade
          this.form.uf = data.uf
          this.showToast('CEP encontrado!', 'success')
        } else {
          this.showToast('CEP não encontrado', 'error')
        }
      } catch (error) {
        this.showToast('Erro ao buscar CEP', 'error')
      }
    },
    
    cancelChanges() {
      this.loadUserData()
    },
    
    cancelPassword() {
      this.passwordForm = { currentPassword: '', newPassword: '', confirmPassword: '' }
    },
    
    cancelAddress() {
      this.loadUserData()
    },
    
    formatDate(date) {
      if (!date) return 'Não informado'
      return new Date(date).toLocaleDateString('pt-BR')
    },
    
    showToast(message, type) {
      this.toast = { visible: true, message, type }
      setTimeout(() => { this.toast.visible = false }, 3200)
    }
  }
}
</script>

<style scoped>
.profile-page {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  margin-bottom: 2rem;
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

.profile-badge {
  background: linear-gradient(135deg, #818cf8, #6366f1);
  padding: 0.5rem 1.5rem;
  border-radius: 2rem;
}

.badge-role {
  color: white;
  font-weight: 600;
}

.profile-container {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 2rem;
}

.profile-sidebar {
  background: white;
  border-radius: 1rem;
  padding: 2rem;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  height: fit-content;
}

[data-theme="dark"] .profile-sidebar {
  background: #1f2937;
}

.profile-avatar {
  text-align: center;
  margin-bottom: 2rem;
}

.avatar-large {
  width: 100px;
  height: 100px;
  background: linear-gradient(135deg, #818cf8, #6366f1);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
  font-weight: 700;
  color: white;
  margin: 0 auto 1rem;
}

.profile-avatar h3 {
  margin-bottom: 0.25rem;
  color: #1f2937;
}

[data-theme="dark"] .profile-avatar h3 {
  color: white;
}

.user-role {
  color: #6366f1;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.user-since {
  font-size: 0.75rem;
  color: #6b7280;
}

.profile-stats {
  background: #f9fafb;
  border-radius: 0.75rem;
  padding: 1rem;
  margin-bottom: 1.5rem;
}

[data-theme="dark"] .profile-stats {
  background: #374151;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.stat-label {
  font-size: 0.75rem;
  color: #6b7280;
}

.stat-value {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1f2937;
}

[data-theme="dark"] .stat-value {
  color: white;
}

.status-active {
  color: #10b981;
}

.profile-menu {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.menu-item {
  padding: 0.75rem 1rem;
  background: transparent;
  border: none;
  border-radius: 0.5rem;
  text-align: left;
  cursor: pointer;
  transition: all 0.2s;
  color: #6b7280;
}

.menu-item:hover {
  background: #f3f4f6;
}

.menu-item.active {
  background: linear-gradient(135deg, #818cf8, #6366f1);
  color: white;
}

.profile-content {
  background: white;
  border-radius: 1rem;
  padding: 2rem;
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}

[data-theme="dark"] .profile-content {
  background: #1f2937;
}

.profile-card h2 {
  margin-bottom: 1.5rem;
  color: #1f2937;
}

[data-theme="dark"] .profile-card h2 {
  color: white;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group.full {
  grid-column: 1 / -1;
}

.form-group label {
  font-size: 0.875rem;
  font-weight: 600;
  color: #374151;
}

[data-theme="dark"] .form-group label {
  color: #e5e7eb;
}

.form-group input, .form-group select {
  padding: 0.75rem;
  border: 1.5px solid #e5e7eb;
  border-radius: 0.5rem;
  transition: all 0.2s;
  background: white;
}

[data-theme="dark"] .form-group input,
[data-theme="dark"] .form-group select {
  background: #374151;
  border-color: #4b5563;
  color: white;
}

.field-disabled {
  background: #f3f4f6;
  cursor: not-allowed;
}

[data-theme="dark"] .field-disabled {
  background: #4b5563;
}

.password-wrapper {
  display: flex;
  gap: 0.5rem;
}

.password-wrapper input {
  flex: 1;
}

.toggle-password {
  padding: 0.5rem 1rem;
  background: #f3f4f6;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  cursor: pointer;
}

[data-theme="dark"] .toggle-password {
  background: #4b5563;
  border-color: #6b7280;
  color: white;
}

.cep-wrapper {
  display: flex;
  gap: 0.5rem;
}

.cep-wrapper input {
  flex: 1;
}

.btn-cep {
  padding: 0.5rem 1rem;
  background: #6366f1;
  color: white;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
}

.password-hint {
  font-size: 0.7rem;
  color: #6b7280;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.btn-cancel {
  padding: 0.75rem 1.5rem;
  background: #f3f4f6;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.2s;
}

[data-theme="dark"] .btn-cancel {
  background: #4b5563;
  color: white;
}

.btn-save {
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #10b981, #059669);
  color: white;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.btn-save:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .profile-container {
    grid-template-columns: 1fr;
  }
  
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .btn-cancel, .btn-save {
    width: 100%;
  }
}
</style>