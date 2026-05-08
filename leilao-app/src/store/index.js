import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'

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
    component: () => import('../views/unidade/Unidades.vue')
  },
  {
    path: '/empresas',
    name: 'Empresas',
    component: () => import('../views/empresa/Empresas.vue')
  },
  {
    path: '/leiloes',
    name: 'Leiloes',
    component: () => import('../views/leilao/Leiloes.vue')
  }
]

const router = new VueRouter({
  mode: 'hash',
  routes
})

export default router