import http from './apiClient'

export async function login(identificador, contrasenia) {
  try {
    const isEmail = identificador.includes('@')
    const body = {
      contrasenia,
      contrasena: contrasenia,
      password:   contrasenia,
      ...(isEmail
        ? { correo: identificador, email: identificador }
        : { usuario: identificador, nombre_usuario: identificador, username: identificador }
      ),
    }
    const res = await http.post('/api/auth/login', body)
    const d   = res.data
    const usr = d.usuario || d.user || {}
    return {
      ok:           true,
      nombre:       usr.nombre || d.nombre || '',
      token:        d.access_token || d.accessToken || d.token || '',
      refreshToken: d.refresh_token || '',
      message:      null,
    }
  } catch (err) {
    const d = err.response?.data
    return {
      ok:      false,
      message: d?.error || d?.message || d?.detail || 'Usuario o contraseña incorrectos',
    }
  }
}

export async function mapaNombresParaMostrarPorId() {
  try {
    const res = await http.get('/api/usuarios/nombres')
    const data = Array.isArray(res.data) ? res.data : (res.data?.data || [])
    const mapa = {}
    for (const u of data) {
      const id = u.id_usuario || u.id
      const nombre = u.nombre || u.name || u.login || ''
      if (id && nombre) mapa[String(id)] = nombre
    }
    return mapa
  } catch (_) { return {} }
}
