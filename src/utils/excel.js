const VERDE_HEADER = 'FFA9D18E'
const VERDE_BORDE   = 'FF70AD47'
const GRIS_BORDE    = 'FFE2E8F0'

export async function descargarXlsx(filas, nombreArchivo) {
  const { default: ExcelJS } = await import('exceljs')
  const [encabezados, ...datos] = filas

  const wb = new ExcelJS.Workbook()
  wb.creator = 'LH Inventario'
  wb.created = new Date()
  const ws = wb.addWorksheet('Datos')

  ws.addRow(encabezados)
  datos.forEach(fila => ws.addRow(fila))

  ws.columns.forEach((col, i) => {
    const valores = [encabezados[i], ...datos.map(f => f[i])]
    const maxLen = valores.reduce((m, v) => Math.max(m, String(v ?? '').length), 0)
    col.width = Math.min(Math.max(maxLen + 3, 12), 40)
  })

  const header = ws.getRow(1)
  header.height = 22
  header.eachCell(cell => {
    cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: VERDE_HEADER } }
    cell.font = { bold: true, size: 11, color: { argb: 'FF1F2937' } }
    cell.alignment = { vertical: 'middle', horizontal: 'left' }
    cell.border = {
      top: { style: 'thin', color: { argb: VERDE_BORDE } },
      bottom: { style: 'thin', color: { argb: VERDE_BORDE } },
      left: { style: 'thin', color: { argb: VERDE_BORDE } },
      right: { style: 'thin', color: { argb: VERDE_BORDE } },
    }
  })

  ws.eachRow((row, rowNumber) => {
    row.height = 18
    row.eachCell(cell => {
      cell.alignment = { ...cell.alignment, vertical: 'middle' }
      if (rowNumber > 1) {
        cell.border = {
          top: { style: 'thin', color: { argb: GRIS_BORDE } },
          bottom: { style: 'thin', color: { argb: GRIS_BORDE } },
          left: { style: 'thin', color: { argb: GRIS_BORDE } },
          right: { style: 'thin', color: { argb: GRIS_BORDE } },
        }
      }
    })
  })

  ws.views = [{ state: 'frozen', ySplit: 1 }]
  ws.autoFilter = { from: { row: 1, column: 1 }, to: { row: 1, column: encabezados.length } }

  const buffer = await wb.xlsx.writeBuffer()
  const blob = new Blob([buffer], {
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = nombreArchivo
  a.click()
  URL.revokeObjectURL(url)
}
