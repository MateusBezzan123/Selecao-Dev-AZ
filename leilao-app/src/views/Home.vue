<template>
  <div class="home">
    <div class="home-card">
      <h1>🔨 Sistema de Leilões</h1>
      <p>Bem-vindo ao sistema. Utilize o menu acima para navegar entre as seções.</p>
      <div class="home-links">
        <router-link to="/unidades" class="card-link">📦 Unidades</router-link>
        <router-link to="/empresas" class="card-link">🏢 Empresas</router-link>
        <router-link to="/leiloes"  class="card-link">🔖 Leilões</router-link>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Home'
}
</script>

<style scoped>
.home {
  display: flex;
  justify-content: center;
  margin-top: 60px;
}

.home-card {
  background: #fff;
  border-radius: 10px;
  padding: 48px 56px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  text-align: center;
  max-width: 560px;
  width: 100%;
}

.home-card h1 {
  font-size: 2rem;
  margin-bottom: 12px;
  color: #2c3e50;
}

.home-card p {
  color: #7f8c8d;
  margin-bottom: 36px;
  line-height: 1.6;
}

.home-links {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}

.card-link {
  display: inline-block;
  padding: 12px 28px;
  background-color: #42b983;
  color: #fff;
  border-radius: 6px;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.95rem;
  transition: background 0.2s;
}

.card-link:hover {
  background-color: #369870;
}
</style>