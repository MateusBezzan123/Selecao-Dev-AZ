import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'
import Unidades from '../views/unidade/Unidades.vue'
import Empresas from '../views/empresa/Empresas.vue'
import Leilões from '../views/leilao/Leiloes.vue'
import Empresa from '../views/empresa/NovaEmpresa.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/unidades',
    name: 'Unidades',
    component: Unidades
  },
  {
    path: '/empresas',
    name: 'Empresas',
    component: Empresas
  },
  {
    path: '/leiloes',
    name: 'Leilões',
    component: Leilões
  },
  {
    path: '/empresa',
    name: 'Empresa',
    component: Empresa
  },
  {
    path: '/empresa/:id',
    name: 'Empresa',
    component: Empresa
  },
]

const router = new VueRouter({
  routes
})

export default router
