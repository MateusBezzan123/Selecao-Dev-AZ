const API_URL = 'http://localhost:8081'

class AuthService {
  async login(username, password) {
    try {
      const response = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ username, password })
      })

      if (!response.ok) {
        throw new Error('Credenciais inválidas')
      }

      const data = await response.json()
      
      if (data.token) {
        localStorage.setItem('token', data.token)
        localStorage.setItem('user', JSON.stringify({ username: data.username }))
      }
      
      return data
    } catch (error) {
      console.error('Erro no login:', error)
      throw error
    }
  }

  logout() {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  getToken() {
    return localStorage.getItem('token')
  }

  getUser() {
    const user = localStorage.getItem('user')
    return user ? JSON.parse(user) : null
  }

  isAuthenticated() {
    return !!this.getToken()
  }
}

export default new AuthService()