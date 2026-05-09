<template>
  <transition name="slide-up">
    <div v-if="visible" class="toast" :class="type">
      <span class="toast-icon">{{ icon }}</span>
      <span class="toast-msg">{{ message }}</span>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'ToastNotification',
  props: {
    visible: { type: Boolean, default: false },
    message: { type: String,  default: '' },
    type:    { type: String,  default: 'success' }
  },
  computed: {
    icon() {
      return { success: '✓', error: '✕', info: 'ℹ' }[this.type] || '✓'
    }
  }
}
</script>

<style scoped>
.toast {
  position: fixed;
  bottom: 28px;
  right: 28px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 22px;
  border-radius: 8px;
  font-size: 0.92rem;
  font-weight: 600;
  color: #fff;
  box-shadow: 0 4px 16px rgba(0,0,0,0.18);
  z-index: 2000;
  min-width: 220px;
}
.toast.success { background: #27ae60; }
.toast.error   { background: #e74c3c; }
.toast.info    { background: #2980b9; }
.toast-icon    { font-size: 1.1rem; }
.slide-up-enter-active, .slide-up-leave-active { transition: all .3s ease; }
.slide-up-enter { opacity: 0; transform: translateY(20px); }
.slide-up-leave-to { opacity: 0; transform: translateY(20px); }
</style>