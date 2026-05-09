<template>
  <transition name="fade">
    <div v-if="visible" class="dialog-overlay" @click.self="$emit('cancel')">
      <div class="dialog-box">
        <div class="dialog-icon">⚠️</div>
        <h3 class="dialog-title">{{ title }}</h3>
        <p class="dialog-msg">{{ message }}</p>
        <div class="dialog-actions">
          <button class="btn-cancel" @click="$emit('cancel')">Cancelar</button>
          <button class="btn-confirm" @click="$emit('confirm')">Confirmar</button>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'ConfirmDialog',
  props: {
    visible: { type: Boolean, default: false },
    title:   { type: String,  default: 'Confirmar ação' },
    message: { type: String,  default: 'Deseja realmente continuar?' }
  }
}
</script>

<style scoped>
.dialog-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.dialog-box {
  background: #fff;
  border-radius: 10px;
  padding: 36px 40px;
  max-width: 380px;
  width: 90%;
  text-align: center;
  box-shadow: 0 8px 32px rgba(0,0,0,0.18);
}
.dialog-icon { font-size: 2.2rem; margin-bottom: 12px; }
.dialog-title { font-size: 1.1rem; font-weight: 700; color: #2c3e50; margin-bottom: 8px; }
.dialog-msg   { font-size: 0.92rem; color: #7f8c8d; margin-bottom: 28px; line-height: 1.5; }
.dialog-actions { display: flex; gap: 12px; justify-content: center; }
.btn-cancel  { padding: 9px 24px; border: 2px solid #ddd; background: #fff; border-radius: 6px; cursor: pointer; font-size: 0.9rem; color: #555; transition: border-color .2s; }
.btn-cancel:hover { border-color: #aaa; }
.btn-confirm { padding: 9px 24px; border: none; background: #e74c3c; color: #fff; border-radius: 6px; cursor: pointer; font-size: 0.9rem; font-weight: 600; transition: background .2s; }
.btn-confirm:hover { background: #c0392b; }
.fade-enter-active, .fade-leave-active { transition: opacity .2s; }
.fade-enter, .fade-leave-to { opacity: 0; }
</style>