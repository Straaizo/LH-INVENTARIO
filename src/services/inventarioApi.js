import http from './apiClient'

// ── Stock actual ────────────────────────────────────────────────────────────
export async function listarStock() {
  try {
    const res = await http.get('/api/inventario/stock')
    const raw = Array.isArray(res.data) ? res.data : (res.data?.data || res.data?.items || [])
    return raw.map((r) => ({
      idProducto:      r.id_producto ?? r.idProducto ?? 0,
      stockActual:     Number(r.stock_actual ?? r.stockActual ?? 0),
      nombreProducto:  r.nombre_producto ?? r.nombreProducto ?? r.producto ?? '',
      nombreCategoria: r.nombre_categoria ?? r.nombreCategoria ?? r.categoria ?? '',
    }))
  } catch (err) {
    return { error: err.response?.data?.message || 'Error al cargar stock' }
  }
}

// ── Categorías ──────────────────────────────────────────────────────────────
export async function listarCategorias() {
  try {
    const res = await http.get('/api/inventario/categorias')
    const raw = Array.isArray(res.data) ? res.data : (res.data?.data || [])
    return raw.map((c) => ({
      id:     c.id_categoria ?? c.id ?? 0,
      nombre: c.nombre_categoria ?? c.nombre ?? '',
    }))
  } catch (_) { return [] }
}

// ── Productos ───────────────────────────────────────────────────────────────
export async function listarProductos() {
  try {
    const res = await http.get('/api/inventario/productos')
    const raw = Array.isArray(res.data) ? res.data : (res.data?.data || [])
    return raw.map((p) => ({
      idProducto:      p.id_producto ?? p.id ?? 0,
      nombreProducto:  p.nombre_producto ?? p.nombre ?? '',
      nombreCategoria: p.nombre_categoria ?? p.nombreCategoria ?? '',
      idCategoria:     p.id_categoria ?? p.idCategoria ?? null,
    }))
  } catch (_) { return [] }
}

export async function crearProducto(nombre, idCategoria) {
  try {
    await http.post('/api/inventario/productos', { nombre_producto: nombre, id_categoria: idCategoria })
    return { ok: true }
  } catch (err) {
    return { ok: false, message: err.response?.data?.message || 'Error al crear producto' }
  }
}

export async function actualizarProducto(id, nombre, idCategoria) {
  try {
    await http.put(`/api/inventario/productos/${id}`, { nombre_producto: nombre, id_categoria: idCategoria })
    return { ok: true }
  } catch (err) {
    return { ok: false, message: err.response?.data?.message || 'Error al actualizar' }
  }
}

export async function eliminarProducto(id) {
  try {
    await http.delete(`/api/inventario/productos/${id}`)
    return { ok: true }
  } catch (err) {
    return { ok: false, message: err.response?.data?.message || 'Error al eliminar' }
  }
}

export async function ajustarStock(idProducto, nuevoStock) {
  try {
    const res = await http.post(`/api/inventario/stock/${idProducto}/ajuste`, { nuevo_stock: nuevoStock })
    return { ok: true, data: res.data }
  } catch (err) {
    return { ok: false, message: err.response?.data?.error || err.response?.data?.message || 'Error al ajustar stock' }
  }
}
