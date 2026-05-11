export const API_BASE_URL = 'http://localhost:8080/api'

const getHeaders = () => ({
  'Content-Type': 'application/json',
})

export async function apiFetch(path, opts = {}) {
  const headers = { ...getHeaders(), ...opts.headers }
  try {
    const res = await fetch(`${API_BASE_URL}${path}`, { ...opts, headers })
    
    if (!res.ok) {
      const errText = await res.text()
      throw new Error(errText || `HTTP ${res.status}: ${res.statusText}`)
    }
    
    const contentType = res.headers.get('content-type')
    if (contentType && contentType.includes('application/json')) {
      return await res.json()
    }
    return null
  } catch (err) {
    console.error('API Error:', err)
    throw err
  }
}

// Auth API
export const auth = {
  login: (credentials) => apiFetch('/login', { method: 'POST', body: JSON.stringify(credentials) }),
  register: (data) => apiFetch('/register', { method: 'POST', body: JSON.stringify(data) }),
}

// Students API
export const students = {
  list: () => apiFetch('/students'),
  create: (data) => apiFetch('/students', { method: 'POST', body: JSON.stringify(data) }),
  update: (id, data) => apiFetch(`/students/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  delete: (id) => apiFetch(`/students/${id}`, { method: 'DELETE' }),
}

// Subjects API
export const subjects = {
  list: () => apiFetch('/subjects'),
  create: (data) => apiFetch('/subjects', { method: 'POST', body: JSON.stringify(data) }),
  update: (id, data) => apiFetch(`/subjects/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  delete: (id) => apiFetch(`/subjects/${id}`, { method: 'DELETE' }),
}

// Assignments API
export const assignments = {
  assign: (studentId, subjectId) => apiFetch(`/${studentId}/subjects/${subjectId}`, { method: 'PUT' }),
}
