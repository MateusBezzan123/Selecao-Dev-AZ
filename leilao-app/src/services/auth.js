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
        const error = await response.json()
        throw new Error(error.message || 'Credenciais inválidas')
      }

      const data = await response.json()
      
      if (data.token) {
        const userResponse = await fetch(`${API_URL}/empresa?usuario=${username}`)
        const users = await userResponse.json()
        const user = users.find(u => u.usuario === username) || users[0]
        
        localStorage.setItem('token', data.token)
        localStorage.setItem('user', JSON.stringify({ 
          id: user?.id,
          username: data.username,
          role: user?.role || 'USER'
        }))
        localStorage.setItem('loginTime', new Date().getTime())
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
    localStorage.removeItem('loginTime')
    localStorage.removeItem('theme')
    
    window.dispatchEvent(new Event('user-logout'))
  }

  async logoutServer() {
    try {
      const token = this.getToken()
      if (token) {
        await fetch(`${API_URL}/auth/logout`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        })
      }
    } catch (error) {
      console.error('Erro ao fazer logout no servidor:', error)
    } finally {
      this.logout()
    }
  }

  getToken() {
    return localStorage.getItem('token')
  }

  getUser() {
    const user = localStorage.getItem('user')
    return user ? JSON.parse(user) : null
  }

  isAuthenticated() {
    const token = this.getToken()
    const loginTime = localStorage.getItem('loginTime')
    
    if (!token) return false
    
    if (loginTime) {
      const elapsed = new Date().getTime() - parseInt(loginTime)
      const eightHours = 8 * 60 * 60 * 1000
      if (elapsed > eightHours) {
        this.logout()
        return false
      }
    }
    
    return true
  }

  async validateToken() {
    const token = this.getToken()
    if (!token) return false
    
    try {
      const response = await fetch(`${API_URL}/auth/validate`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
      return response.ok
    } catch (error) {
      return false
    }
  }
}

export default new AuthService()