import { useEffect, useRef, useState } from 'react'
import { BarChart2, Download, Filter, Search } from 'lucide-react'
import {
  ComposedChart, Bar, Line, XAxis, YAxis,
  CartesianGrid, Tooltip, Legend, ResponsiveContainer,
} from 'recharts'
import { listarSalidas } from '../services/movimientosApi'

const PERIODOS = [
  { key: '7',   label: '7 días' },
  { key: '30',  label: '30 días' },
  { key: '90',  label: '90 días' },
  { key: 'all', label: 'Todo' },
]

const AGRUPACIONES = [
  { key: 'destino',  label: 'Destino' },
  { key: 'producto', label: 'Producto' },
]

function filtrarPorPeriodo(salidas, periodo) {
  if (periodo === 'all') return salidas
  const desde = new Date()
  desde.setDate(desde.getDate() - Number(periodo))
  return salidas.filter(s => {
    const f = new Date(s.fecha)
    return !isNaN(f) && f >= desde
  })
}

function calcularDatos(salidas, por) {
  const map = {}
  for (const s of salidas) {
    const key = por === 'producto' ? s.nombreProducto : s.nombreDestino
    if (!key) continue
    map[key] = (map[key] || 0) + s.cantidad
  }
  const arr = Object.entries(map)
    .map(([nombre, total]) => ({ nombre, total }))
    .sort((a, b) => b.total - a.total)
  const totalGeneral = arr.reduce((s, i) => s + i.total, 0)
  let acum = 0
  return arr.map(item => {
    acum += item.total
    return {
      ...item,
      pct:       totalGeneral > 0 ? Math.round((item.total / totalGeneral) * 100) : 0,
      acumulado: totalGeneral > 0 ? Math.round((acum / totalGeneral) * 100) : 0,
    }
  })
}

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null
  return (
    <div className="bg-white dark:bg-[#1A2332] border border-slate-200 dark:border-white/10 rounded-xl p-3 shadow-lg text-xs max-w-[220px]">
      <p className="font-semibold text-slate-800 dark:text-white mb-1.5 truncate">{label}</p>
      {payload.map((p, i) => (
        <p key={i} className="flex items-center justify-between gap-4">
          <span style={{ color: p.color }}>{p.name}</span>
          <span className="font-bold text-slate-800 dark:text-white">
            {p.value}{p.name === 'Acumulado %' ? '%' : ' uds'}
          </span>
        </p>
      ))}
    </div>
  )
}

async function cargarLogoBase64() {
  try {
    const res  = await fetch('/logo_lh.png')
    const blob = await res.blob()
    return await new Promise(resolve => {
      const reader = new FileReader()
      reader.onload = () => resolve(reader.result)
      reader.readAsDataURL(blob)
    })
  } catch { return null }
}

// ── PDF generator ──────────────────────────────────────────────────────────────
async function generarPDF({ datos, filtradas, agrupado, periodo, chartRef }) {
  const [{ default: jsPDF }, { default: html2canvas }, logoB64] = await Promise.all([
    import('jspdf'),
    import('html2canvas'),
    cargarLogoBase64(),
  ])

  const pdf = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' })
  const W = 297
  const H = 210
  const P = 14

  const NAVY  = [15, 23, 42]
  const NAVYD = [18, 27, 47]
  const GREEN = [22, 163, 74]
  const GREENL= [220, 252, 231]
  const WHITE = [255, 255, 255]
  const FONDO = [248, 250, 252]
  const TEXTO = [30, 41, 59]
  const GRIS  = [100, 116, 139]
  const GRISL = [226, 232, 240]

  const labelPer = PERIODOS.find(p => p.key === periodo)?.label || ''
  const labelAg  = agrupado === 'producto' ? 'Productos' : 'Destinos'
  const fechaStr = new Date().toLocaleDateString('es-CL', { day: '2-digit', month: 'long', year: 'numeric' })
  const totalUds = filtradas.reduce((s, i) => s + i.cantidad, 0)
  const topItem  = datos[0]?.nombre || '—'

  // ── HEADER (0 → 38mm) ───────────────────────────────────────────────────────
  const HDR_H = 38
  pdf.setFillColor(...NAVY)
  pdf.rect(0, 0, W, HDR_H, 'F')

  // Logo 28×28, centrado verticalmente
  const LOGO_S = 28
  const LOGO_X = P
  const LOGO_Y = (HDR_H - LOGO_S) / 2
  pdf.setFillColor(...WHITE)
  pdf.roundedRect(LOGO_X, LOGO_Y, LOGO_S, LOGO_S, 5, 5, 'F')
  if (logoB64) pdf.addImage(logoB64, 'PNG', LOGO_X + 3, LOGO_Y + 3, LOGO_S - 6, LOGO_S - 6)

  // Empresa
  const TXT_X = LOGO_X + LOGO_S + 7
  pdf.setFont('helvetica', 'bold');   pdf.setFontSize(12); pdf.setTextColor(...WHITE)
  pdf.text('LA HORNILLA', TXT_X, HDR_H / 2 - 0.5)
  pdf.setFont('helvetica', 'normal'); pdf.setFontSize(8);  pdf.setTextColor(148, 163, 184)
  pdf.text('Sistema de Inventario', TXT_X, HDR_H / 2 + 6.5)

  // Título centrado
  pdf.setFont('helvetica', 'bold'); pdf.setFontSize(22); pdf.setTextColor(...WHITE)
  pdf.text('Análisis de Inventario', W / 2, HDR_H / 2 - 1, { align: 'center' })

  // Subtítulo
  pdf.setFont('helvetica', 'normal'); pdf.setFontSize(8.5); pdf.setTextColor(...GREENL)
  pdf.text(`${labelAg}  ·  Período: ${labelPer}  ·  ${fechaStr}`, W / 2, HDR_H / 2 + 8, { align: 'center' })

  // Línea verde al final del header
  pdf.setFillColor(...GREEN)
  pdf.rect(0, HDR_H, W, 2, 'F')

  // ── KPI STRIP (40 → 58mm) ────────────────────────────────────────────────────
  const STRIP_Y = HDR_H + 2
  const STRIP_H = 18
  pdf.setFillColor(...NAVYD)
  pdf.rect(0, STRIP_Y, W, STRIP_H, 'F')

  const kpis = [
    { label: 'Total unidades',    value: String(totalUds) },
    { label: agrupado === 'producto' ? 'Productos distintos' : 'Destinos distintos', value: String(datos.length) },
    { label: 'Mayor consumo',     value: topItem.length > 26 ? topItem.slice(0, 26) + '…' : topItem },
  ]
  const kpiW = W / 3
  kpis.forEach((k, i) => {
    const cx = kpiW * i + kpiW / 2
    pdf.setFont('helvetica', 'bold');   pdf.setFontSize(12); pdf.setTextColor(...GREEN)
    pdf.text(k.value, cx, STRIP_Y + 8.5, { align: 'center' })
    pdf.setFont('helvetica', 'normal'); pdf.setFontSize(7.5); pdf.setTextColor(148, 163, 184)
    pdf.text(k.label, cx, STRIP_Y + 15, { align: 'center' })
    if (i > 0) {
      pdf.setDrawColor(55, 80, 110); pdf.setLineWidth(0.3)
      pdf.line(kpiW * i, STRIP_Y + 4, kpiW * i, STRIP_Y + STRIP_H - 4)
    }
  })

  // ── GRÁFICO (76mm → ~130mm) ──────────────────────────────────────────────────
  // Espacio blanco de ~18mm entre KPI y gráfico (como el ejemplo)
  const CHART_TOP = STRIP_Y + STRIP_H + 18
  let chartBottom = CHART_TOP
  if (chartRef.current) {
    const canvas = await html2canvas(chartRef.current, {
      scale: 2,
      backgroundColor: '#ffffff',
      useCORS: true,
      onclone: (_doc, el) => {
        el.style.background = '#ffffff'
        el.style.borderRadius = '0'
        el.querySelectorAll('.recharts-cartesian-axis-tick text').forEach(t => {
          t.style.fill = '#475569'
        })
      },
    })
    const maxChartH = 54
    const ratio  = canvas.height / canvas.width
    const chartW = W - P * 2
    const chartH = Math.min(chartW * ratio, maxChartH)
    const chartWf= chartH / ratio

    // Caja blanca con borde sutil
    pdf.setFillColor(...WHITE)
    pdf.rect(P - 1, CHART_TOP - 1, W - P * 2 + 2, chartH + 2, 'F')
    pdf.setDrawColor(...GRISL); pdf.setLineWidth(0.3)
    pdf.rect(P - 1, CHART_TOP - 1, W - P * 2 + 2, chartH + 2, 'S')

    pdf.addImage(canvas.toDataURL('image/png'), 'PNG', (W - chartWf) / 2, CHART_TOP, chartWf, chartH)
    chartBottom = CHART_TOP + chartH + 1
  }

  // ── TABLA (fijada al fondo, ~38mm antes del footer) ──────────────────────────
  // Gran espacio blanco entre gráfico y tabla (como el ejemplo)
  const TABLE_BOTTOM = H - 7 - 2
  const TBL_HDR_H = 10
  // La tabla empieza al menos 35mm debajo del gráfico, y no antes de 158mm
  const TBL_Y = Math.max(158, chartBottom + 35)
  const rowArea = TABLE_BOTTOM - TBL_Y - TBL_HDR_H
  const actualRows = Math.min(datos.length, Math.floor(rowArea / 9))
  const ROW_H = actualRows > 0 ? Math.min(20, rowArea / actualRows) : 14

  const COL = {
    num:    P,
    nombre: P + 10,
    uds:    162,
    barX:   168,
    barW:   65,
    pct:    252,
    acum:   W - P,
  }

  // Encabezado tabla
  pdf.setFillColor(...NAVY)
  pdf.rect(P, TBL_Y, W - P * 2, TBL_HDR_H, 'F')
  pdf.setFillColor(...GREEN)
  pdf.rect(P, TBL_Y, 3, TBL_HDR_H, 'F')

  const hdrY = TBL_Y + TBL_HDR_H / 2 + 1.3
  pdf.setFont('helvetica', 'bold'); pdf.setFontSize(7); pdf.setTextColor(...WHITE)
  pdf.text('#',                                               COL.num + 5,  hdrY)
  pdf.text(agrupado === 'producto' ? 'PRODUCTO' : 'DESTINO', COL.nombre,   hdrY)
  pdf.text('UNIDADES',                                        COL.uds,      hdrY, { align: 'right' })
  pdf.text('% DEL TOTAL',                                     COL.pct,      hdrY, { align: 'right' })
  pdf.text('ACUMULADO',                                       COL.acum,     hdrY, { align: 'right' })

  datos.slice(0, actualRows).forEach((row, i) => {
    const y = TBL_Y + TBL_HDR_H + i * ROW_H
    pdf.setFillColor(...(i % 2 === 0 ? FONDO : WHITE))
    pdf.rect(P, y, W - P * 2, ROW_H, 'F')
    if (i < 3) { pdf.setFillColor(...GREEN); pdf.rect(P, y, 3, ROW_H, 'F') }

    const ty = y + ROW_H / 2 + 1.5

    pdf.setFont('helvetica', 'bold'); pdf.setFontSize(7.5)
    pdf.setTextColor(...(i < 3 ? GREEN : GRIS))
    pdf.text(String(i + 1), COL.num + 5, ty)

    const nombre = row.nombre.length > 58 ? row.nombre.slice(0, 58) + '…' : row.nombre
    pdf.setFont('helvetica', i < 3 ? 'bold' : 'normal'); pdf.setFontSize(8)
    pdf.setTextColor(...TEXTO)
    pdf.text(nombre, COL.nombre, ty)

    pdf.setFont('helvetica', 'bold'); pdf.setFontSize(8)
    pdf.setTextColor(...(i < 3 ? GREEN : TEXTO))
    pdf.text(String(row.total), COL.uds, ty, { align: 'right' })

    const bFilled = (row.pct / 100) * COL.barW
    pdf.setFillColor(...GRISL)
    pdf.roundedRect(COL.barX, y + ROW_H / 2 - 1.8, COL.barW, 3.5, 1.7, 1.7, 'F')
    if (bFilled > 0) {
      pdf.setFillColor(...GREEN)
      pdf.roundedRect(COL.barX, y + ROW_H / 2 - 1.8, bFilled, 3.5, 1.7, 1.7, 'F')
    }

    pdf.setFont('helvetica', 'normal'); pdf.setFontSize(7.5); pdf.setTextColor(...GRIS)
    pdf.text(`${row.pct}%`,       COL.pct,  ty, { align: 'right' })
    pdf.text(`${row.acumulado}%`, COL.acum, ty, { align: 'right' })

    pdf.setDrawColor(...GRISL); pdf.setLineWidth(0.2)
    pdf.line(P + 3, y + ROW_H, W - P - 3, y + ROW_H)
  })

  if (datos.length > actualRows) {
    pdf.setFont('helvetica', 'italic'); pdf.setFontSize(6.5); pdf.setTextColor(...GRIS)
    pdf.text(`+ ${datos.length - actualRows} registros adicionales`, P + 5, TABLE_BOTTOM - 2)
  }

  // ── FOOTER ───────────────────────────────────────────────────────────────────
  pdf.setFillColor(...GRISL)
  pdf.rect(0, H - 7, W, 7, 'F')
  pdf.setFillColor(...GREEN)
  pdf.rect(0, H - 7, W, 1.2, 'F')
  pdf.setFont('helvetica', 'normal'); pdf.setFontSize(6.5); pdf.setTextColor(...GRIS)
  pdf.text('Documento generado automáticamente · LH Inventario · La Hornilla', P, H - 2.5)
  pdf.text('Página 1 / 1', W - P, H - 2.5, { align: 'right' })

  pdf.save(`analisis_${agrupado}_${periodo}.pdf`)
}

// ── Componente ─────────────────────────────────────────────────────────────────
export default function Analisis() {
  const [salidas,   setSalidas]   = useState([])
  const [loading,   setLoading]   = useState(true)
  const [periodo,   setPeriodo]   = useState('30')
  const [agrupado,  setAgrupado]  = useState('destino')
  const [busqueda,  setBusqueda]  = useState('')
  const [exporting, setExporting] = useState(false)
  const chartRef = useRef(null)

  useEffect(() => {
    listarSalidas().then(data => {
      setSalidas(Array.isArray(data) ? data : [])
      setLoading(false)
    })
  }, [])

  const filtradas     = filtrarPorPeriodo(salidas, periodo)
  const todosLosDatos = calcularDatos(filtradas, agrupado)
  const datos = busqueda.trim()
    ? todosLosDatos.filter(d => d.nombre.toLowerCase().includes(busqueda.toLowerCase()))
    : todosLosDatos
  const datosGrafico = datos.slice(0, 20)
  const totalUds     = filtradas.reduce((s, i) => s + i.cantidad, 0)

  async function exportarPDF() {
    if (!datos.length) return
    setExporting(true)
    try {
      await generarPDF({ datos, filtradas, agrupado, periodo, chartRef })
    } catch (e) { console.error('PDF', e) }
    setExporting(false)
  }

  return (
    <div className="flex flex-col p-4 md:p-7 gap-4 pb-8">

      {/* Header */}
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <h2 className="text-xl md:text-2xl font-bold text-slate-800 dark:text-white">Análisis</h2>
          <p className="text-slate-500 dark:text-slate-400 text-xs mt-0.5">Consumo de insumos por período</p>
        </div>
        <button onClick={exportarPDF} disabled={exporting || loading || !datos.length}
          className="flex items-center gap-2 px-4 py-2 rounded-lg bg-green-600 hover:bg-green-700
            disabled:opacity-40 disabled:cursor-not-allowed text-white text-sm font-semibold
            transition-colors cursor-pointer shadow-sm">
          <Download size={15} />
          {exporting ? 'Generando PDF...' : 'Exportar PDF'}
        </button>
      </div>

      {/* Filtros */}
      <div className="flex flex-wrap gap-2 items-center">
        <Filter size={14} className="text-slate-400 flex-shrink-0" />
        <div className="flex rounded-lg overflow-hidden border border-slate-200 dark:border-white/10">
          {AGRUPACIONES.map(a => (
            <button key={a.key} onClick={() => { setAgrupado(a.key); setBusqueda('') }}
              className={`px-3 py-1.5 text-xs font-semibold transition-colors cursor-pointer
                ${agrupado === a.key
                  ? 'bg-green-600 text-white'
                  : 'bg-white dark:bg-[#1A2332] text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-white/5'
                }`}>
              {a.label}
            </button>
          ))}
        </div>
        <div className="flex rounded-lg overflow-hidden border border-slate-200 dark:border-white/10">
          {PERIODOS.map(p => (
            <button key={p.key} onClick={() => setPeriodo(p.key)}
              className={`px-3 py-1.5 text-xs font-semibold transition-colors cursor-pointer
                ${periodo === p.key
                  ? 'bg-green-600 text-white'
                  : 'bg-white dark:bg-[#1A2332] text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-white/5'
                }`}>
              {p.label}
            </button>
          ))}
        </div>
        <div className="relative">
          <Search size={13} className="absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-400" />
          <input type="text" placeholder={`Buscar ${agrupado}...`} value={busqueda}
            onChange={e => setBusqueda(e.target.value)}
            className="pl-8 pr-3 py-1.5 rounded-lg border border-slate-200 dark:border-white/10
              bg-white dark:bg-[#1A2332] text-slate-800 dark:text-white text-xs outline-none
              placeholder:text-slate-400 focus:border-green-500 transition-colors w-44" />
        </div>
        {!loading && datos.length > 0 && (
          <span className="text-xs text-slate-400 dark:text-slate-500 ml-1">
            {datos.length} {agrupado === 'producto' ? 'productos' : 'destinos'} ·{' '}
            <strong className="text-slate-600 dark:text-slate-300">{totalUds.toLocaleString('es-CL')}</strong> uds
          </span>
        )}
      </div>

      {/* Gráfico */}
      <div ref={chartRef} className="bg-white dark:bg-[#1A2332] rounded-xl border border-slate-200 dark:border-white/5 p-4 md:p-6">
        {loading ? (
          <div className="h-72 flex items-center justify-center">
            <div className="w-8 h-8 border-2 border-green-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : datosGrafico.length === 0 ? (
          <div className="h-72 flex flex-col items-center justify-center gap-3 text-slate-400 dark:text-slate-500">
            <BarChart2 size={40} strokeWidth={1.2} />
            <p className="text-sm font-medium">Sin datos para los filtros aplicados</p>
          </div>
        ) : (
          <ResponsiveContainer width="100%" height={300}>
            <ComposedChart data={datosGrafico} margin={{ top: 4, right: 48, left: 0, bottom: 64 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(100,116,139,0.12)" />
              <XAxis dataKey="nombre" tick={{ fontSize: 11, fill: 'rgb(148,163,184)' }}
                angle={-38} textAnchor="end" interval={0}
                tickFormatter={v => v.length > 20 ? v.slice(0, 20) + '…' : v} />
              <YAxis yAxisId="left" tick={{ fontSize: 11, fill: 'rgb(148,163,184)' }} width={36}
                tickFormatter={v => v >= 1000 ? `${(v / 1000).toFixed(1)}k` : v} />
              <YAxis yAxisId="right" orientation="right" domain={[0, 100]}
                tick={{ fontSize: 11, fill: 'rgb(148,163,184)' }}
                tickFormatter={v => `${v}%`} width={40} />
              <Tooltip content={<CustomTooltip />} />
              <Legend verticalAlign="top" wrapperStyle={{ fontSize: 12, paddingBottom: 8 }} />
              <Bar yAxisId="left" dataKey="total" name="Unidades pedidas"
                fill="#16a34a" radius={[4, 4, 0, 0]} maxBarSize={48} />
              <Line yAxisId="right" type="monotone" dataKey="acumulado" name="Acumulado %"
                stroke="#f59e0b" strokeWidth={2} dot={false} strokeDasharray="5 3" />
            </ComposedChart>
          </ResponsiveContainer>
        )}
      </div>

      {/* Tabla */}
      {!loading && datos.length > 0 && (
        <div className="bg-white dark:bg-[#1A2332] rounded-xl border border-slate-200 dark:border-white/5 overflow-hidden">
          <div className="px-5 py-3.5 border-b border-slate-100 dark:border-white/5 flex items-center gap-2">
            <BarChart2 size={15} className="text-green-600 dark:text-green-400" />
            <h3 className="font-semibold text-slate-800 dark:text-white text-sm">
              Ranking por {agrupado === 'producto' ? 'producto' : 'destino'}
            </h3>
            <span className="ml-auto text-xs text-slate-400 dark:text-slate-500">{datos.length} registros</span>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="sticky top-0 bg-white dark:bg-[#1A2332]">
                <tr className="border-b border-slate-100 dark:border-white/5 text-xs text-slate-500 dark:text-slate-400 uppercase tracking-wider">
                  <th className="px-4 py-2.5 text-left font-semibold w-10">#</th>
                  <th className="px-4 py-2.5 text-left font-semibold">{agrupado === 'producto' ? 'Producto' : 'Destino'}</th>
                  <th className="px-4 py-2.5 text-center font-semibold">Unidades</th>
                  <th className="px-4 py-2.5 text-center font-semibold">% del total</th>
                  <th className="px-4 py-2.5 text-center font-semibold">Acumulado</th>
                </tr>
              </thead>
              <tbody>
                {datos.map((row, i) => (
                  <tr key={row.nombre}
                    className="border-b border-slate-50 dark:border-white/5 hover:bg-slate-50 dark:hover:bg-white/5 transition-colors">
                    <td className="px-4 py-2.5 text-xs tabular-nums">
                      <span className={i < 3 ? 'font-bold text-green-600 dark:text-green-400' : 'text-slate-400 dark:text-slate-500'}>
                        {i + 1}
                      </span>
                    </td>
                    <td className={`px-4 py-2.5 max-w-[240px] truncate ${i < 3 ? 'font-semibold text-slate-800 dark:text-slate-100' : 'text-slate-700 dark:text-slate-300'}`}>
                      {row.nombre}
                    </td>
                    <td className={`px-4 py-2.5 text-center font-semibold tabular-nums ${i < 3 ? 'text-green-600 dark:text-green-400' : 'text-slate-800 dark:text-slate-200'}`}>
                      {row.total.toLocaleString('es-CL')}
                    </td>
                    <td className="px-4 py-2.5 text-center">
                      <div className="flex items-center justify-center gap-2">
                        <div className="w-16 h-1.5 bg-slate-100 dark:bg-white/10 rounded-full overflow-hidden">
                          <div className="h-full bg-green-500 rounded-full" style={{ width: `${row.pct}%` }} />
                        </div>
                        <span className="text-slate-500 dark:text-slate-400 text-xs tabular-nums w-8 text-left">{row.pct}%</span>
                      </div>
                    </td>
                    <td className="px-4 py-2.5 text-center text-slate-400 dark:text-slate-500 text-xs tabular-nums">{row.acumulado}%</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
