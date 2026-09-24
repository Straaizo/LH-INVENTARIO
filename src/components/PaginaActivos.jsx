import { useEffect, useRef, useState } from 'react'
import { Plus, Edit2, Pencil, Check, Search, X, ChevronLeft, ChevronRight, ChevronUp, ChevronDown, AlertTriangle, Download, Star, SlidersHorizontal } from 'lucide-react'
import toast from 'react-hot-toast'
import { descargarXlsx } from '../utils/excel'

function toInputDate(val) {
  if (typeof val === 'string' && /^\d{2}-\d{2}-\d{4}$/.test(val)) {
    const [d, m, y] = val.split('-')
    return `${y}-${m}-${d}`
  }
  return val || ''
}

function fromInputDate(val) {
  if (typeof val === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(val)) {
    const [y, m, d] = val.split('-')
    return `${d}-${m}-${y}`
  }
  return val
}

function formatCell(val) {
  if (!val) return '—'
  if (/^\d{2}-\d{2}-\d{4}$/.test(String(val))) return val
  if (/^\d{4}-\d{2}-\d{2}/.test(String(val))) {
    const [y, m, d] = String(val).split('T')[0].split('-')
    return `${d}-${m}-${y}`
  }
  return val
}

// ── Estado badge ──────────────────────────────────────────────────────────────
const ESTADO_CFG = {
  'Activo':        { dot: 'bg-green-500',  badge: 'bg-green-100  text-green-800  border-green-200  dark:bg-green-500/20  dark:text-green-400  dark:border-green-500/30'  },
  'Asignado':      { dot: 'bg-green-500',  badge: 'bg-green-100  text-green-800  border-green-200  dark:bg-green-500/20  dark:text-green-400  dark:border-green-500/30'  },
  'Disponible':    { icon: Star, iconClass: 'fill-yellow-400 text-yellow-400', badge: 'bg-yellow-50 text-yellow-800 border-yellow-200 dark:bg-yellow-500/10 dark:text-yellow-300 dark:border-yellow-500/30' },
  'En reparación': { dot: 'bg-orange-500', badge: 'bg-orange-100 text-orange-800 border-orange-200 dark:bg-orange-500/20 dark:text-orange-400 dark:border-orange-500/30' },
  'En revisión':   { dot: 'bg-blue-500',   badge: 'bg-blue-100   text-blue-800   border-blue-200   dark:bg-blue-500/20   dark:text-blue-400   dark:border-blue-500/30'   },
  'De baja':       { dot: 'bg-slate-400',  badge: 'bg-slate-100  text-slate-600  border-slate-200  dark:bg-slate-500/20  dark:text-slate-400  dark:border-slate-500/30'  },
  'Inactivo':      { dot: 'bg-slate-400',  badge: 'bg-slate-100  text-slate-600  border-slate-200  dark:bg-slate-500/20  dark:text-slate-400  dark:border-slate-500/30'  },
  'Robado':        { dot: 'bg-yellow-500', badge: 'bg-yellow-100 text-yellow-800 border-yellow-200 dark:bg-yellow-500/20 dark:text-yellow-400 dark:border-yellow-500/30' },
}
const ESTADO_DEFAULT = { dot: 'bg-slate-400', badge: 'bg-slate-100 text-slate-600 border-slate-200 dark:bg-slate-500/20 dark:text-slate-400 dark:border-slate-500/30' }

export function EstadoBadge({ estado }) {
  const c = ESTADO_CFG[estado] || ESTADO_DEFAULT
  return (
    <span style={{ minWidth: '7.5rem' }} className={`inline-flex items-center justify-center gap-1.5 text-xs py-0.5 rounded-full border font-semibold ${c.badge}`}>
      {c.icon
        ? <c.icon size={11} strokeWidth={1.5} className={`flex-shrink-0 ${c.iconClass}`} />
        : <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${c.dot}`} />}
      {estado || '—'}
    </span>
  )
}

// ── Skeleton loader ───────────────────────────────────────────────────────────
const SKEL_WIDTHS = ['55%', '80%', '65%', '90%', '70%']

function SkeletonRows({ cols }) {
  return (
    <>
      {[0, 1, 2, 3, 4].map(i => (
        <tr key={i} className="border-b border-slate-100 dark:border-white/5">
          {Array.from({ length: cols }, (_, j) => (
            <td key={j} className="px-4 py-3.5">
              <div className="h-3.5 rounded animate-pulse bg-slate-200 dark:bg-white/10"
                style={{ width: SKEL_WIDTHS[(i + j) % SKEL_WIDTHS.length] }} />
            </td>
          ))}
        </tr>
      ))}
    </>
  )
}

const PAGE_SIZE = 15

// ── Main component ─────────────────────────────────────────────────────────────
export default function PaginaActivos({
  titulo, subtitulo, icono: Icono, api,
  columnas,
  campos       = [],
  pasos        = null,
  campoId      = null,
  filtros      = [],
  ModalFormulario = null,
}) {
  const [items,    setItems]    = useState([])
  const [loading,  setLoading]  = useState(true)
  const [busqueda, setBusqueda] = useState('')
  const [page,     setPage]     = useState(1)
  const [detalle,  setDetalle]  = useState(null)
  const [modal,    setModal]    = useState(null)
  const [sortDir,  setSortDir]  = useState(null) // null | 'asc' | 'desc'
  const [filtrosActivos, setFiltrosActivos] = useState({}) // { key: Set(valores) }
  const [panelFiltros,   setPanelFiltros]   = useState(false)
  const filtroRef = useRef(null)

  async function cargar() {
    setLoading(true)
    const data = await api.listar()
    setItems(Array.isArray(data) ? data : [])
    setLoading(false)
  }

  useEffect(() => { cargar() }, [])

  // Escape para cerrar modales / panel de filtros
  useEffect(() => {
    function onKey(e) {
      if (e.key !== 'Escape') return
      if (panelFiltros)   { setPanelFiltros(false); return }
      if (modal)          { setModal(null);   return }
      if (detalle)        { setDetalle(null); return }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [panelFiltros, modal, detalle])

  // Cerrar panel de filtros al hacer click afuera
  useEffect(() => {
    if (!panelFiltros) return
    function onClickFuera(e) { if (filtroRef.current && !filtroRef.current.contains(e.target)) setPanelFiltros(false) }
    document.addEventListener('mousedown', onClickFuera)
    return () => document.removeEventListener('mousedown', onClickFuera)
  }, [panelFiltros])

  const camposBusqueda = campos.length ? campos : columnas

  const porBusqueda = busqueda.trim()
    ? items.filter(item =>
        camposBusqueda.some(col => {
          const v = item[col.key]
          return v && String(v).toLowerCase().includes(busqueda.toLowerCase())
        })
      )
    : items

  const totalFiltrosActivos = Object.values(filtrosActivos).reduce((sum, set) => sum + (set?.size || 0), 0)

  const filtrados = totalFiltrosActivos > 0
    ? porBusqueda.filter(item =>
        Object.entries(filtrosActivos).every(([key, valores]) =>
          !valores || valores.size === 0 || valores.has(String(item[key] ?? ''))
        )
      )
    : porBusqueda

  function opcionesFiltro(key) {
    const estadoCampo = key === 'estado' ? campos.find(c => c.key === 'estado') : null
    const universo = estadoCampo?.opciones
      ? estadoCampo.opciones.map(o => o.value)
      : [...new Set(items.map(i => i[key]).filter(Boolean))]
          .sort((a, b) => String(a).localeCompare(String(b), undefined, { numeric: true, sensitivity: 'base' }))
    return universo.map(valor => ({
      valor,
      count: porBusqueda.filter(i => String(i[key] ?? '') === String(valor)).length,
    }))
  }

  function toggleValorFiltro(key, valor) {
    setFiltrosActivos(prev => {
      const next = { ...prev }
      const set  = new Set(next[key] || [])
      if (set.has(valor)) set.delete(valor)
      else set.add(valor)
      next[key] = set
      return next
    })
    setPage(1)
  }

  function limpiarFiltros() {
    setFiltrosActivos({})
    setPage(1)
  }

  const ordenados = sortDir
    ? [...filtrados].sort((a, b) => {
        const cmp = String(a[campoId] ?? '').localeCompare(String(b[campoId] ?? ''), undefined, { numeric: true, sensitivity: 'base' })
        return sortDir === 'asc' ? cmp : -cmp
      })
    : filtrados

  function toggleSort(colKey) {
    if (colKey !== campoId) return
    setSortDir(d => d === 'desc' ? 'asc' : 'desc')
    setPage(1)
  }

  useEffect(() => { setPage(1) }, [busqueda])

  const totalPages = Math.max(1, Math.ceil(ordenados.length / PAGE_SIZE))
  const safePage   = Math.min(page, totalPages)
  const paginados  = ordenados.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE)

  function abrirFormulario(mode, item = null) {
    setDetalle(null)
    setModal({ mode, item })
  }

  async function exportar() {
    if (!items.length) return
    const hoy = new Date().toISOString().slice(0, 10)
    const camposExport = campos.length ? campos : columnas
    const filas = [
      camposExport.map(c => c.label),
      ...ordenados.map(item => camposExport.map(c => item[c.key] ?? '')),
    ]
    await descargarXlsx(filas, `${titulo.toLowerCase()}_${hoy}.xlsx`)
  }

  const hayBusquedaOFiltros = !!busqueda.trim() || totalFiltrosActivos > 0

  const contadorTexto = hayBusquedaOFiltros
    ? `${filtrados.length} de ${items.length} ${titulo.toLowerCase()}`
    : `${items.length} ${titulo.toLowerCase()}`

  return (
    <div className="flex flex-col h-full p-4 md:p-7 gap-4">

      <div>
        <h2 className="text-xl md:text-2xl font-bold text-slate-800 dark:text-white">{titulo}</h2>
        <p className="text-slate-500 dark:text-slate-400 text-xs mt-0.5">{subtitulo}</p>
      </div>

      {/* Búsqueda + botones */}
      <div className="flex items-center gap-2">
        <div className="flex-1 relative">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-500" />
          <input type="text" placeholder="Buscar…" value={busqueda}
            onChange={e => setBusqueda(e.target.value)}
            className="w-full pl-8 pr-4 py-2 rounded-lg text-sm outline-none transition-colors
              text-slate-800 dark:text-white bg-white dark:bg-[#1A2332]
              border border-slate-200 dark:border-white/10
              placeholder:text-slate-400 dark:placeholder:text-slate-500
              focus:border-green-500 dark:focus:border-green-500" />
        </div>
        {!loading && (
          <span className="hidden sm:block text-xs text-slate-400 dark:text-slate-500 whitespace-nowrap tabular-nums">
            {contadorTexto}
          </span>
        )}
        <div className="flex gap-2 flex-shrink-0">
          {filtros.length > 0 && (
            <div className="relative" ref={filtroRef}>
              <button onClick={() => setPanelFiltros(p => !p)}
                className={`flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors cursor-pointer
                  ${totalFiltrosActivos > 0
                    ? 'bg-green-600 hover:bg-green-700 text-white'
                    : 'bg-slate-200 hover:bg-slate-300 dark:bg-white/10 dark:hover:bg-white/15 text-slate-700 dark:text-white'}`}>
                <SlidersHorizontal size={15} />
                <span className="hidden sm:inline">Filtros</span>
                {totalFiltrosActivos > 0 && (
                  <span className="flex items-center justify-center min-w-[18px] h-[18px] px-1 rounded-full bg-white/25 text-[10px] font-bold">
                    {totalFiltrosActivos}
                  </span>
                )}
              </button>
              {panelFiltros && (
                <div className="absolute right-0 mt-2 z-30 w-72 max-h-[26rem] overflow-y-auto rounded-xl border border-slate-200 dark:border-white/10 bg-white dark:bg-[#1A2332] shadow-2xl p-4">
                  <div className="flex items-center justify-between mb-3">
                    <p className="text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wide">Filtrar por</p>
                    {totalFiltrosActivos > 0 && (
                      <button onClick={limpiarFiltros}
                        className="text-xs text-green-600 dark:text-green-400 hover:underline cursor-pointer">
                        Limpiar
                      </button>
                    )}
                  </div>
                  <div className="flex flex-col gap-4">
                    {filtros.map(f => {
                      const opciones = opcionesFiltro(f.key)
                      if (!opciones.length) return null
                      return (
                        <div key={f.key}>
                          <p className="text-[11px] font-semibold text-slate-400 dark:text-slate-500 uppercase tracking-wide mb-1.5">{f.label}</p>
                          <div className="flex flex-wrap gap-1.5">
                            {opciones.map(o => {
                              const activo = !!filtrosActivos[f.key]?.has(o.valor)
                              return (
                                <button key={o.valor} onClick={() => toggleValorFiltro(f.key, o.valor)}
                                  className={`px-2.5 py-1 rounded-full text-xs font-medium border transition-colors cursor-pointer
                                    ${activo
                                      ? 'bg-green-600 border-green-600 text-white'
                                      : 'bg-transparent border-slate-200 dark:border-white/10 text-slate-600 dark:text-slate-300 hover:border-green-400 dark:hover:border-green-500/50'}`}>
                                  {o.valor}{' '}
                                  <span className={activo ? 'text-white/70' : 'text-slate-400 dark:text-slate-500'}>({o.count})</span>
                                </button>
                              )
                            })}
                          </div>
                        </div>
                      )
                    })}
                  </div>
                </div>
              )}
            </div>
          )}
          <button onClick={exportar} disabled={!items.length}
            className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-slate-200 hover:bg-slate-300 dark:bg-white/10 dark:hover:bg-white/15 text-slate-700 dark:text-white text-sm font-medium transition-colors disabled:opacity-40 cursor-pointer disabled:cursor-not-allowed">
            <Download size={15} /> <span className="hidden sm:inline">Excel</span>
          </button>
          <button onClick={() => abrirFormulario('nuevo')}
            className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-green-600 hover:bg-green-700 text-white text-sm font-medium transition-colors cursor-pointer">
            <Plus size={15} /> <span className="hidden sm:inline">Nuevo</span>
          </button>
        </div>
      </div>

      <div className="flex-1 flex flex-col rounded-xl border border-slate-200 dark:border-white/5 overflow-hidden min-h-0 bg-white dark:bg-[#1A2332]">

        {/* Tabla (con skeleton o datos) */}
        <div className="flex-1 min-h-0 overflow-x-auto overflow-y-auto">
          <table className="w-full text-sm text-left" style={{ minWidth: 600 }}>
            <thead className="text-slate-500 dark:text-slate-400 text-xs uppercase border-b border-slate-200 dark:border-white/5 sticky top-0 bg-white dark:bg-[#1A2332]">
              <tr>
                {columnas.map(col => (
                  <th key={col.key} className="px-4 py-3 font-semibold whitespace-nowrap">
                    {col.key === campoId ? (
                      <span onClick={() => toggleSort(col.key)}
                        className="inline-flex items-center gap-1 cursor-pointer select-none hover:text-slate-700 dark:hover:text-slate-200 transition-colors">
                        {col.label}
                        {sortDir === 'asc' && <ChevronUp size={13} />}
                        {sortDir === 'desc' && <ChevronDown size={13} />}
                      </span>
                    ) : col.label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <SkeletonRows cols={columnas.length} />
              ) : filtrados.length === 0 ? (
                <tr>
                  <td colSpan={columnas.length}>
                    <div className="flex flex-col items-center justify-center py-16 gap-3 text-slate-400 dark:text-slate-500">
                      <div className="w-16 h-16 rounded-2xl bg-slate-100 dark:bg-white/5 flex items-center justify-center">
                        <Icono size={32} strokeWidth={1.3} />
                      </div>
                      <div className="text-center">
                        <p className="text-sm font-medium">
                          {busqueda ? `Sin resultados para "${busqueda}"` : hayBusquedaOFiltros ? 'Sin resultados para estos filtros' : `Sin ${titulo.toLowerCase()} registrados`}
                        </p>
                        {!hayBusquedaOFiltros && <p className="text-xs mt-0.5 text-slate-300 dark:text-white/20">Usá el botón Nuevo para agregar el primero</p>}
                      </div>
                    </div>
                  </td>
                </tr>
              ) : (
                paginados.map(item => (
                  <tr key={item.id}
                    onClick={() => setDetalle(item)}
                    className="border-b border-slate-100 dark:border-white/5 hover:bg-slate-50 dark:hover:bg-white/5 transition-colors cursor-pointer select-none">
                    {columnas.map(col => (
                      <td key={col.key} className={`px-4 py-3 text-slate-700 dark:text-slate-300 ${col.truncate ? 'max-w-[140px] truncate' : 'whitespace-nowrap'}`}>
                        {col.render ? col.render(item[col.key], item) : formatCell(item[col.key])}
                      </td>
                    ))}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Paginación */}
        {!loading && filtrados.length > PAGE_SIZE && (
          <div className="flex items-center justify-between px-4 py-2.5 border-t border-slate-200 dark:border-white/5 flex-shrink-0">
            <span className="text-xs text-slate-400 dark:text-slate-500 tabular-nums">
              {(safePage - 1) * PAGE_SIZE + 1}–{Math.min(safePage * PAGE_SIZE, filtrados.length)} de {filtrados.length}
            </span>
            <div className="flex gap-1">
              <button disabled={safePage === 1} onClick={() => setPage(p => p - 1)}
                className="p-1.5 rounded transition-colors disabled:opacity-30 disabled:cursor-not-allowed hover:bg-slate-100 dark:hover:bg-white/10 cursor-pointer">
                <ChevronLeft size={16} className="text-slate-600 dark:text-slate-400" />
              </button>
              <button disabled={safePage >= totalPages} onClick={() => setPage(p => p + 1)}
                className="p-1.5 rounded transition-colors disabled:opacity-30 disabled:cursor-not-allowed hover:bg-slate-100 dark:hover:bg-white/10 cursor-pointer">
                <ChevronRight size={16} className="text-slate-600 dark:text-slate-400" />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Detalle */}
      {detalle && (
        <ModalDetalle
          item={detalle}
          campos={campos.length ? campos : columnas}
          campoId={campoId || columnas[0]?.key}
          titulo={titulo}
          api={api}
          onClose={() => setDetalle(null)}
          onEdit={() => abrirFormulario('editar', detalle)}
          onEstadoActualizado={nuevoEstado => { setDetalle(d => ({ ...d, estado: nuevoEstado })); cargar() }}
        />
      )}

      {/* Formulario */}
      {modal && (
        pasos
          ? <ModalWizard
              mode={modal.mode} item={modal.item}
              campos={campos} pasos={pasos} api={api} titulo={titulo}
              onClose={() => setModal(null)}
              onExito={() => { setModal(null); cargar() }}
            />
          : ModalFormulario && (
              <ModalFormulario
                mode={modal.mode} item={modal.item} api={api}
                onClose={() => setModal(null)}
                onExito={() => { setModal(null); cargar() }}
              />
            )
      )}
    </div>
  )
}

// ── Modal detalle ─────────────────────────────────────────────────────────────
function ModalDetalle({ item, campos, campoId, titulo, api, onClose, onEdit, onEstadoActualizado }) {
  const idValue = item[campoId] || `#${item.id}`
  const camposSinEstado = campos.filter(c => c.key !== 'estado' && c.key !== campoId)
  const estadoCampo = campos.find(c => c.key === 'estado')

  const [editandoEstado, setEditandoEstado] = useState(false)
  const [nuevoEstado,    setNuevoEstado]    = useState(item.estado || '')
  const [guardandoEstado, setGuardandoEstado] = useState(false)

  useEffect(() => {
    function onKey(e) { if (e.key === 'Escape') onClose() }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  async function guardarEstado() {
    if (nuevoEstado === item.estado) { setEditandoEstado(false); return }
    setGuardandoEstado(true)
    const res = await api.actualizar(item.id, { estado: nuevoEstado })
    setGuardandoEstado(false)
    if (res.ok) {
      toast.success('Estado actualizado')
      setEditandoEstado(false)
      onEstadoActualizado?.(nuevoEstado)
    } else {
      toast.error(res.message || 'Error al actualizar el estado')
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="bg-white dark:bg-[#1A2332] rounded-2xl w-full max-w-lg shadow-2xl max-h-[90vh] flex flex-col">
        <div className="flex items-start justify-between p-6 border-b border-gray-100 dark:border-white/5 flex-shrink-0">
          <div>
            <p className="text-[11px] text-gray-400 dark:text-slate-500 font-semibold uppercase tracking-widest mb-1">{titulo}</p>
            <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-2">{idValue}</h2>
            {editandoEstado ? (
              <div className="flex items-center gap-1.5">
                <select value={nuevoEstado} onChange={e => setNuevoEstado(e.target.value)} autoFocus
                  className="px-2 py-1.5 rounded-lg text-xs font-medium outline-none border border-gray-200 dark:border-white/10 bg-white dark:bg-[#1E2C3D] text-gray-700 dark:text-slate-200 focus:border-green-500 dark:[color-scheme:dark]">
                  {estadoCampo.opciones.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
                </select>
                <button onClick={guardarEstado} disabled={guardandoEstado} title="Guardar estado"
                  className="p-1.5 rounded-lg text-green-600 dark:text-green-400 hover:bg-green-50 dark:hover:bg-green-500/10 cursor-pointer disabled:opacity-50">
                  <Check size={19} />
                </button>
                <button onClick={() => setEditandoEstado(false)} disabled={guardandoEstado} title="Cancelar"
                  className="p-1.5 rounded-lg text-red-500 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-500/10 cursor-pointer">
                  <X size={19} />
                </button>
              </div>
            ) : (
              item.estado && (
                <div className="flex items-center gap-1.5">
                  <EstadoBadge estado={item.estado} />
                  {estadoCampo?.opciones && (
                    <button onClick={() => { setNuevoEstado(item.estado); setEditandoEstado(true) }} title="Cambiar estado"
                      className="p-1 rounded text-gray-400 dark:text-slate-500 hover:text-green-600 dark:hover:text-green-400 hover:bg-gray-100 dark:hover:bg-white/5 cursor-pointer transition-colors">
                      <Pencil size={17} />
                    </button>
                  )}
                </div>
              )
            )}
          </div>
          <button onClick={onClose} className="text-gray-400 dark:text-slate-500 hover:text-gray-600 dark:hover:text-slate-300 cursor-pointer mt-1">
            <X size={22} />
          </button>
        </div>
        <div className="overflow-y-auto flex-1 p-6">
          <div className="grid grid-cols-2 gap-x-8 gap-y-4">
            {camposSinEstado.map(c => {
              const val = item[c.key]
              if (!val) return null
              return (
                <div key={c.key} className={c.fullWidth ? 'col-span-2' : ''}>
                  <p className="text-[10px] font-bold text-gray-400 dark:text-slate-500 uppercase tracking-wider mb-0.5">{c.label}</p>
                  <p className="text-sm font-medium text-gray-800 dark:text-slate-200 break-words">{c.render ? c.render(val) : formatCell(val)}</p>
                </div>
              )
            })}
          </div>
        </div>
        <div className="flex gap-3 p-5 border-t border-gray-100 dark:border-white/5 flex-shrink-0">
          <button onClick={onEdit}
            className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl border-2 border-green-500 text-green-700 dark:text-green-400 text-sm font-semibold hover:bg-green-50 dark:hover:bg-green-500/10 transition-colors cursor-pointer">
            <Edit2 size={15} /> Editar
          </button>
        </div>
      </div>
    </div>
  )
}

// ── Wizard por pasos ──────────────────────────────────────────────────────────
function ModalWizard({ mode, item, campos, pasos, api, titulo, onClose, onExito }) {
  const isDateF = c => !c.opciones && c.key.toLowerCase().includes('fecha')
  const initial = {}
  for (const c of campos) {
    const raw = item?.[c.key] != null
      ? String(item[c.key])
      : (c.defaultValue ?? (c.opciones?.[0]?.value ?? ''))
    initial[c.key] = isDateF(c) ? toInputDate(raw) : raw
  }

  const [form,         setForm]         = useState(initial)
  const [step,         setStep]         = useState(0)
  const [errores,      setErrores]      = useState({})
  const [guardando,    setGuardando]    = useState(false)
  const [error,        setError]        = useState(null)
  const [confirmClose, setConfirmClose] = useState(false)

  const isDirty = Object.keys(initial).some(k => form[k] !== initial[k])

  function handleClose() {
    if (isDirty) setConfirmClose(true)
    else onClose()
  }

  const total      = pasos.length
  const pasoActual = pasos[step]
  const camposPaso = campos.filter(c => pasoActual.campos.includes(c.key))

  function setField(key, val) {
    setForm(f => ({ ...f, [key]: val }))
    setErrores(e => { const n = { ...e }; delete n[key]; return n })
    setError(null)
  }

  function validarPaso() {
    const nuevos = {}
    for (const c of camposPaso) {
      if (!c.opciones && !c.opcional && !form[c.key]?.trim()) {
        nuevos[c.key] = 'Requerido'
      }
    }
    setErrores(nuevos)
    return Object.keys(nuevos).length === 0
  }

  function avanzar() {
    if (validarPaso()) setStep(s => s + 1)
  }

  async function guardar() {
    if (!validarPaso()) return
    setGuardando(true); setError(null)
    const body = {}
    for (const c of campos) {
      const val = form[c.key]
      body[c.apiKey || c.key] = c.tipo === 'number' ? Number(val) : (isDateF(c) ? fromInputDate(val) : val)
    }
    const res = mode === 'nuevo' ? await api.crear(body) : await api.actualizar(item.id, body)
    setGuardando(false)
    if (res.ok) {
      toast.success(mode === 'nuevo' ? 'Guardado correctamente' : 'Actualizado correctamente')
      onExito()
    } else {
      setError(res.message)
    }
  }

  const inputBase  = 'w-full px-3 py-2.5 rounded-xl text-sm outline-none transition-all bg-white dark:bg-white/5 text-gray-700 dark:text-slate-200 focus:ring-1'
  const selectBase = 'w-full px-3 py-2.5 rounded-xl text-sm outline-none transition-all bg-white dark:bg-[#1E2C3D] text-gray-700 dark:text-slate-200 focus:ring-1 dark:[color-scheme:dark]'
  const inputOk    = 'border border-gray-200 dark:border-white/10 focus:border-green-500 dark:focus:border-green-500 focus:ring-green-200 dark:focus:ring-green-500/20'
  const inputErr   = 'border border-red-400 dark:border-red-500 focus:border-red-400 focus:ring-red-200 dark:focus:ring-red-500/20'

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="relative bg-white dark:bg-[#1A2332] rounded-2xl w-full max-w-md shadow-2xl max-h-[90vh] flex flex-col overflow-hidden">

        {/* Encabezado */}
        <div className="px-6 pt-6 pb-4 border-b border-gray-100 dark:border-white/5 flex-shrink-0">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[11px] font-bold text-gray-400 dark:text-slate-500 uppercase tracking-widest">
              Paso {step + 1} de {total}
            </span>
            <button onClick={handleClose} className="text-gray-400 dark:text-slate-500 hover:text-gray-600 dark:hover:text-slate-300 cursor-pointer">
              <X size={20} />
            </button>
          </div>
          <h3 className="text-lg font-bold text-gray-800 dark:text-white mb-3">{pasoActual.titulo}</h3>
          <div className="flex gap-1.5">
            {pasos.map((_, i) => (
              <div key={i} className={`h-1.5 flex-1 rounded-full transition-all duration-300
                ${i < step ? 'bg-green-500' : i === step ? 'bg-green-400' : 'bg-gray-200 dark:bg-white/10'}`} />
            ))}
          </div>
        </div>

        {/* Campos */}
        <div className="px-6 py-5 grid grid-cols-2 gap-3 overflow-y-auto flex-1">
          {camposPaso.map(c => {
            const isDate = !c.opciones && c.key.toLowerCase().includes('fecha')
            const hasErr = !!errores[c.key]
            return (
              <div key={c.key} className={c.fullWidth ? 'col-span-2' : ''}>
                <label className="text-xs font-semibold text-gray-500 dark:text-slate-400 uppercase tracking-wide mb-1.5 block">
                  {c.label}{!c.opciones && !c.opcional && <span className="text-red-400 ml-0.5">*</span>}
                </label>
                {c.opciones ? (
                  <select value={form[c.key]} onChange={e => setField(c.key, e.target.value)}
                    className={`${selectBase} ${inputOk}`}>
                    {c.opciones.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
                  </select>
                ) : (
                  <input
                    type={c.tipo === 'number' ? 'number' : isDate ? 'date' : 'text'}
                    value={form[c.key]}
                    onChange={e => setField(c.key, e.target.value)}
                    className={`${inputBase} ${hasErr ? inputErr : inputOk}`} />
                )}
                {hasErr && <p className="text-red-500 text-[11px] mt-1">{errores[c.key]}</p>}
              </div>
            )
          })}
          {error && <p className="col-span-2 text-red-500 text-sm mt-1">{error}</p>}
        </div>

        {/* Confirmar descarte */}
        {confirmClose && (
          <div className="absolute inset-0 z-10 flex items-center justify-center bg-black/50 rounded-2xl">
            <div className="bg-white dark:bg-[#1E2C3D] rounded-xl p-5 w-72 shadow-2xl mx-4">
              <div className="flex items-center gap-3 mb-3">
                <AlertTriangle size={18} className="text-orange-500 flex-shrink-0" />
                <p className="font-semibold text-gray-800 dark:text-white text-sm">¿Descartar cambios?</p>
              </div>
              <p className="text-gray-500 dark:text-slate-400 text-xs mb-4">Los datos ingresados se perderán.</p>
              <div className="flex gap-2">
                <button onClick={() => setConfirmClose(false)}
                  className="flex-1 py-2 border border-gray-300 dark:border-white/10 rounded-lg text-gray-700 dark:text-slate-300 text-xs font-medium hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer">
                  Seguir editando
                </button>
                <button onClick={onClose}
                  className="flex-1 py-2 bg-red-500 hover:bg-red-600 rounded-lg text-white text-xs font-semibold cursor-pointer">
                  Descartar
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Navegación */}
        <div className="flex gap-3 px-6 pb-6 flex-shrink-0 border-t border-gray-100 dark:border-white/5 pt-4">
          {step > 0 ? (
            <button onClick={() => setStep(s => s - 1)}
              className="flex items-center gap-1.5 px-4 py-2.5 border border-gray-300 dark:border-white/10 rounded-xl text-gray-700 dark:text-slate-300 text-sm font-medium hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer transition-colors">
              <ChevronLeft size={16} /> Anterior
            </button>
          ) : (
            <button onClick={handleClose}
              className="px-4 py-2.5 border border-gray-300 dark:border-white/10 rounded-xl text-gray-700 dark:text-slate-300 text-sm font-medium hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer transition-colors">
              Cancelar
            </button>
          )}
          {step < total - 1 ? (
            <button onClick={avanzar}
              className="flex-1 flex items-center justify-center gap-1.5 py-2.5 bg-green-600 hover:bg-green-700 rounded-xl text-white text-sm font-semibold cursor-pointer transition-colors">
              Siguiente <ChevronRight size={16} />
            </button>
          ) : (
            <button onClick={guardar} disabled={guardando}
              className="flex-1 py-2.5 bg-green-600 hover:bg-green-700 disabled:opacity-60 rounded-xl text-white text-sm font-semibold cursor-pointer transition-colors">
              {guardando
                ? <span className="flex items-center justify-center gap-2"><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /></span>
                : mode === 'nuevo' ? 'Guardar' : 'Actualizar'}
            </button>
          )}
        </div>
      </div>
    </div>
  )
}

// ── ModalGenerico (backward compat) ──────────────────────────────────────────
export function ModalGenerico({ titulo, campos, item, api, mode, onClose, onExito }) {
  const initial = {}
  for (const c of campos) initial[c.key] = item?.[c.key] != null ? String(item[c.key]) : (c.defaultValue ?? '')
  const [form,      setForm]      = useState(initial)
  const [guardando, setGuardando] = useState(false)
  const [error,     setError]     = useState(null)

  async function guardar() {
    setGuardando(true); setError(null)
    const body = {}
    for (const c of campos) body[c.apiKey || c.key] = c.tipo === 'number' ? Number(form[c.key]) : form[c.key]
    const res = mode === 'nuevo' ? await api.crear(body) : await api.actualizar(item.id, body)
    setGuardando(false)
    if (res.ok) {
      toast.success(mode === 'nuevo' ? 'Guardado correctamente' : 'Actualizado correctamente')
      onExito()
    } else {
      setError(res.message)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="bg-white dark:bg-[#1A2332] rounded-xl w-full max-w-md shadow-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between p-5 border-b border-gray-100 dark:border-white/5">
          <h3 className="font-bold text-gray-800 dark:text-white">{mode === 'nuevo' ? `Nuevo ${titulo}` : `Editar ${titulo}`}</h3>
          <button onClick={onClose} className="text-gray-400 dark:text-slate-500 hover:text-gray-600 dark:hover:text-slate-300 cursor-pointer"><X size={20} /></button>
        </div>
        <div className="p-5 grid grid-cols-2 gap-3">
          {campos.map(c => (
            <div key={c.key} className={c.fullWidth ? 'col-span-2' : ''}>
              <label className="text-xs font-semibold text-gray-500 dark:text-slate-400 uppercase tracking-wide mb-1 block">{c.label}</label>
              {c.opciones ? (
                <select value={form[c.key]} onChange={e => setForm({ ...form, [c.key]: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-200 dark:border-white/10 rounded-lg text-sm text-gray-700 dark:text-slate-200 bg-white dark:bg-[#1E2C3D] outline-none focus:border-green-500 dark:focus:border-green-500 dark:[color-scheme:dark]">
                  {c.opciones.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
                </select>
              ) : (
                <input type={c.tipo === 'number' ? 'number' : 'text'} value={form[c.key]}
                  onChange={e => setForm({ ...form, [c.key]: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-200 dark:border-white/10 rounded-lg text-sm text-gray-700 dark:text-slate-200 bg-white dark:bg-white/5 outline-none focus:border-green-500 dark:focus:border-green-500" />
              )}
            </div>
          ))}
          {error && <p className="col-span-2 text-red-500 text-sm">{error}</p>}
          <div className="col-span-2 flex gap-3 pt-1">
            <button onClick={onClose} className="flex-1 py-2.5 border border-gray-300 dark:border-white/10 rounded-lg text-gray-700 dark:text-slate-300 text-sm hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer">Cancelar</button>
            <button onClick={guardar} disabled={guardando}
              className="flex-1 py-2.5 bg-green-600 hover:bg-green-700 disabled:opacity-60 rounded-lg text-white text-sm font-semibold cursor-pointer">
              {guardando ? <span className="flex items-center justify-center gap-2"><span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /></span> : 'Guardar'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
