import { createContext, useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { setAuthToken, logout as apiLogout, hasAuthToken } from '../services/apiClient'
import { login as apiLogin } from '../services/authApi'

export const AuthContext = createContext(null)

const INACTIVITY_MS  = 15 * 60 * 1000
const WARNING_BEFORE =  1 * 60 * 1000

function _restoreUser() {
  try {
    const s = sessionStorage.getItem('_user')
    if (hasAuthToken() && s) return JSON.parse(s)
  } catch (_) {}
  return null
}

export function AuthProvider({ children }) {
  const [user,              setUser]              = useState(_restoreUser)
  const [loading,           setLoading]           = useState(false)
  const [inactivityWarning, setInactivityWarning] = useState(false)
  const timerRef = useRef(null)
  const warnRef  = useRef(null)
  const navigate = useNavigate()

  function clearTimers() {
    if (timerRef.current) clearTimeout(timerRef.current)
    if (warnRef.current)  clearTimeout(warnRef.current)
  }

  function resetTimer() {
    clearTimers()
    warnRef.current  = setTimeout(() => setInactivityWarning(true), INACTIVITY_MS - WARNING_BEFORE)
    timerRef.current = setTimeout(doLogout, INACTIVITY_MS)
  }

  function extendSession() {
    setInactivityWarning(false)
    resetTimer()
  }

  useEffect(() => {
    if (!user) return
    resetTimer()
    window.addEventListener('pointerdown', extendSession)
    window.addEventListener('keydown',     extendSession)
    return () => {
      window.removeEventListener('pointerdown', extendSession)
      window.removeEventListener('keydown',     extendSession)
      clearTimers()
    }
  }, [user])

  async function doLogin(identificador, contrasenia) {
    setLoading(true)
    const res = await apiLogin(identificador, contrasenia)
    setLoading(false)
    if (!res.ok) return res
    setAuthToken(res.token, res.refreshToken)
    const u = { nombre: res.nombre || 'Usuario' }
    sessionStorage.setItem('_user', JSON.stringify(u))
    setUser(u)
    return res
  }

  async function doLogout() {
    await apiLogout()
    setUser(null)
    setInactivityWarning(false)
    clearTimers()
    navigate('/login', { replace: true })
  }

  return (
    <AuthContext.Provider value={{ user, loading, doLogin, doLogout, inactivityWarning, extendSession }}>
      {children}
    </AuthContext.Provider>
  )
}

