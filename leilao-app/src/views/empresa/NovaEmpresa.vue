<template>
  <div class="empresa-form-page">
    <ToastNotification :visible="toast.visible" :message="toast.message" :type="toast.type" />

    <div class="page-header">
      <div class="page-title">
        <span class="page-icon">{{ isEdicao ? '✏️' : '🏢' }}</span>
        <div>
          <h1>{{ isEdicao ? 'Editar Empresa' : 'Nova Empresa' }}</h1>
          <p>{{ isEdicao ? 'Atualize os dados da empresa' : 'Preencha os dados para cadastrar uma nova empresa' }}</p>
        </div>
      </div>
      <router-link to="/empresas" class="btn-voltar">← Voltar</router-link>
    </div>

    <div v-if="loading" class="loading-wrap">
      <div class="spinner"></div>
      <span>Carregando...</span>
    </div>

    <div v-else class="form-card">
      <div class="form-section">
        <h3 class="section-title">📋 Dados Principais</h3>
        <div class="form-grid">

          <div class="form-group full">
            <label>Razão Social <span class="required">*</span></label>
            <input v-model="form.razaoSocial" :class="{ 'input-error': erros.razaoSocial }"
              maxlength="64" placeholder="Nome ou Razão Social da empresa" @blur="validarCampo('razaoSocial')" />
            <span class="erro-msg" v-if="erros.razaoSocial">{{ erros.razaoSocial }}</span>
            <span class="char-count">{{ (form.razaoSocial || '').length }}/64</span>
          </div>

          <div class="form-group">
            <label>CNPJ <span class="required">*</span></label>
            <input v-model="form.cnpj" :class="{ 'input-error': erros.cnpj }"
              maxlength="18" placeholder="00.000.000/0000-00"
              @input="mascararCNPJ" @blur="validarCampo('cnpj')" />
            <span class="erro-msg" v-if="erros.cnpj">{{ erros.cnpj }}</span>
          </div>

          <div class="form-group">
            <label>Telefone</label>
            <input v-model="form.telefone" :class="{ 'input-error': erros.telefone }"
              maxlength="15" placeholder="(00) 00000-0000"
              @input="mascararTelefone" @blur="validarCampo('telefone')" />
            <span class="erro-msg" v-if="erros.telefone">{{ erros.telefone }}</span>
          </div>

          <div class="form-group">
            <label>E-mail</label>
            <input v-model="form.email" :class="{ 'input-error': erros.email }"
              maxlength="254" type="email" placeholder="contato@empresa.com.br"
              @blur="validarCampo('email')" />
            <span class="erro-msg" v-if="erros.email">{{ erros.email }}</span>
          </div>

          <div class="form-group">
            <label>Site</label>
            <input v-model="form.site" :class="{ 'input-error': erros.site }"
              maxlength="254" placeholder="https://www.empresa.com.br"
              @blur="validarCampo('site')" />
            <span class="erro-msg" v-if="erros.site">{{ erros.site }}</span>
          </div>

        </div>
      </div>

      <div class="form-section">
        <h3 class="section-title">📍 Endereço</h3>
        <div class="form-grid">

          <div class="form-group">
            <label>CEP</label>
            <input v-model="form.cep" :class="{ 'input-error': erros.cep }"
              maxlength="9" placeholder="00000-000"
              @input="mascararCEP" @blur="validarCampo('cep')" />
            <span class="erro-msg" v-if="erros.cep">{{ erros.cep }}</span>
          </div>

          <div class="form-group dois-tercos">
            <label>Logradouro</label>
            <input v-model="form.logradouro" maxlength="64" placeholder="Rua, Avenida, etc." />
          </div>

          <div class="form-group um-quarto">
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

        </div>
      </div>

      <p class="obrigatorio-nota"><span class="required">*</span> Campos obrigatórios</p>

      <div class="form-actions">
        <router-link to="/empresas" class="btn-cancelar">Cancelar</router-link>
        <button class="btn-salvar" :disabled="salvando" @click="salvar">
          <span v-if="salvando" class="spinner-sm"></span>
          {{ salvando ? 'Salvando...' : (isEdicao ? 'Atualizar' : 'Cadastrar') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import ToastNotification from '@/components/ToastNotification.vue'

const API = 'http://localhost:8081/empresa'

export default {
  name: 'Empresa',
  components: { ToastNotification },

  data() {
    return {
      loading:  false,
      salvando: false,
      toast: { visible: false, message: '', type: 'success' },
      form: {
        razaoSocial: '', cnpj: '', logradouro: '', municipio: '',
        numero: '', complemento: '', bairro: '', cep: '',
        telefone: '', email: '', site: '', usuario: ''
      },
      erros: {}
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
        const res  = await fetch(`${API}/${this.$route.params.id}`)
        if (!res.ok) throw new Error()
        const data = await res.json()
        this.form  = { ...data }
        if (this.form.cnpj)     this.form.cnpj     = this.aplicarMascaraCNPJ(this.form.cnpj)
        if (this.form.telefone) this.form.telefone = this.aplicarMascaraTelefone(this.form.telefone)
        if (this.form.cep)      this.form.cep      = this.aplicarMascaraCEP(this.form.cep)
      } catch {
        this.showToast('Erro ao carregar dados da empresa.', 'error')
      } finally {
        this.loading = false
      }
    },

    async salvar() {
      if (!this.validarTudo()) return
      this.salvando = true
      try {
        const payload = { ...this.form }
        payload.cnpj     = (payload.cnpj     || '').replace(/\D/g, '')
        payload.telefone = (payload.telefone || '').replace(/\D/g, '')
        payload.cep      = (payload.cep      || '').replace(/\D/g, '')

        const url    = this.isEdicao ? `${API}/${this.$route.params.id}` : API
        const method = this.isEdicao ? 'PUT' : 'POST'
        const res    = await fetch(url, {
          method,
          headers: { 'Content-Type': 'application/json' },
          body:    JSON.stringify(payload)
        })
        if (!res.ok) throw new Error()
        this.showToast(this.isEdicao ? 'Empresa atualizada!' : 'Empresa cadastrada!', 'success')
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
          if (n.length !== 14)       erro = 'CNPJ deve ter 14 dígitos.'
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
      let soma = 0, resto
      for (let i = 1; i <= 12; i++) soma += parseInt(cnpj[i - 1]) * (i < 5 ? 5 - i + 4 : 13 - i + 4)
      // Algoritmo padrão de validação Receita Federal
      let pesos1 = [5,4,3,2,9,8,7,6,5,4,3,2]
      let pesos2 = [6,5,4,3,2,9,8,7,6,5,4,3,2]
      soma = pesos1.reduce((s, p, i) => s + p * parseInt(cnpj[i]), 0)
      resto = soma % 11
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
      if (n.length >= 7)   return n.replace(/^(\d{2})(\d{4,5})(\d{0,4})/, '($1) $2-$3')
      if (n.length >= 3)   return n.replace(/^(\d{2})(\d{0,5})/, '($1) $2')
      if (n.length >= 1)   return n.replace(/^(\d{0,2})/, '($1')
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
.empresa-form-page { max-width: 900px; margin: 0 auto; }

.page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
.page-title  { display: flex; align-items: center; gap: 14px; }
.page-icon   { font-size: 2.2rem; }
.page-title h1 { font-size: 1.6rem; font-weight: 700; color: #2c3e50; margin: 0; }
.page-title p  { font-size: 0.85rem; color: #95a5a6; margin: 2px 0 0; }
.btn-voltar { display: inline-block; padding: 9px 20px; background: #ecf0f1; color: #555; border-radius: 7px; text-decoration: none; font-size: 0.88rem; font-weight: 600; transition: background .2s; }
.btn-voltar:hover { background: #dde1e3; }

.loading-wrap { display: flex; align-items: center; justify-content: center; gap: 14px; padding: 60px; color: #7f8c8d; }
.spinner { width: 28px; height: 28px; border: 3px solid #ddd; border-top-color: #42b983; border-radius: 50%; animation: spin .7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

.form-card { background: #fff; border-radius: 12px; box-shadow: 0 2px 16px rgba(0,0,0,0.08); overflow: hidden; }


.form-section { padding: 28px 32px; border-bottom: 1px solid #f0f0f0; }
.form-section:last-of-type { border-bottom: none; }
.section-title { font-size: 0.95rem; font-weight: 700; color: #2c3e50; margin: 0 0 20px; padding-bottom: 10px; border-bottom: 2px solid #f0f0f0; }


.form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 18px; }
.form-group { display: flex; flex-direction: column; gap: 5px; position: relative; }
.form-group.full      { grid-column: 1 / -1; }
.form-group.dois-tercos { grid-column: span 1; }
.form-group.um-quarto   { grid-column: span 1; }


label { font-size: 0.82rem; font-weight: 600; color: #555; }
.required { color: #e74c3c; margin-left: 2px; }


input {
  padding: 10px 12px; border: 1.5px solid #e0e0e0; border-radius: 7px;
  font-size: 0.92rem; outline: none; color: #2c3e50; transition: border-color .2s;
  background: #fff;
}
input:focus { border-color: #42b983; box-shadow: 0 0 0 3px rgba(66,185,131,.1); }
input.input-error { border-color: #e74c3c; }
input.input-error:focus { box-shadow: 0 0 0 3px rgba(231,76,60,.1); }

.char-count { font-size: 0.74rem; color: #bdc3c7; text-align: right; }
.erro-msg   { font-size: 0.78rem; color: #e74c3c; }
.hint-inline{ font-size: 0.78rem; color: #95a5a6; }

.obrigatorio-nota { font-size: 0.8rem; color: #95a5a6; padding: 0 32px 4px; }


.form-actions { display: flex; align-items: center; justify-content: flex-end; gap: 12px; padding: 20px 32px; background: #f8f9fa; border-top: 1px solid #f0f0f0; }
.btn-cancelar { padding: 10px 24px; background: #ecf0f1; color: #555; text-decoration: none; border-radius: 7px; font-size: 0.92rem; font-weight: 600; transition: background .2s; }
.btn-cancelar:hover { background: #dde1e3; }
.btn-salvar { display: flex; align-items: center; gap: 8px; padding: 10px 28px; background: #42b983; color: #fff; border: none; border-radius: 7px; font-size: 0.92rem; font-weight: 700; cursor: pointer; transition: background .2s; }
.btn-salvar:hover:not(:disabled) { background: #369870; }
.btn-salvar:disabled { opacity: .65; cursor: not-allowed; }
.spinner-sm { width: 16px; height: 16px; border: 2px solid rgba(255,255,255,.4); border-top-color: #fff; border-radius: 50%; animation: spin .6s linear infinite; }

@media (max-width: 640px) {
  .form-grid { grid-template-columns: 1fr; }
  .form-section { padding: 20px 16px; }
  .form-actions { padding: 16px; }
}
</style>