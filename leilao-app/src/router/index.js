import Vue from 'vue'
import VueRouter from 'vue-router'
import Login from '../views/Login.vue'
import authService from '@/services/auth'

Vue.use(VueRouter)

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { public: true }
  },
  {
    path: '/',
    name: 'Home',
    component: () => import('../views/Home.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/unidades',
    name: 'Unidades',
    component: () => import('../views/unidade/Unidades.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/empresas',
    name: 'Empresas',
    component: () => import('../views/empresa/Empresas.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/leiloes',
    name: 'Leiloes',
    component: () => import('../views/leilao/Leiloes.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/empresa',
    name: 'Empresa',
    component: () => import('../views/empresa/NovaEmpresa.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/empresa/:id',
    name: 'EmpresaEdit',
    component: () => import('../views/empresa/NovaEmpresa.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('../views/Profile.vue'),
    meta: { requiresAuth: true }
  }
]

const router = new VueRouter({
  mode: 'hash',
  routes
})


router.beforeEach((to, from, next) => {
  if (to.meta.requiresAuth && !authService.isAuthenticated()) {
    next('/login')
  } else if (to.path === '/login' && authService.isAuthenticated()) {
    next('/')
  } else {
    next()
  }
})

export default router