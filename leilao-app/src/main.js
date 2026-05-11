import Vue from 'vue'
import App from './App.vue'
import router from './router'
import './assets/main.css'

Vue.config.productionTip = false


Vue.directive('fade', {
  inserted(el) {
    el.style.animation = 'fadeIn 0.5s ease'
  }
})

new Vue({
  router,
  render: h => h(App)
}).$mount('#app')