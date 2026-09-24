import http from './apiClient'

function makeApi(path, parseRow) {
  return {
    async listar() {
      try {
        const res = await http.get(path)
        const raw = Array.isArray(res.data) ? res.data : (res.data?.data || [])
        return raw.map(parseRow)
      } catch (_) { return [] }
    },
    async crear(body) {
      try { await http.post(path, body); return { ok: true } }
      catch (err) { return { ok: false, message: err.response?.data?.message || 'Error al crear' } }
    },
    async actualizar(id, body) {
      try { await http.put(`${path}/${id}`, body); return { ok: true } }
      catch (err) { return { ok: false, message: err.response?.data?.message || 'Error al actualizar' } }
    },
  }
}

export const equiposApi = makeApi('/api/activos/equipos', (r) => ({
  id:              r.id_equipos ?? r.id ?? 0,
  codigo:          r.codigo_equipo ?? '',
  estado:          r.estado ?? '',
  antivirus:       r.antivirus ?? '',
  ubicacion:       r.ubicacion ?? '',
  tipo:            r.tipo ?? '',
  marca:           r.marca ?? '',
  modelo:          r.modelo ?? '',
  procesador:      r.procesador ?? '',
  ram:             r.ram ?? '',
  discoDuro:       r.disco_duro ?? r.discoDuro ?? '',
  sistemaOperativo:r.sistema_operativo ?? r.sistemaOperativo ?? '',
  office:          r.office ?? '',
  numeroSerie:     r.numero_serie ?? r.numeroSerie ?? '',
  fechaRevision:   r.fecha_revision ?? r.fechaRevision ?? '',
  responsable:     r.responsable ?? r.usuario_nombre ?? '',
  comentario:      r.comentario ?? '',
}))

export const celularesApi = makeApi('/api/activos/celulares', (r) => ({
  id:             r.id ?? 0,
  numero:         r.numero ?? '',
  estado:         r.estado ?? '',
  tipoCelular:    r.tipo_celular ?? '',
  compania:       r.compania ?? '',
  marca:          r.marca ?? '',
  modelo:         r.modelo ?? '',
  imei:           r.imei ?? '',
  fechaEntrega:   r.fecha_entrega ?? '',
  responsable:    r.responsable ?? '',
  identificador:  r.identificador ?? '',
  comentario:     r.comentario ?? '',
}))

export const tabletsApi = makeApi('/api/activos/tablets', (r) => ({
  id:           r.id_tablet ?? r.id ?? 0,
  codigo:       r.codigo_tablet ?? r.codigoTablet ?? '',
  estado:       r.estado ?? '',
  marca:        r.marca ?? '',
  modelo:       r.modelo ?? '',
  capacidad:    r.capacidad ?? '',
  fechaEntrega: r.fecha_entrega ?? r.fechaEntrega ?? '',
  responsable:  r.responsable ?? '',
}))

export const impresorasApi = makeApi('/api/activos/impresoras', (r) => ({
  id:          r.id_impresora ?? r.id ?? 0,
  estado:      r.estado ?? '',
  ubicacion:   r.ubicacion ?? '',
  impresora:   r.impresora ?? '',
  conexion:    r.conexion ?? '',
  fecha:       r.fecha ?? '',
  responsable: r.responsable ?? '',
}))
