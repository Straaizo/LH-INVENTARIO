import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Eye, EyeOff, LogIn, AlertCircle } from 'lucide-react'
import { useAuth } from '../context/useAuth'

export default function Login() {
  const { doLogin, loading } = useAuth()
  const navigate = useNavigate()

  useEffect(() => {
    const meta = document.querySelector('meta[name="theme-color"]')
    const prev = meta?.getAttribute('content')
    const img = new Image()
    img.src = '/fondo_login.png'
    img.onload = () => {
      try {
        const canvas = document.createElement('canvas')
        canvas.width = 1; canvas.height = 1
        const ctx = canvas.getContext('2d')
        ctx.drawImage(img, img.width / 2, img.height - 20, 1, 1, 0, 0, 1, 1)
        const [r, g, b] = ctx.getImageData(0, 0, 1, 1).data
        const hex = `#${r.toString(16).padStart(2,'0')}${g.toString(16).padStart(2,'0')}${b.toString(16).padStart(2,'0')}`
        if (meta) meta.setAttribute('content', hex)
      } catch (_) {}
    }
    return () => { if (meta && prev) meta.setAttribute('content', prev) }
  }, [])

  const [identificador, setIdentificador] = useState('')
  const [contrasenia,   setContrasenia]   = useState('')
  const [showPass,      setShowPass]      = useState(false)
  const [errEmail,   setErrEmail]   = useState(null)
  const [errPass,    setErrPass]    = useState(null)
  const [errGeneral, setErrGeneral] = useState(null)
  const [errAcceso,  setErrAcceso]  = useState(null)

  async function handleSubmit(e) {
    e.preventDefault()
    setErrGeneral(null)
    setErrAcceso(null)
    let valid = true
    if (!identificador.trim()) { setErrEmail('Ingrese su correo o usuario'); valid = false }
    if (!contrasenia)          { setErrPass('Ingrese su contraseña');        valid = false }
    if (!valid) return

    const res = await doLogin(identificador.trim(), contrasenia)
    if (res.ok) {
      navigate('/', { replace: true })
    } else if (res.message?.toLowerCase().includes('acceso') || res.message?.toLowerCase().includes('desactivada')) {
      setErrAcceso(res.message)
    } else {
      setErrGeneral(res.message || 'Usuario o contraseña incorrectos')
    }
  }

  return (
    <div className="flex flex-col items-center justify-center relative overflow-hidden"
      style={{
        minHeight: '100dvh',
        background: 'url(/fondo_login.png)',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        paddingTop: 'env(safe-area-inset-top)',
        paddingBottom: 'env(safe-area-inset-bottom)',
      }}>

      {/* Overlay sutil */}
      <div className="absolute inset-0 bg-black/20 " />

      {/* Card glassmorphism */}
      <div className="relative z-10 w-full max-w-sm mx-6 px-8 py-10 flex flex-col items-center gap-6 rounded-2xl"
        style={{
          background: 'rgba(255,255,255,0.18)',
          backdropFilter: 'blur(18px)',
          WebkitBackdropFilter: 'blur(18px)',
          border: '1px solid rgba(255,255,255,0.28)',
          boxShadow: '0 8px 32px rgba(0,0,0,0.25)',
        }}>

        {/* Logo */}
        <div className="w-24 h-24 rounded-full bg-white flex items-center justify-center shadow-2xl">
          <img src="/logo_lh.png" alt="LH" className="w-14 h-14 object-contain" />
        </div>

        <div className="text-center">
          <h1 className="text-2xl font-bold text-white tracking-tight"
            style={{ textShadow: '0 1px 6px rgba(0,0,0,0.5)' }}>Iniciar Sesión</h1>
          <p className="text-sm mt-1 font-semibold text-white"
            style={{ textShadow: '0 1px 6px rgba(0,0,0,0.6)' }}>LH Inventario</p>
        </div>

        <form onSubmit={handleSubmit} className="w-full flex flex-col gap-3">

          {/* Error de acceso/cuenta desactivada */}
          {errAcceso && (
            <div className="flex items-center gap-2 px-3 py-2.5 rounded-xl text-white text-sm font-medium"
              style={{ background: 'rgba(180,83,9,0.92)', boxShadow: '0 2px 10px rgba(0,0,0,0.3)' }}>
              <AlertCircle size={15} className="flex-shrink-0" />
              <span>{errAcceso}</span>
            </div>
          )}

          {/* Error general (credenciales incorrectas) */}
          {errGeneral && (
            <div className="flex items-center gap-2 px-3 py-2.5 rounded-xl text-white text-sm font-medium"
              style={{ background: 'rgba(185,28,28,0.88)', boxShadow: '0 2px 10px rgba(0,0,0,0.3)' }}>
              <AlertCircle size={15} className="flex-shrink-0" />
              <span>{errGeneral}</span>
            </div>
          )}

          {/* Email / Usuario */}
          <div className="flex flex-col gap-1">
            <input
              type="text"
              placeholder="Correo o usuario"
              value={identificador}
              onChange={(e) => { setIdentificador(e.target.value); setErrEmail(null); setErrGeneral(null) }}
              className={`w-full px-4 py-3 rounded-xl bg-white text-gray-800 text-sm outline-none transition-all
                ${errEmail ? 'ring-2 ring-red-500' : 'focus:ring-2 focus:ring-green-400'}`}
            />
            {errEmail && (
              <p className="flex items-center gap-1 text-xs font-semibold px-1"
                style={{ color: '#ef4444', textShadow: '0 1px 4px rgba(0,0,0,0.8)' }}>
                <AlertCircle size={11} className="flex-shrink-0" />
                {errEmail}
              </p>
            )}
          </div>

          {/* Contraseña */}
          <div className="flex flex-col gap-1">
            <div className="relative">
              <input
                type={showPass ? 'text' : 'password'}
                placeholder="Contraseña"
                value={contrasenia}
                onChange={(e) => { setContrasenia(e.target.value); setErrPass(null); setErrGeneral(null) }}
                onKeyDown={(e) => e.key === 'Enter' && handleSubmit(e)}
                className={`w-full px-4 py-3 pr-11 rounded-xl bg-white text-gray-800 text-sm outline-none transition-all
                  ${errPass ? 'ring-2 ring-red-500' : 'focus:ring-2 focus:ring-green-400'}`}
              />
              <button type="button" onClick={() => setShowPass(!showPass)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                {showPass ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
            {errPass && (
              <p className="flex items-center gap-1 text-xs font-semibold px-1"
                style={{ color: '#ef4444', textShadow: '0 1px 4px rgba(0,0,0,0.8)' }}>
                <AlertCircle size={11} className="flex-shrink-0" />
                {errPass}
              </p>
            )}
          </div>

          <button type="submit" disabled={loading}
            className="mt-1 w-full py-3.5 rounded-full bg-green-700 hover:bg-green-800 disabled:opacity-60
              text-white font-semibold text-sm flex items-center justify-center gap-2 transition-colors shadow-lg">
            {loading
              ? <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              : <LogIn size={18} />}
            {loading ? 'Cargando...' : 'Iniciar Sesión'}
          </button>
        </form>

        <p className="text-white text-xs text-center mt-2 font-medium"
          style={{ textShadow: '0 1px 6px rgba(0,0,0,0.7)' }}>
          Desarrollado por el departamento de TI de la Hornilla
        </p>
      </div>
    </div>
  )
}
