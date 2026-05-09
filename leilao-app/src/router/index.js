import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'
import Unidades from '../views/unidade/Unidades.vue'
import Empresas from '../views/empresa/Empresas.vue'

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
]

const router = new VueRouter({
  routes
})

export default router
