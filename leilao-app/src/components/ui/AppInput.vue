<template>
  <div class="app-input" :class="{ error: error, focused }">
    <label v-if="label" class="input-label">{{ label }}</label>
    <div class="input-wrapper">
      <span v-if="icon" class="input-icon">{{ icon }}</span>
      <input
        :type="type"
        :value="value"
        :placeholder="placeholder"
        :disabled="disabled"
        @input="$emit('input', $event.target.value)"
        @focus="focused = true"
        @blur="focused = false"
      />
    </div>
    <span v-if="error" class="input-error">{{ error }}</span>
    <span v-if="helper" class="input-helper">{{ helper }}</span>
  </div>
</template>

<script>
export default {
  name: 'AppInput',
  props: {
    value: [String, Number],
    label: String,
    placeholder: String,
    type: {
      type: String,
      default: 'text'
    },
    icon: String,
    error: String,
    helper: String,
    disabled: Boolean
  },
  data() {
    return {
      focused: false
    }
  }
}
</script>

<style scoped>
.app-input {
  margin-bottom: var(--spacing-md);
}

.input-label {
  display: block;
  margin-bottom: var(--spacing-xs);
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--gray-700);
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-icon {
  position: absolute;
  left: var(--spacing-md);
  font-size: 1rem;
  opacity: 0.5;
}

.app-input input {
  width: 100%;
  padding: var(--spacing-sm) var(--spacing-md);
  border: 1px solid var(--gray-300);
  border-radius: var(--radius-md);
  font-size: 0.9375rem;
  transition: all 0.2s;
  background: white;
}

.app-input input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.app-input.error input {
  border-color: var(--danger);
}

.input-error {
  display: block;
  margin-top: var(--spacing-xs);
  font-size: 0.75rem;
  color: var(--danger);
}

.input-helper {
  display: block;
  margin-top: var(--spacing-xs);
  font-size: 0.75rem;
  color: var(--gray-500);
}
</style>