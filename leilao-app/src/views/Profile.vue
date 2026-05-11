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

        <div v-if="loading" class="loading-wrap">
            <div class="spinner"></div>
            <span>Carregando dados do perfil...</span>
        </div>

        <div v-else class="profile-container">
            <div class="profile-sidebar animate-fade">
                <div class="profile-avatar">
                    <div class="avatar-large">
                        {{ userInitials }}
                    </div>
                    <h3>{{ form.razaoSocial || form.usuario }}</h3>
                    <p class="user-role">{{ userRole }}</p>
                    <p class="user-since">Membro desde {{ formatarDataBR(form.createdAt) }}</p>
                </div>

                <div class="profile-stats">
                    <div class="stat-item">
                        <span class="stat-label">ID do Usuário</span>
                        <span class="stat-value">#{{ form.id }}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">Último acesso</span>
                        <span class="stat-value">{{ formatarDataBR(lastLogin) }}</span>
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
                    <button @click="activeTab = 'security'"
                        :class="['menu-item', { active: activeTab === 'security' }]">
                        🔒 Segurança
                    </button>
                    <button @click="activeTab = 'address'" :class="['menu-item', { active: activeTab === 'address' }]">
                        📍 Endereço
                    </button>
                    <button @click="activeTab = 'leiloes'" :class="['menu-item', { active: activeTab === 'leiloes' }]">
                        🔖 Meus Leilões
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
                                <input v-model="form.telefone" type="text" placeholder="(00) 00000-0000"
                                    @input="mascararTelefone" />
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
                                    <input :type="showCurrentPassword ? 'text' : 'password'"
                                        v-model="passwordForm.currentPassword" required />
                                    <button type="button" class="toggle-password"
                                        @click="showCurrentPassword = !showCurrentPassword">
                                        {{ showCurrentPassword ? '🙈' : '👁️' }}
                                    </button>
                                </div>
                            </div>

                            <div class="form-group full">
                                <label>Nova Senha *</label>
                                <div class="password-wrapper">
                                    <input :type="showNewPassword ? 'text' : 'password'"
                                        v-model="passwordForm.newPassword" required />
                                    <button type="button" class="toggle-password"
                                        @click="showNewPassword = !showNewPassword">
                                        {{ showNewPassword ? '🙈' : '👁️' }}
                                    </button>
                                </div>
                                <span class="password-hint">Mínimo 6 caracteres</span>
                            </div>

                            <div class="form-group full">
                                <label>Confirmar Nova Senha *</label>
                                <div class="password-wrapper">
                                    <input :type="showConfirmPassword ? 'text' : 'password'"
                                        v-model="passwordForm.confirmPassword" required />
                                    <button type="button" class="toggle-password"
                                        @click="showConfirmPassword = !showConfirmPassword">
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

                <!-- Aba Meus Leilões -->
                <div v-if="activeTab === 'leiloes'" class="profile-card">
                    <h2>🔖 Meus Leilões</h2>
                    <div v-if="loadingLeiloes" class="loading-small">
                        <div class="spinner-small"></div>
                        <span>Carregando leilões...</span>
                    </div>
                    <div v-else-if="meusLeiloes.length === 0" class="empty-leiloes">
                        <span class="empty-icon">🔖</span>
                        <p>Você ainda não possui leilões cadastrados</p>
                        <button @click="criarLeilao" class="btn-create-leilao">+ Criar meu primeiro leilão</button>
                    </div>
                    <div v-else class="leiloes-list">
                        <div v-for="leilao in meusLeiloes" :key="leilao.id" class="leilao-item"
                            @click="verDetalhesLeilao(leilao.id)">
                            <div class="leilao-header">
                                <span class="leilao-code">#{{ leilao.codigo }}</span>
                                <span :class="['leilao-status', getStatusClass(leilao)]">{{ getStatus(leilao) }}</span>
                            </div>
                            <h4 class="leilao-title">{{ leilao.descricao }}</h4>
                            <div class="leilao-details">
                                <div class="detail">
                                    <span class="detail-label">📅 Início:</span>
                                    <span class="detail-value">{{ formatarDataCompleta(leilao.inicioPrevisto) }}</span>
                                </div>
                                <div class="detail">
                                    <span class="detail-label">💰 Total:</span>
                                    <span class="detail-value highlight">{{ formatarMoeda(leilao._total) }}</span>
                                </div>
                                <div class="detail">
                                    <span class="detail-label">📦 Lotes:</span>
                                    <span class="detail-value">{{ leilao.lotesCount || 0 }}</span>
                                </div>
                            </div>
                            <div class="leilao-actions">
                                <button @click.stop="editarLeilao(leilao.id)" class="btn-edit-leilao">✏️ Editar</button>
                                <button @click.stop="verLances(leilao.id)" class="btn-view-bids">👁️ Ver lances</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import ToastNotification from '@/components/ToastNotification.vue'
import authService from '@/services/auth'

const API = 'http://localhost:8081/empresa'
const API_LEILAO = 'http://localhost:8081/leilao'
const API_LOTE = 'http://localhost:8081/lote'
const API_CEP = 'https://viacep.com.br/ws'

export default {
    name: 'Profile',
    components: { ToastNotification },
    data() {
        return {
            loading: true,
            loadingLeiloes: false,
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
                uf: '',
                createdAt: '',
                role: ''
            },
            passwordForm: {
                currentPassword: '',
                newPassword: '',
                confirmPassword: ''
            },
            meusLeiloes: [],
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
            return this.form.role === 'ADMIN' ? 'Administrador' : (this.form.role === 'VENDEDOR' ? 'Vendedor' : 'Usuário')
        }
    },
    mounted() {
        this.loadUserData()
    },
    methods: {
        formatarDataBR(valor) {
            if (!valor) return 'Não informado'
            const d = new Date(valor)
            if (isNaN(d.getTime())) return 'Data inválida'
            return d.toLocaleDateString('pt-BR')
        },

        formatarDataCompleta(valor) {
            if (!valor) return '—'
            const d = new Date(valor)
            if (isNaN(d.getTime())) return valor
            return d.toLocaleDateString('pt-BR', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            })
        },
        
        async loadUserData() {
            this.loading = true
            try {
                const token = authService.getToken()
                const userData = authService.getUser()
                console.log('User data from auth:', userData)

                let empresaId = null

                if (userData?.id) {
                    empresaId = userData.id
                    const response = await fetch(`${API}/${empresaId}`, {
                        headers: {
                            'Authorization': `Bearer ${token}`,
                            'Content-Type': 'application/json'
                        }
                    })
                    if (!response.ok) throw new Error('Erro ao buscar usuário')
                    const data = await response.json()
                    console.log('User data from API:', data)
                    this.form = { ...data }
                } else if (userData?.username) {
                    const response = await fetch(`${API}?usuario=${userData.username}`, {
                        headers: {
                            'Authorization': `Bearer ${token}`,
                            'Content-Type': 'application/json'
                        }
                    })
                    const data = await response.json()
                    if (data && data.length > 0) {
                        this.form = data[0]
                        empresaId = this.form.id
                    }
                }

                if (empresaId) {
                    await this.carregarMeusLeiloes(empresaId)
                } else {
                    console.warn('Não foi possível encontrar o ID da empresa')
                }
            } catch (error) {
                console.error('Erro ao carregar dados:', error)
                this.showToast('Erro ao carregar dados do usuário', 'error')
            } finally {
                this.loading = false
            }
        },

        async carregarMeusLeiloes(empresaId) {
            this.loadingLeiloes = true
            try {
                console.log('Buscando leilões para empresa ID:', empresaId)

                const response = await fetch(API_LEILAO)
                if (!response.ok) throw new Error('Erro ao buscar leilões')
                let leiloes = await response.json()

                console.log('Todos os leilões:', leiloes)
                console.log('Vendedor ID a filtrar:', empresaId)

                // Filtrar leilões onde o vendedor é a empresa logada
                leiloes = leiloes.filter(l => l.vendedor === empresaId)

                console.log('Leilões filtrados:', leiloes)

                // Buscar lotes para calcular total
                const lotesResponse = await fetch(API_LOTE)
                const lotes = await lotesResponse.json()

                // Calcular total por leilão
                const totalPorLeilao = {}
                lotes.forEach(l => {
                    const sub = Number(l.quantidade) * Number(l.valorInicial)
                    totalPorLeilao[l.leilao] = (totalPorLeilao[l.leilao] || 0) + sub
                })

                this.meusLeiloes = leiloes.map(l => ({
                    ...l,
                    _total: totalPorLeilao[l.id] || 0,
                    lotesCount: lotes.filter(lote => lote.leilao === l.id).length
                }))

                console.log('Meus leilões carregados:', this.meusLeiloes)

                if (this.meusLeiloes.length === 0) {
                    console.log('Nenhum leilão encontrado para esta empresa')
                }
            } catch (error) {
                console.error('Erro ao carregar leilões:', error)
                this.showToast('Erro ao carregar seus leilões', 'error')
            } finally {
                this.loadingLeiloes = false
            }
        },

        async updateProfile() {
            this.saving = true
            try {
                const response = await fetch(`${API}/${this.form.id}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(this.form)
                })

                if (!response.ok) throw new Error('Erro ao atualizar')

                this.showToast('Perfil atualizado com sucesso!', 'success')
                await this.loadUserData()
            } catch (error) {
                console.error('Erro:', error)
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

                const response = await fetch(`${API}/${this.form.id}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                })

                if (!response.ok) throw new Error('Erro ao atualizar senha')

                this.showToast('Senha atualizada com sucesso!', 'success')
                this.passwordForm = { currentPassword: '', newPassword: '', confirmPassword: '' }
            } catch (error) {
                console.error('Erro:', error)
                this.showToast('Erro ao atualizar senha', 'error')
            } finally {
                this.updatingPassword = false
            }
        },

        async updateAddress() {
            this.savingAddress = true
            try {
                const response = await fetch(`${API}/${this.form.id}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(this.form)
                })

                if (!response.ok) throw new Error('Erro ao atualizar endereço')

                this.showToast('Endereço atualizado com sucesso!', 'success')
            } catch (error) {
                console.error('Erro:', error)
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
                console.error('Erro:', error)
                this.showToast('Erro ao buscar CEP', 'error')
            }
        },

        mascararTelefone() {
            let value = this.form.telefone.replace(/\D/g, '')
            if (value.length === 11) {
                this.form.telefone = value.replace(/^(\d{2})(\d{5})(\d{4})$/, '($1) $2-$3')
            } else if (value.length === 10) {
                this.form.telefone = value.replace(/^(\d{2})(\d{4})(\d{4})$/, '($1) $2-$3')
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

        criarLeilao() {
            this.$router.push('/leiloes')
        },

        verDetalhesLeilao(id) {
            this.$router.push('/leiloes')
        },

        editarLeilao(id) {
            this.$router.push(`/leilao/${id}`)
        },

        verLances(id) {
            this.showToast('Funcionalidade em desenvolvimento', 'info')
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
            if (dataInicio > agora) return 'Agendado'
            if (dataInicio <= agora) return 'Em Andamento'
            return 'Finalizado'
        },

        getStatusClass(leilao) {
            const status = this.getStatus(leilao)
            if (status === 'Agendado') return 'status-scheduled'
            if (status === 'Em Andamento') return 'status-progress'
            return 'status-finished'
        },

        showToast(message, type) {
            this.toast = { visible: true, message, type }
            setTimeout(() => { this.toast.visible = false }, 3200)
        }
    }
}
</script>

<style scoped>
.loading-wrap {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 3rem;
}

.spinner {
    width: 40px;
    height: 40px;
    border: 3px solid #e5e7eb;
    border-top-color: #6366f1;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin-right: 1rem;
}

.loading-small {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 1rem;
    padding: 2rem;
}

.spinner-small {
    width: 24px;
    height: 24px;
    border: 2px solid #e5e7eb;
    border-top-color: #6366f1;
    border-radius: 50%;
    animation: spin 0.6s linear infinite;
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}

.empty-leiloes {
    text-align: center;
    padding: 3rem;
    background: #f9fafb;
    border-radius: 0.75rem;
}

.empty-icon {
    font-size: 3rem;
    display: block;
    margin-bottom: 1rem;
}

.btn-create-leilao {
    margin-top: 1rem;
    padding: 0.75rem 1.5rem;
    background: linear-gradient(135deg, #6366f1, #4f46e5);
    color: white;
    border: none;
    border-radius: 0.5rem;
    cursor: pointer;
}

.leiloes-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}

.leilao-item {
    background: #f9fafb;
    border-radius: 0.75rem;
    padding: 1.5rem;
    cursor: pointer;
    transition: all 0.2s;
}

[data-theme="dark"] .leilao-item {
    background: #374151;
}

.leilao-item:hover {
    transform: translateX(4px);
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.leilao-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.75rem;
}

.leilao-code {
    font-family: monospace;
    font-size: 0.875rem;
    font-weight: 600;
    color: #6366f1;
}

.leilao-status {
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

.leilao-title {
    font-size: 1rem;
    font-weight: 600;
    margin-bottom: 0.75rem;
    color: #1f2937;
}

[data-theme="dark"] .leilao-title {
    color: white;
}

.leilao-details {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem;
    margin-bottom: 1rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #e5e7eb;
}

[data-theme="dark"] .leilao-details {
    border-bottom-color: #4b5563;
}

.detail {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
}

.detail-label {
    font-size: 0.7rem;
    color: #6b7280;
}

.detail-value {
    font-size: 0.875rem;
    font-weight: 500;
    color: #1f2937;
}

[data-theme="dark"] .detail-value {
    color: #e5e7eb;
}

.highlight {
    color: #10b981;
    font-weight: 700;
}

.leilao-actions {
    display: flex;
    gap: 0.5rem;
}

.btn-edit-leilao,
.btn-view-bids {
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 0.5rem;
    cursor: pointer;
    font-size: 0.75rem;
    transition: all 0.2s;
}

.btn-edit-leilao {
    background: #6366f1;
    color: white;
}

.btn-edit-leilao:hover {
    background: #4f46e5;
}

.btn-view-bids {
    background: #f3f4f6;
    color: #374151;
}

[data-theme="dark"] .btn-view-bids {
    background: #4b5563;
    color: white;
}

.btn-view-bids:hover {
    background: #e5e7eb;
}

/* Restante dos estilos já existentes... */
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

.form-group input,
.form-group select {
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

    .btn-cancel,
    .btn-save {
        width: 100%;
    }

    .leilao-details {
        grid-template-columns: 1fr;
    }
}
</style>