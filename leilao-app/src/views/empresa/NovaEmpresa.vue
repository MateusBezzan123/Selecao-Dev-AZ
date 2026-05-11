<template>
  <div class="empresa-form-page container">
    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />

    <div class="page-header animate-fade">
      <div>
        <h1 class="page-title">{{ isEdicao ? 'Editar Empresa' : 'Nova Empresa' }}</h1>
        <p class="page-subtitle">
          {{ isEdicao ? 'Atualize os dados da empresa no sistema' : 'Preencha os dados para cadastrar uma nova empresa' }}
        </p>
      </div>
      <div class="header-actions">
        <div class="step-indicator" v-if="!isEdicao">
          <div class="step" :class="{ active: stepAtual === 1 }">1</div>
          <div class="step-line"></div>
          <div class="step" :class="{ active: stepAtual === 2 }">2</div>
        </div>
        <AppButton variant="outline" @click="$router.push('/empresas')">
          ← Voltar
        </AppButton>
      </div>
    </div>

    <LoadingSkeleton v-if="loading" type="card" />

    <AppCard v-else class="animate-fade">
      <form @submit.prevent="salvar">
        <div v-show="stepAtual === 1" class="form-step">
          <div class="form-header">
            <span class="step-badge">Passo 1 de 2</span>
            <h3>📋 Informações Básicas</h3>
            <p>Dados principais da empresa</p>
          </div>

          <div class="form-grid">
            <div class="form-group full">
              <label>
                Razão Social <span class="required">*</span>
                <span class="label-hint">Nome oficial da empresa</span>
              </label>
              <input 
                v-model="form.razaoSocial" 
                :class="{ 'input-error': erros.razaoSocial }"
                maxlength="64" 
                placeholder="Ex: Empresa Exemplo Ltda" 
                @blur="validarCampo('razaoSocial')"
              />
              <span class="erro-msg" v-if="erros.razaoSocial">{{ erros.razaoSocial }}</span>
              <div class="input-footer">
                <span class="char-count">{{ (form.razaoSocial || '').length }}/64</span>
                <span class="input-hint">Nome completo da empresa</span>
              </div>
            </div>

            <div class="form-group">
              <label>
                CNPJ <span class="required">*</span>
                <span class="label-hint">Apenas números</span>
              </label>
              <input 
                v-model="form.cnpj" 
                :class="{ 'input-error': erros.cnpj }"
                maxlength="18" 
                placeholder="00.000.000/0000-00"
                @input="mascararCNPJ" 
                @blur="validarCampo('cnpj')"
              />
              <span class="erro-msg" v-if="erros.cnpj">{{ erros.cnpj }}</span>
            </div>

            <div class="form-group">
              <label>
                Telefone
                <span class="label-hint">Com DDD</span>
              </label>
              <input 
                v-model="form.telefone" 
                :class="{ 'input-error': erros.telefone }"
                maxlength="15" 
                placeholder="(00) 00000-0000"
                @input="mascararTelefone" 
                @blur="validarCampo('telefone')"
              />
              <span class="erro-msg" v-if="erros.telefone">{{ erros.telefone }}</span>
            </div>

            <div class="form-group">
              <label>E-mail</label>
              <input 
                v-model="form.email" 
                :class="{ 'input-error': erros.email }"
                maxlength="254" 
                type="email" 
                placeholder="contato@empresa.com.br"
                @blur="validarCampo('email')"
              />
              <span class="erro-msg" v-if="erros.email">{{ erros.email }}</span>
            </div>

            <div class="form-group full">
              <label>Site</label>
              <input 
                v-model="form.site" 
                :class="{ 'input-error': erros.site }"
                maxlength="254" 
                placeholder="https://www.empresa.com.br"
                @blur="validarCampo('site')"
              />
              <span class="erro-msg" v-if="erros.site">{{ erros.site }}</span>
            </div>
          </div>
        </div>

        <div v-show="stepAtual === 2" class="form-step">
          <div class="form-header">
            <span class="step-badge">Passo 2 de 2</span>
            <h3>📍 Endereço</h3>
            <p>Localização da empresa</p>
          </div>

          <div class="form-grid">
            <div class="form-group">
              <label>CEP</label>
              <div class="cep-wrapper">
                <input 
                  v-model="form.cep" 
                  :class="{ 'input-error': erros.cep }"
                  maxlength="9" 
                  placeholder="00000-000"
                  @input="mascararCEP" 
                  @blur="validarCampo('cep')"
                />
                <button type="button" class="btn-cep" @click="buscarCEP" :disabled="buscandoCEP">
                  {{ buscandoCEP ? '🔍...' : '🔍 Buscar' }}
                </button>
              </div>
              <span class="erro-msg" v-if="erros.cep">{{ erros.cep }}</span>
            </div>

            <div class="form-group dois-tercos">
              <label>Logradouro</label>
              <input v-model="form.logradouro" maxlength="64" placeholder="Rua, Avenida, etc." />
            </div>

            <div class="form-group um-terco">
              <label>Número</label>
              <input v-model="form.numero" maxlength="10" placeholder="Nº" />
            </div>

            <div class="form-group">
              <label>Complemento</label>
              <input v-model="form.complemento" maxlength="64" placeholder="Sala, Andar, Bloco..." />
            </div>

            <div class="form-group">
              <label>Bairro</label>
              <input v-model="form.bairro" maxlength="64" placeholder="Bairro" />
            </div>

            <div class="form-group">
              <label>Município</label>
              <input v-model="form.municipio" maxlength="64" placeholder="Cidade" />
            </div>

            <div class="form-group um-terco">
              <label>UF</label>
              <select v-model="form.uf" class="select-input">
                <option value="">Selecione</option>
                <option v-for="uf in ufs" :key="uf.sigla" :value="uf.sigla">
                  {{ uf.sigla }} - {{ uf.nome }}
                </option>
              </select>
            </div>
          </div>
        </div>

        <div class="form-actions">
          <div class="actions-left">
            <span class="required-nota">
              <span class="required">*</span> Campos obrigatórios
            </span>
          </div>
          <div class="actions-right">
            <AppButton 
              v-if="stepAtual === 2" 
              type="button" 
              variant="outline" 
              @click="stepAtual = 1"
            >
              ← Voltar
            </AppButton>
            <AppButton 
              v-if="stepAtual === 1 && !isEdicao" 
              type="button" 
              variant="primary" 
              @click="proximoPasso"
            >
              Próximo →
            </AppButton>
            <AppButton 
              type="submit" 
              variant="success" 
              :loading="salvando"
            >
              {{ salvando ? 'Salvando...' : (isEdicao ? 'Atualizar Empresa' : 'Cadastrar Empresa') }}
            </AppButton>
          </div>
        </div>
      </form>
    </AppCard>
  </div>
</template>

<script>
import ToastNotification from '@/components/ToastNotification.vue'
import AppCard from '@/components/ui/AppCard.vue'
import AppButton from '@/components/ui/AppButton.vue'
import LoadingSkeleton from '@/components/ui/LoadingSkeleton.vue'

const API = 'http://localhost:8081/empresa'
const API_CEP = 'https://viacep.com.br/ws'

export default {
  name: 'Empresa',
  components: { ToastNotification, AppCard, AppButton, LoadingSkeleton },

  data() {
    return {
      loading: false,
      salvando: false,
      buscandoCEP: false,
      stepAtual: 1,
      toast: { visible: false, message: '', type: 'success' },
      form: {
        razaoSocial: '', 
        cnpj: '', 
        logradouro: '', 
        municipio: '',
        numero: '', 
        complemento: '', 
        bairro: '', 
        cep: '',
        telefone: '', 
        email: '', 
        site: '', 
        uf: '',
        usuario: ''
      },
      erros: {},
      ufs: [
        { sigla: 'AC', nome: 'Acre' },
        { sigla: 'AL', nome: 'Alagoas' },
        { sigla: 'AP', nome: 'Amapá' },
        { sigla: 'AM', nome: 'Amazonas' },
        { sigla: 'BA', nome: 'Bahia' },
        { sigla: 'CE', nome: 'Ceará' },
        { sigla: 'DF', nome: 'Distrito Federal' },
        { sigla: 'ES', nome: 'Espírito Santo' },
        { sigla: 'GO', nome: 'Goiás' },
        { sigla: 'MA', nome: 'Maranhão' },
        { sigla: 'MT', nome: 'Mato Grosso' },
        { sigla: 'MS', nome: 'Mato Grosso do Sul' },
        { sigla: 'MG', nome: 'Minas Gerais' },
        { sigla: 'PA', nome: 'Pará' },
        { sigla: 'PB', nome: 'Paraíba' },
        { sigla: 'PR', nome: 'Paraná' },
        { sigla: 'PE', nome: 'Pernambuco' },
        { sigla: 'PI', nome: 'Piauí' },
        { sigla: 'RJ', nome: 'Rio de Janeiro' },
        { sigla: 'RN', nome: 'Rio Grande do Norte' },
        { sigla: 'RS', nome: 'Rio Grande do Sul' },
        { sigla: 'RO', nome: 'Rondônia' },
        { sigla: 'RR', nome: 'Roraima' },
        { sigla: 'SC', nome: 'Santa Catarina' },
        { sigla: 'SP', nome: 'São Paulo' },
        { sigla: 'SE', nome: 'Sergipe' },
        { sigla: 'TO', nome: 'Tocantins' }
      ]
    }
  },

  computed: {
    isEdicao() { return !!this.$route.params.id }
  },

  mounted() {
    if (this.isEdicao) this.carregarEmpresa()
  },

  methods: {
    async carregarEmpresa() {
      this.loading = true
      try {
        const res = await fetch(`${API}/${this.$route.params.id}`)
        if (!res.ok) throw new Error()
        const data = await res.json()
        this.form = { ...data }
        if (this.form.cnpj) this.form.cnpj = this.aplicarMascaraCNPJ(this.form.cnpj)
        if (this.form.telefone) this.form.telefone = this.aplicarMascaraTelefone(this.form.telefone)
        if (this.form.cep) this.form.cep = this.aplicarMascaraCEP(this.form.cep)
        this.showToast('Dados carregados com sucesso', 'success')
      } catch {
        this.showToast('Erro ao carregar dados da empresa.', 'error')
      } finally {
        this.loading = false
      }
    },

    async buscarCEP() {
      const cep = this.form.cep.replace(/\D/g, '')
      if (cep.length !== 8) {
        this.showToast('CEP inválido. Digite 8 dígitos.', 'error')
        return
      }

      this.buscandoCEP = true
      try {
        const res = await fetch(`${API_CEP}/${cep}/json/`)
        const data = await res.json()
        
        if (!data.erro) {
          this.form.logradouro = data.logradouro
          this.form.bairro = data.bairro
          this.form.municipio = data.localidade
          this.form.uf = data.uf
          this.showToast('CEP encontrado!', 'success')
        } else {
          this.showToast('CEP não encontrado', 'error')
        }
      } catch {
        this.showToast('Erro ao buscar CEP', 'error')
      } finally {
        this.buscandoCEP = false
      }
    },

    proximoPasso() {
      if (this.validarStep1()) {
        this.stepAtual = 2
      }
    },

    validarStep1() {
      const campos = ['razaoSocial', 'cnpj']
      let valido = true
      
      campos.forEach(c => {
        this.validarCampo(c)
        if (this.erros[c]) valido = false
      })
      
      return valido
    },

    async salvar() {
      if (!this.validarTudo()) return
      
      this.salvando = true
      try {
        const payload = { ...this.form }
        payload.cnpj = (payload.cnpj || '').replace(/\D/g, '')
        payload.telefone = (payload.telefone || '').replace(/\D/g, '')
        payload.cep = (payload.cep || '').replace(/\D/g, '')

        const url = this.isEdicao ? `${API}/${this.$route.params.id}` : API
        const method = this.isEdicao ? 'PUT' : 'POST'
        const res = await fetch(url, {
          method,
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        })
        
        if (!res.ok) throw new Error()
        
        this.showToast(this.isEdicao ? 'Empresa atualizada com sucesso!' : 'Empresa cadastrada com sucesso!', 'success')
        setTimeout(() => this.$router.push('/empresas'), 1500)
      } catch {
        this.showToast('Erro ao salvar empresa.', 'error')
      } finally {
        this.salvando = false
      }
    },

    validarTudo() {
      this.erros = {}
      const campos = ['razaoSocial', 'cnpj', 'telefone', 'email', 'site', 'cep']
      campos.forEach(c => this.validarCampo(c))
      return Object.keys(this.erros).length === 0
    },

    validarCampo(campo) {
      const v = (this.form[campo] || '').trim()
      let erro = ''

      if (campo === 'razaoSocial') {
        if (!v) erro = 'Razão Social é obrigatória.'
        else if (v.length > 64) erro = 'Máximo 64 caracteres.'
      }

      if (campo === 'cnpj') {
        if (!v) { erro = 'CNPJ é obrigatório.' }
        else {
          const n = v.replace(/\D/g, '')
          if (n.length !== 14) erro = 'CNPJ deve ter 14 dígitos.'
          else if (!this.validarCNPJ(n)) erro = 'CNPJ inválido.'
        }
      }

      if (campo === 'email' && v) {
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)) erro = 'E-mail inválido.'
        else if (v.length > 254) erro = 'Máximo 254 caracteres.'
      }

      if (campo === 'site' && v) {
        if (!/^https?:\/\/.+/.test(v)) erro = 'URL deve começar com http:// ou https://'
        else if (v.length > 254) erro = 'Máximo 254 caracteres.'
      }

      if (campo === 'telefone' && v) {
        const n = v.replace(/\D/g, '')
        if (n.length < 10 || n.length > 11) erro = 'Telefone deve ter 10 ou 11 dígitos.'
      }

      if (campo === 'cep' && v) {
        const n = v.replace(/\D/g, '')
        if (n.length !== 8) erro = 'CEP deve ter 8 dígitos.'
      }

      if (erro) {
        this.$set(this.erros, campo, erro)
      } else {
        this.$delete(this.erros, campo)
      }
    },

    validarCNPJ(cnpj) {
      if (/^(\d)\1+$/.test(cnpj)) return false
      
      let pesos1 = [5,4,3,2,9,8,7,6,5,4,3,2]
      let pesos2 = [6,5,4,3,2,9,8,7,6,5,4,3,2]
      
      let soma = pesos1.reduce((s, p, i) => s + p * parseInt(cnpj[i]), 0)
      let resto = soma % 11
      if (parseInt(cnpj[12]) !== (resto < 2 ? 0 : 11 - resto)) return false
      
      soma = pesos2.reduce((s, p, i) => s + p * parseInt(cnpj[i]), 0)
      resto = soma % 11
      return parseInt(cnpj[13]) === (resto < 2 ? 0 : 11 - resto)
    },

    mascararCNPJ(e) {
      this.form.cnpj = this.aplicarMascaraCNPJ(e.target.value)
    },
    
    aplicarMascaraCNPJ(v) {
      const n = v.replace(/\D/g, '').slice(0, 14)
      return n.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/, '$1.$2.$3/$4-$5')
              .replace(/^(\d{2})(\d{3})(\d{3})(\d{0,4})/, '$1.$2.$3/$4')
              .replace(/^(\d{2})(\d{3})(\d{0,3})/, '$1.$2.$3')
              .replace(/^(\d{2})(\d{0,3})/, '$1.$2')
    },

    mascararTelefone(e) {
      this.form.telefone = this.aplicarMascaraTelefone(e.target.value)
    },
    
    aplicarMascaraTelefone(v) {
      const n = v.replace(/\D/g, '').slice(0, 11)
      if (n.length === 11) return n.replace(/^(\d{2})(\d{5})(\d{4})$/, '($1) $2-$3')
      if (n.length >= 7) return n.replace(/^(\d{2})(\d{4,5})(\d{0,4})/, '($1) $2-$3')
      if (n.length >= 3) return n.replace(/^(\d{2})(\d{0,5})/, '($1) $2')
      if (n.length >= 1) return n.replace(/^(\d{0,2})/, '($1')
      return n
    },

    mascararCEP(e) {
      this.form.cep = this.aplicarMascaraCEP(e.target.value)
    },
    
    aplicarMascaraCEP(v) {
      const n = v.replace(/\D/g, '').slice(0, 8)
      return n.replace(/^(\d{5})(\d{0,3})/, '$1-$2')
    },

    showToast(msg, type = 'success') {
      this.toast = { visible: true, message: msg, type }
      setTimeout(() => { this.toast.visible = false }, 3200)
    }
  }
}
</script>

<style scoped>
.empresa-form-page {
  max-width: 900px;
  margin: 0 auto;
  animation: fadeIn 0.5s ease;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: var(--spacing-lg);
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

.header-actions {
  display: flex;
  gap: var(--spacing-md);
  align-items: center;
}

.step-indicator {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.step {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--gray-200);
  border-radius: 50%;
  font-weight: 700;
  color: var(--gray-600);
  transition: all 0.3s;
}

.step.active {
  background: var(--primary);
  color: white;
  transform: scale(1.1);
}

.step-line {
  width: 40px;
  height: 2px;
  background: var(--gray-200);
}

.form-step {
  animation: fadeIn 0.3s ease;
}

.form-header {
  margin-bottom: var(--spacing-xl);
  text-align: center;
}

.step-badge {
  display: inline-block;
  padding: 4px 12px;
  background: var(--primary-light);
  color: white;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  margin-bottom: var(--spacing-sm);
}

.form-header h3 {
  font-size: 1.5rem;
  margin-bottom: var(--spacing-xs);
  color: var(--gray-800);
}

.form-header p {
  color: var(--gray-600);
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--spacing-md);
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
}

.form-group.full {
  grid-column: 1 / -1;
}

.form-group.dois-tercos {
  grid-column: span 2;
}

.form-group.um-terco {
  grid-column: span 1;
}

label {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--gray-700);
}

.label-hint {
  font-size: 0.75rem;
  font-weight: normal;
  color: var(--gray-500);
  margin-left: var(--spacing-xs);
}

.required {
  color: var(--danger);
  margin-left: 2px;
}

input, select {
  padding: var(--spacing-md);
  border: 1.5px solid var(--gray-200);
  border-radius: var(--radius-md);
  font-size: 0.9375rem;
  transition: all 0.2s;
  background: white;
}

input:focus, select:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

input.input-error, select.input-error {
  border-color: var(--danger);
}

.cep-wrapper {
  display: flex;
  gap: var(--spacing-sm);
}

.cep-wrapper input {
  flex: 1;
}

.btn-cep {
  padding: var(--spacing-sm) var(--spacing-md);
  background: var(--primary-light);
  color: white;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
}

.btn-cep:hover:not(:disabled) {
  background: var(--primary);
  transform: scale(1.05);
}

.btn-cep:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.erro-msg {
  font-size: 0.75rem;
  color: var(--danger);
}

.input-footer {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
  color: var(--gray-500);
}

.char-count {
  font-family: monospace;
}

.input-hint {
  font-style: italic;
}

.select-input {
  cursor: pointer;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: var(--spacing-xl);
  padding-top: var(--spacing-lg);
  border-top: 1px solid var(--gray-200);
}

.actions-left {
  display: flex;
  gap: var(--spacing-md);
}

.required-nota {
  font-size: 0.75rem;
  color: var(--gray-600);
}

.actions-right {
  display: flex;
  gap: var(--spacing-sm);
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .header-actions {
    width: 100%;
    justify-content: space-between;
  }
  
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .form-group.dois-tercos,
  .form-group.um-terco {
    grid-column: span 1;
  }
  
  .cep-wrapper {
    flex-direction: column;
  }
  
  .form-actions {
    flex-direction: column;
    gap: var(--spacing-md);
  }
  
  .actions-right {
    width: 100%;
  }
  
  .actions-right button {
    flex: 1;
  }
}
</style>