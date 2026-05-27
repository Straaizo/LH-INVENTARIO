import http from './apiClient'

export async function listarDestinos() {
  try {
    const res = await http.get('/api/catalogo/destinos')
    const raw = Array.isArray(res.data) ? res.data : (res.data?.data || [])
    return raw.map((d) => ({
      id:     d.id_destino ?? d.id ?? 0,
      nombre: d.nombre_destino ?? d.nombre ?? '',
    }))
  } catch (_) { return [] }
}

export async function listarTiposMovimiento() {
  try {
    const res = await http.get('/api/catalogo/tipos-movimiento')
    const raw = Array.isArray(res.data) ? res.data : (res.data?.data || [])
    return raw.map((t) => ({
      id:     t.id_tipo_movimiento ?? t.id ?? 0,
      nombre: t.nombre_movimiento ?? t.nombre ?? '',
    }))
  } catch (_) { return [] }
}

export function idParaEntrada(tipos) {
  const t = tipos.find((x) => x.nombre.toUpperCase().includes('ENTRADA'))
  return t?.id ?? null
}

export function idParaSalida(tipos) {
  const t = tipos.find((x) => x.nombre.toUpperCase().includes('SALIDA'))
  return t?.id ?? null
}

export function idPreferidoParaEntrada(destinos) {
  const oficina = destinos.find((d) =>
    d.nombre.toUpperCase().includes('OFICINA') || d.nombre.toUpperCase().includes('CENTRAL')
  )
  return oficina?.id ?? destinos[0]?.id ?? null
}
