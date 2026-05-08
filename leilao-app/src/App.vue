<template>
  <div id="app">
    <header id="header">
      <div id="logo">🔨 Sistema de Leilões</div>
      <nav id="nav">
        <router-link to="/">Home</router-link>
        <router-link to="/unidades">Unidades</router-link>
        <router-link to="/empresas">Empresas</router-link>
        <router-link to="/leiloes">Leilões</router-link>
      </nav>
    </header>

    <section id="root">
      <router-view/>
    </section>
  </div>
</template>

<style>
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  background-color: #f4f6f9;
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

#app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* ── Header ─────────────────────────────────────── */
#header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  height: 60px;
  background-color: #2c3e50;
  color: #fff;
  box-shadow: 0 2px 6px rgba(0,0,0,0.3);
}

#logo {
  font-size: 1.2rem;
  font-weight: bold;
  letter-spacing: 1px;
}

/* ── Nav ─────────────────────────────────────────── */
#nav {
  display: flex;
  gap: 8px;
}

#nav a {
  color: #bdc3c7;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.95rem;
  padding: 6px 16px;
  border-radius: 4px;
  transition: background 0.2s, color 0.2s;
}

#nav a:hover {
  background-color: rgba(255,255,255,0.1);
  color: #fff;
}

#nav a.router-link-exact-active {
  background-color: #42b983;
  color: #fff;
}

/* ── Content section ─────────────────────────────── */
#root {
  flex: 1;
  padding: 32px;
}
</style>