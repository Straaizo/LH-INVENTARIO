import axios from 'axios'

const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'
const TIMEOUT  = Number(import.meta.env.VITE_API_TIMEOUT) || 15000

let _accessToken  = sessionStorage.getItem('_at') || null
let _refreshToken = sessionStorage.getItem('_rt') || null
let _refreshing   = false

const http = axios.create({ baseURL: BASE_URL, timeout: TIMEOUT })

http.interceptors.request.use((config) => {
  if (_accessToken) config.headers['Authorization'] = `Bearer ${_accessToken}`
  return config
})

async function _tryRefresh() {
  if (!_refreshToken || _refreshing) return false
  _refreshing = true
  try {
    const res = await http.post('/api/auth/refresh', null, {
      headers: { Authorization: `Bearer ${_refreshToken}` },
    })
    const { access_token, refresh_token } = res.data
    if (access_token) {
      _accessToken = access_token
      sessionStorage.setItem('_at', _accessToken)
      if (refresh_token) {
        _refreshToken = refresh_token
        sessionStorage.setItem('_rt', _refreshToken)
      }
      return true
    }
  } catch (_) {}
  _accessToken  = null
  _refreshToken = null
  sessionStorage.removeItem('_at')
  sessionStorage.removeItem('_rt')
  return false
}

http.interceptors.response.use(
  (res) => res,
  async (err) => {
    const orig = err.config
    if (err.response?.status === 401 && _refreshToken && !orig._retry) {
      orig._retry = true
      _refreshing = false
      const ok = await _tryRefresh()
      _refreshing = false
      if (ok) {
        orig.headers['Authorization'] = `Bearer ${_accessToken}`
        return http(orig)
      }
    }
    _refreshing = false
    return Promise.reject(err)
  }
)

export function setAuthToken(token, refreshToken) {
  _accessToken = token || null
  if (refreshToken !== undefined) _refreshToken = refreshToken || null
  if (_accessToken) {
    sessionStorage.setItem('_at', _accessToken)
    if (_refreshToken) sessionStorage.setItem('_rt', _refreshToken)
    else sessionStorage.removeItem('_rt')
  } else {
    sessionStorage.removeItem('_at')
    sessionStorage.removeItem('_rt')
    sessionStorage.removeItem('_user')
  }
}

export function hasAuthToken() { return !!_accessToken }

export async function logout() {
  if (_accessToken) {
    try { await http.post('/api/auth/logout') } catch (_) {}
  }
  _accessToken  = null
  _refreshToken = null
  sessionStorage.removeItem('_at')
  sessionStorage.removeItem('_rt')
  sessionStorage.removeItem('_user')
}

export default http
