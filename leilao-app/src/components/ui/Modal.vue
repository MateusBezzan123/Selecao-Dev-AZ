<template>
  <transition name="modal">
    <div v-if="visible" class="modal-overlay" @click.self="close">
      <div class="modal-container" :class="size">
        <div class="modal-header">
          <h3>{{ title }}</h3>
          <button class="modal-close" @click="close">✕</button>
        </div>
        <div class="modal-body">
          <slot />
        </div>
        <div v-if="$slots.footer" class="modal-footer">
          <slot name="footer" />
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'Modal',
  props: {
    visible: Boolean,
    title: String,
    size: {
      type: String,
      default: 'md',
      validator: v => ['sm', 'md', 'lg', 'xl'].includes(v)
    }
  },
  methods: {
    close() {
      this.$emit('update:visible', false)
      this.$emit('close')
    }
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.2s ease;
}

.modal-container {
  background: white;
  border-radius: var(--radius-lg);
  max-width: 90%;
  max-height: 90vh;
  overflow: auto;
  animation: slideUp 0.3s ease;
}

.modal-container.sm { width: 400px; }
.modal-container.md { width: 600px; }
.modal-container.lg { width: 800px; }
.modal-container.xl { width: 1100px; }

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-lg);
  border-bottom: 1px solid var(--gray-200);
}

.modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  color: var(--gray-800);
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.25rem;
  cursor: pointer;
  padding: var(--spacing-xs);
  transition: all 0.2s;
}

.modal-close:hover {
  transform: scale(1.1);
  color: var(--danger);
}

.modal-body {
  padding: var(--spacing-lg);
  max-height: calc(90vh - 130px);
  overflow-y: auto;
}

.modal-footer {
  padding: var(--spacing-lg);
  border-top: 1px solid var(--gray-200);
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-sm);
}

@keyframes slideUp {
  from {
    transform: translateY(50px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}
</style>