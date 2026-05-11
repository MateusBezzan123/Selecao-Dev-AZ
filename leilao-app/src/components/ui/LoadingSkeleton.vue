<template>
  <div class="skeleton-wrapper">
    <div v-if="type === 'table'" class="skeleton-table">
      <div v-for="i in rows" :key="i" class="skeleton-row">
        <div v-for="j in columns" :key="j" class="skeleton-cell"></div>
      </div>
    </div>
    <div v-else class="skeleton-card">
      <div class="skeleton-header"></div>
      <div class="skeleton-body">
        <div v-for="i in 5" :key="i" class="skeleton-line"></div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LoadingSkeleton',
  props: {
    type: {
      type: String,
      default: 'table',
      validator: v => ['table', 'card'].includes(v)
    },
    rows: {
      type: Number,
      default: 5
    },
    columns: {
      type: Number,
      default: 4
    }
  }
}
</script>

<style scoped>
.skeleton-wrapper {
  background: var(--gray-50);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.skeleton-table {
  padding: var(--spacing-md);
}

.skeleton-row {
  display: flex;
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-md);
}

.skeleton-cell {
  flex: 1;
  height: 48px;
  background: linear-gradient(90deg, var(--gray-200) 25%, var(--gray-100) 50%, var(--gray-200) 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
  border-radius: var(--radius-sm);
}

.skeleton-card {
  padding: var(--spacing-lg);
}

.skeleton-header {
  width: 60%;
  height: 32px;
  background: linear-gradient(90deg, var(--gray-200) 25%, var(--gray-100) 50%, var(--gray-200) 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
  border-radius: var(--radius-sm);
  margin-bottom: var(--spacing-lg);
}

.skeleton-body {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
}

.skeleton-line {
  height: 20px;
  background: linear-gradient(90deg, var(--gray-200) 25%, var(--gray-100) 50%, var(--gray-200) 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
  border-radius: var(--radius-sm);
}

@keyframes loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}
</style>