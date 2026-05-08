<template>
  <div class="page">
    <div class="page-header">
      <h2>📦 Unidades</h2>
      <p>Gerenciamento das unidades de medida cadastradas no sistema.</p>
    </div>
    <div class="page-body">
      <p class="placeholder">Listagem de unidades será exibida aqui.</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Unidades'
}
</script>

<style scoped>
.page {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  overflow: hidden;
}

.page-header {
  padding: 24px 32px;
  background-color: #2c3e50;
  color: #fff;
}

.page-header h2 {
  font-size: 1.5rem;
  margin-bottom: 4px;
}

.page-header p {
  font-size: 0.9rem;
  opacity: 0.75;
}

.page-body {
  padding: 32px;
}

.placeholder {
  color: #95a5a6;
  font-style: italic;
}
</style>