<template>
  <div class="app-card" :class="variant">
    <div v-if="title" class="card-header">
      <h3>{{ title }}</h3>
      <slot name="header-actions" />
    </div>
    <div class="card-body">
      <slot />
    </div>
    <div v-if="$slots.footer" class="card-footer">
      <slot name="footer" />
    </div>
  </div>
</template>

<script>
export default {
  name: 'AppCard',
  props: {
    title: String,
    variant: {
      type: String,
      default: 'default',
      validator: v => ['default', 'elevated', 'bordered'].includes(v)
    }
  }
}
</script>

<style scoped>
.app-card {
  background: var(--gray-50);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.default {
  background: white;
  box-shadow: var(--shadow-sm);
}

.elevated {
  background: white;
  box-shadow: var(--shadow-lg);
}

.bordered {
  background: white;
  border: 1px solid var(--gray-200);
}

.card-header {
  padding: var(--spacing-lg);
  border-bottom: 1px solid var(--gray-200);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h3 {
  margin: 0;
  font-size: 1.125rem;
  font-weight: 600;
}

.card-body {
  padding: var(--spacing-lg);
}

.card-footer {
  padding: var(--spacing-md) var(--spacing-lg);
  background: var(--gray-50);
  border-top: 1px solid var(--gray-200);
}
</style>