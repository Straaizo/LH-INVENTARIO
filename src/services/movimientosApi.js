import http from './apiClient'

function parseMov(r) {
  const cant = Number(r.cantidad ?? 0)
  return {
    idMovimiento:     r.id_movimientos ?? r.id_movimiento ?? r.id ?? 0,
    idProducto:       r.id_producto ?? r.producto_id ?? 0,
    nombreProducto:   r.nombre_producto ?? r.producto_nombre ?? r.producto ?? '',
    cantidad:         cant,
    nombreCategoria:  r.nombre_categoria ?? r.categoria ?? '',
    fecha:            r.fecha ?? '',
    nombreDestino:    r.nombre_destino ?? r.nombre_sucursal ?? '',
    nombreMovimiento: r.nombre_movimiento ?? r.nombreMovimiento ?? '',
    idDestino:        r.id_destino ?? r.destino_id ?? null,
    idUsuario:        r.id_usuario ? String(r.id_usuario) : null,
    usuarioNombre:    r.usuario_nombre ?? r.nombre_usuario ?? null,
  }
}

export async function listarMovimientos() {
  try {
    const res = await http.get('/api/movimientos')
    const raw = Array.isArray(res.data) ? res.data : (res.data?.data ?? res.data?.items ?? [])
    return { items: raw.map(parseMov), error: null }
  } catch (err) {
    return { items: [], error: err.response?.data?.message || 'Error al cargar movimientos' }
  }
}

export async function listarSalidas() {
  try {
    const res = await http.get('/api/movimientos/salidas')
    const raw = Array.isArray(res.data)
      ? res.data
      : (res.data?.data ?? res.data?.salidas ?? res.data?.items ?? [])
    return raw.map(parseMov)
  } catch (_) { return [] }
}

export async function listarEntradas() {
  const { items } = await listarMovimientos()
  return items.filter((m) => m.nombreMovimiento.toUpperCase().includes('ENTRADA'))
}

export async function registrarEntrada({ idProducto, cantidad, idTipoMov, idDestino }) {
  try {
    await http.post('/api/movimientos', {
      cantidad,
      id_producto: idProducto,
      producto_id: idProducto,
      id_tipo_mov: idTipoMov,
      tipo_mov_id: idTipoMov,
      id_destino:  idDestino,
      destino_id:  idDestino,
    })
    return { ok: true }
  } catch (err) {
    return { ok: false, message: err.response?.data?.message || 'Error al registrar entrada' }
  }
}

export async function registrarSalida({ idProducto, cantidad, idDestino, idTipoMov, fecha }) {
  try {
    const body = {
      cantidad,
      id_producto: idProducto,
      producto_id: idProducto,
      id_tipo_mov: idTipoMov,
      tipo_mov_id: idTipoMov,
      id_destino:  idDestino,
      destino_id:  idDestino,
    }
    if (fecha) body.fecha = fecha
    await http.post('/api/movimientos', body)
    return { ok: true }
  } catch (err) {
    const d = err.response?.data
    return {
      ok: false,
      message: d?.message || 'Error al registrar salida',
      errorStock: d?.stock_disponible != null
        ? { message: d.message, stockDisponible: d.stock_disponible, cantidadSolicitada: d.cantidad_solicitada }
        : null,
    }
  }
}

export async function actualizarMovimiento(id, { idDestino, idProducto, cantidad, fecha }) {
  try {
    const body = {}
    if (idDestino  != null) body.id_destino  = idDestino
    if (idProducto != null) body.id_producto = idProducto
    if (cantidad   != null) body.cantidad    = cantidad
    if (fecha      != null) body.fecha       = fecha
    await http.put(`/api/movimientos/${id}`, body)
    return { ok: true }
  } catch (err) {
    const d = err.response?.data
    return {
      ok: false,
      message: d?.message || 'Error al actualizar',
      errorStock: d?.stock_disponible != null
        ? { message: d.message, stockDisponible: d.stock_disponible, cantidadSolicitada: d.cantidad_solicitada }
        : null,
    }
  }
}

export async function eliminarMovimiento(id) {
  try {
    await http.delete(`/api/movimientos/${id}`)
    return { ok: true }
  } catch (err) {
    return { ok: false, message: err.response?.data?.message || 'Error al eliminar' }
  }
}

export async function ajustarStock(idProducto, cantidadNueva) {
  try {
    await http.post('/api/movimientos/ajuste', { id_producto: idProducto, cantidad_nueva: cantidadNueva })
    return { ok: true }
  } catch (err) {
    return { ok: false, message: err.response?.data?.message || 'Error al ajustar' }
  }
}
