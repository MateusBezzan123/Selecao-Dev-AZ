<template>
  <button 
    :class="['app-button', variant, size, { loading, disabled }]"
    :disabled="disabled || loading"
    @click="$emit('click')"
  >
    <span v-if="loading" class="spinner"></span>
    <span class="btn-content">
      <slot />
    </span>
  </button>
</template>

<script>
export default {
  name: 'AppButton',
  props: {
    variant: {
      type: String,
      default: 'primary',
      validator: v => ['primary', 'secondary', 'danger', 'success', 'outline'].includes(v)
    },
    size: {
      type: String,
      default: 'md',
      validator: v => ['sm', 'md', 'lg'].includes(v)
    },
    loading: Boolean,
    disabled: Boolean
  }
}
</script>

<style scoped>
.app-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-sm);
  font-weight: 600;
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.2s;
  position: relative;
  overflow: hidden;
}

.app-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.app-button:active:not(:disabled) {
  transform: translateY(0);
}

.primary {
  background: var(--primary);
  color: white;
}

.primary:hover:not(:disabled) {
  background: var(--primary-dark);
}

.secondary {
  background: var(--secondary);
  color: white;
}

.danger {
  background: var(--danger);
  color: white;
}

.outline {
  background: transparent;
  border: 2px solid var(--gray-300);
  color: var(--gray-700);
}

.outline:hover:not(:disabled) {
  background: var(--gray-100);
}

.sm {
  padding: var(--spacing-xs) var(--spacing-md);
  font-size: 0.875rem;
}

.md {
  padding: var(--spacing-sm) var(--spacing-lg);
  font-size: 0.9375rem;
}

.lg {
  padding: var(--spacing-md) var(--spacing-xl);
  font-size: 1rem;
}

.loading {
  opacity: 0.7;
  cursor: wait;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>