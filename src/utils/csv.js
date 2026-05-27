export function descargarCsv(filas, nombreArchivo) {
  const bom = '﻿'
  const contenido = bom + filas.map((fila) =>
    fila.map((celda) => {
      const v = celda == null ? '' : String(celda)
      if (v.includes(';') || v.includes('"') || v.includes('\n')) return `"${v.replaceAll('"', '""')}"`
      return v
    }).join(';')
  ).join('\n')
  const blob = new Blob([contenido], { type: 'text/csv;charset=utf-8;' })
  const url  = URL.createObjectURL(blob)
  const a    = document.createElement('a')
  a.href     = url
  a.download = nombreArchivo
  a.click()
  URL.revokeObjectURL(url)
}

export function formatearFechahora(fechaStr) {
  if (!fechaStr) return ''
  const d = new Date(fechaStr)
  if (isNaN(d)) return fechaStr
  const hh = String(d.getHours()).padStart(2, '0')
  const mm = String(d.getMinutes()).padStart(2, '0')
  return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()} ${hh}:${mm}`
}
