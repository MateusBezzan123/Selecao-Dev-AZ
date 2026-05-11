const API_URL = 'http://localhost:8081'

class ApiService {
  constructor() {
    this.token = localStorage.getItem('token')
  }

  getHeaders() {
    const headers = {
      'Content-Type': 'application/json'
    }
    
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`
    }
    
    return headers
  }

  setToken(token) {
    this.token = token
    if (token) {
      localStorage.setItem('token', token)
    } else {
      localStorage.removeItem('token')
    }
  }

  async get(endpoint) {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'GET',
      headers: this.getHeaders()
    })
    
    if (response.status === 401) {
      this.setToken(null)
      window.location.href = '/login'
      throw new Error('Sessão expirada')
    }
    
    return response.json()
  }

  async post(endpoint, data) {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify(data)
    })
    
    if (response.status === 401) {
      this.setToken(null)
      window.location.href = '/login'
      throw new Error('Sessão expirada')
    }
    
    return response.json()
  }

  async put(endpoint, data) {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'PUT',
      headers: this.getHeaders(),
      body: JSON.stringify(data)
    })
    
    if (response.status === 401) {
      this.setToken(null)
      window.location.href = '/login'
      throw new Error('Sessão expirada')
    }
    
    return response.json()
  }

  async delete(endpoint) {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'DELETE',
      headers: this.getHeaders()
    })
    
    if (response.status === 401) {
      this.setToken(null)
      window.location.href = '/login'
      throw new Error('Sessão expirada')
    }
    
    return response
  }
}

export default new ApiService()