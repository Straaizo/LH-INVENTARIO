import { useEffect, useState } from 'react'
import { Download, Plus, Edit2, Trash2, PackageOpen, X, AlertTriangle, RefreshCw, ChevronLeft, ChevronRight, Search } from 'lucide-react'
import toast from 'react-hot-toast'
import { listarSalidas, registrarSalida, actualizarMovimiento, eliminarMovimiento } from '../services/movimientosApi'
import { listarStock } from '../services/inventarioApi'
import { listarDestinos, listarTiposMovimiento, idParaSalida } from '../services/catalogosApi'
import { mapaNombresParaMostrarPorId } from '../services/authApi'
import { descargarCsv, formatearFechahora } from '../utils/csv'

const PAGE_SIZE = 10

const SKEL_W = ['60%', '40%', '75%', '35%', '20%']
function SkeletonRows({ cols }) {
  return (
    <>
      {[0,1,2,3,4].map(i => (
        <tr key={i} className="border-b border-slate-100 dark:border-white/5">
          {Array.from({ length: cols }, (_, j) => (
            <td key={j} className="px-4 py-3.5">
              <div className="h-3.5 rounded animate-pulse bg-slate-200 dark:bg-white/10"
                style={{ width: SKEL_W[(i + j) % SKEL_W.length] }} />
            </td>
          ))}
        </tr>
      ))}
    </>
  )
}

function claveGrupo(mov) {
  const d = new Date(mov.fecha)
  if (isNaN(d)) return `${mov.fecha}|${mov.nombreDestino}`
  return `${d.getFullYear()}-${d.getMonth()}-${d.getDate()} ${d.getHours()}:${d.getMinutes()}|${mov.nombreDestino}`
}

export default function Salida() {
  const [salidas,  setSalidas]  = useState([])
  const [loading,  setLoading]  = useState(true)
  const [nombres,  setNombres]  = useState({})
  const [modal,    setModal]    = useState(null)
  const [confirm,  setConfirm]  = useState(null)
  const [busqueda, setBusqueda] = useState('')
  const [page,     setPage]     = useState(1)

  async function cargar() {
    setLoading(true)
    const [lista, mapa] = await Promise.all([listarSalidas(), mapaNombresParaMostrarPorId()])
    setSalidas(lista); setNombres(mapa); setLoading(false)
  }

  useEffect(() => { cargar() }, [])
  useEffect(() => { setPage(1) }, [busqueda])

  function getNombreUsuario(mov) {
    if (mov.idUsuario) { const n = nombres[mov.idUsuario]; if (n) return n }
    return mov.usuarioNombre?.trim() || ''
  }

  const grupos = (() => {
    const map = {}
    for (const m of salidas) {
      const k = claveGrupo(m)
      if (!map[k]) map[k] = []
      map[k].push(m)
    }
    return Object.values(map).sort((a, b) => new Date(b[0].fecha) - new Date(a[0].fecha))
  })()

  const gruposFiltrados = grupos.filter(g => {
    if (!busqueda) return true
    const q = busqueda.toLowerCase()
    return g[0].nombreDestino?.toLowerCase().includes(q) ||
      g.some(m => m.nombreProducto?.toLowerCase().includes(q)) ||
      getNombreUsuario(g[0]).toLowerCase().includes(q)
  })
  const totalPages   = Math.max(1, Math.ceil(gruposFiltrados.length / PAGE_SIZE))
  const safePage     = Math.min(page, totalPages)
  const gruposPagina = gruposFiltrados.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE)

  function exportar() {
    if (!salidas.length) return
    const ordenadas = [...salidas].sort((a, b) => new Date(b.fecha) - new Date(a.fecha))
    const filas = [
      ['Fecha y hora', 'Sucursal', 'Producto', 'Cantidad', 'Entregado por'],
      ...ordenadas.map(m => [formatearFechahora(m.fecha), m.nombreDestino, m.nombreProducto || '', m.cantidad, getNombreUsuario(m)]),
    ]
    const hoy = new Date()
    descargarCsv(filas, `salidas_${hoy.getFullYear()}-${String(hoy.getMonth()+1).padStart(2,'0')}-${String(hoy.getDate()).padStart(2,'0')}.csv`)
  }

  async function handleEliminarGrupo(grupo) {
    for (const m of grupo) await eliminarMovimiento(m.idMovimiento)
    setConfirm(null); cargar()
    toast.success('Salida eliminada')
  }

  return (
    <div className="flex flex-col h-full p-4 md:p-7 gap-4">

      <div>
        <h2 className="text-xl md:text-2xl font-bold text-slate-800 dark:text-white">Salida</h2>
        <p className="text-slate-500 dark:text-white/60 text-xs mt-0.5">Registrar una salida de stock</p>
      </div>

      {/* Buscador + botones */}
      <div className="flex items-center gap-2">
        <div className="relative flex-1">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 dark:text-white/30 pointer-events-none" />
          <input
            type="text"
            placeholder="Buscar por sucursal, producto o usuario..."
            value={busqueda}
            onChange={e => setBusqueda(e.target.value)}
            className="w-full pl-9 pr-8 py-2 text-sm rounded-lg border border-slate-200 dark:border-white/10 bg-white dark:bg-white/5 text-slate-800 dark:text-white placeholder-slate-400 dark:placeholder-white/30 outline-none focus:border-green-500 dark:focus:border-green-500"
          />
          {busqueda && (
            <button onClick={() => setBusqueda('')}
              className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 dark:text-white/30 hover:text-slate-700 dark:hover:text-white cursor-pointer">
              <X size={14} />
            </button>
          )}
        </div>
        <div className="flex gap-2 flex-shrink-0">
          <button onClick={exportar}
            className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-slate-200 hover:bg-slate-300 dark:bg-white/10 dark:hover:bg-white/15 text-slate-700 dark:text-white text-sm font-medium transition-colors cursor-pointer">
            <Download size={15} /> <span className="hidden sm:inline">Excel</span>
          </button>
          <button onClick={() => setModal({ mode: 'nuevo' })}
            className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-green-600 hover:bg-green-700 text-white text-sm font-medium transition-colors cursor-pointer">
            <Plus size={15} /> <span className="hidden sm:inline">Agregar</span>
          </button>
        </div>
      </div>

      <div className="flex-1 flex flex-col rounded-xl border border-slate-200 dark:border-white/10 overflow-hidden min-h-0 bg-white dark:bg-[#1A2332]">
        {!loading && gruposFiltrados.length === 0 ? (
          <div className="flex-1 flex flex-col items-center justify-center gap-3 text-slate-400 dark:text-white/40 py-12">
            <div className="w-16 h-16 rounded-2xl bg-slate-100 dark:bg-white/5 flex items-center justify-center">
              <PackageOpen size={32} strokeWidth={1.3} />
            </div>
            <div className="text-center">
              <p className="text-sm font-medium">{busqueda ? 'Sin resultados para esa búsqueda' : 'Sin salidas registradas'}</p>
              <p className="text-xs mt-0.5 text-slate-300 dark:text-white/20">
                {busqueda ? 'Probá con otro término' : 'Registrá la primera salida con el botón Agregar'}
              </p>
            </div>
          </div>
        ) : (
          <>
            <div className="flex-1 min-h-0 overflow-x-auto overflow-y-auto">
              <table className="w-full text-sm text-left" style={{ minWidth: 560 }}>
                <thead className="text-slate-500 dark:text-white/50 text-xs uppercase border-b border-slate-200 dark:border-white/10 sticky top-0 bg-white dark:bg-[#1A2332]">
                  <tr>
                    <th className="px-4 py-3 font-semibold">Fecha y hora</th>
                    <th className="px-4 py-3 font-semibold">Sucursal</th>
                    <th className="px-4 py-3 font-semibold">Productos</th>
                    <th className="px-4 py-3 font-semibold">Entregado por</th>
                    <th className="px-4 py-3 font-semibold text-right">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {loading ? <SkeletonRows cols={5} /> : gruposPagina.map((grupo, i) => {
                    const primera = grupo[0]
                    const textoProductos = grupo.map(m => `${m.nombreProducto || 'Producto'} (${m.cantidad})`).join(' · ')
                    const usuNombre = getNombreUsuario(primera)
                    return (
                      <tr key={i} className="border-b border-slate-100 dark:border-white/5 hover:bg-slate-50 dark:hover:bg-white/10 transition-colors">
                        <td className="px-4 py-3 text-slate-800 dark:text-white font-medium whitespace-nowrap">{formatearFechahora(primera.fecha)}</td>
                        <td className="px-4 py-3 text-slate-700 dark:text-white/80">{primera.nombreDestino}</td>
                        <td className="px-4 py-3 text-slate-600 dark:text-white/70 max-w-xs truncate">{textoProductos}</td>
                        <td className="px-4 py-3 text-slate-400 dark:text-white/50 text-xs italic">{usuNombre || '—'}</td>
                        <td className="px-4 py-3">
                          <div className="flex justify-end gap-1">
                            <button onClick={() => setModal({ mode: 'editar', grupo })}
                              className="p-1.5 text-slate-400 dark:text-white/50 hover:text-slate-800 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-white/10 rounded transition-colors cursor-pointer">
                              <Edit2 size={15} />
                            </button>
                            <button onClick={() => setConfirm(grupo)}
                              className="p-1.5 text-slate-400 dark:text-white/50 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded transition-colors cursor-pointer">
                              <Trash2 size={15} />
                            </button>
                          </div>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>

            {!loading && gruposFiltrados.length > PAGE_SIZE && (
              <div className="flex items-center justify-between px-4 py-2.5 border-t border-slate-200 dark:border-white/10 flex-shrink-0">
                <span className="text-xs text-slate-400 dark:text-slate-500 tabular-nums">
                  {(safePage - 1) * PAGE_SIZE + 1}–{Math.min(safePage * PAGE_SIZE, gruposFiltrados.length)} de {gruposFiltrados.length}
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
          </>
        )}
      </div>

      {modal && (
        <ModalSalida mode={modal.mode} grupo={modal.grupo}
          onClose={() => setModal(null)} onExito={() => { setModal(null); cargar() }} />
      )}

      {confirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
          <div className="bg-white dark:bg-[#1A2332] rounded-xl p-6 w-80 shadow-2xl">
            <h3 className="font-semibold text-gray-800 dark:text-white mb-2">Eliminar salida</h3>
            <p className="text-gray-600 dark:text-slate-400 text-sm mb-5">¿Eliminar la salida a "{confirm[0].nombreDestino}"? Se restaurará el stock.</p>
            <div className="flex gap-3">
              <button onClick={() => setConfirm(null)}
                className="flex-1 py-2 border border-gray-300 dark:border-white/10 rounded-lg text-gray-700 dark:text-slate-300 text-sm hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer">Cancelar</button>
              <button onClick={() => handleEliminarGrupo(confirm)}
                className="flex-1 py-2 bg-red-500 hover:bg-red-600 rounded-lg text-white text-sm font-semibold cursor-pointer">Eliminar</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function ModalSalida({ mode, grupo, onClose, onExito }) {
  const esEdicion = mode === 'editar'
  const [stock,      setStock]      = useState([])
  const [destinos,   setDestinos]   = useState([])
  const [idTipoSal,  setIdTipoSal]  = useState(null)
  const [cargando,   setCargando]   = useState(true)
  const [guardando,  setGuardando]  = useState(false)
  const [destino,    setDestino]    = useState('')
  const [filas,      setFilas]      = useState([{ idProducto: '', cantidad: '' }])
  const [errorStock, setErrorStock] = useState(null)

  useEffect(() => {
    async function init() {
      const [s, d, tipos] = await Promise.all([listarStock(), listarDestinos(), listarTiposMovimiento()])
      const rawStock = Array.isArray(s) ? s : []
      setStock(rawStock); setDestinos(d); setIdTipoSal(idParaSalida(tipos))
      if (esEdicion && grupo?.length) {
        const primera = grupo[0]
        const dest = d.find(x => x.id === primera.idDestino) || d.find(x => x.nombre === primera.nombreDestino)
        setDestino(dest?.id ? String(dest.id) : d[0]?.id ? String(d[0].id) : '')
        setFilas(grupo.map(m => ({ idProducto: String(m.idProducto), cantidad: String(m.cantidad) })))
      } else {
        setDestino(d[0]?.id ? String(d[0].id) : '')
        setFilas([{ idProducto: rawStock[0]?.idProducto ? String(rawStock[0].idProducto) : '', cantidad: '' }])
      }
      setCargando(false)
    }
    init()
  }, [])

  async function guardar() {
    if (!destino) return
    setGuardando(true); setErrorStock(null)
    const idDest = Number(destino)
    if (esEdicion && grupo?.length === 1) {
      const fila = filas[0]
      const res = await actualizarMovimiento(grupo[0].idMovimiento, {
        idDestino: idDest, idProducto: Number(fila.idProducto), cantidad: Number(fila.cantidad),
      })
      setGuardando(false)
      if (res.ok) { toast.success('Salida actualizada'); onExito() } else setErrorStock(res.message)
      return
    }
    for (const fila of filas) {
      const res = await registrarSalida({ idProducto: Number(fila.idProducto), cantidad: Number(fila.cantidad), idDestino: idDest, idTipoMov: idTipoSal })
      if (!res.ok) {
        setGuardando(false)
        if (res.errorStock) {
          setErrorStock(`${res.errorStock.message}. Disponible: ${res.errorStock.stockDisponible ?? '?'}. Solicitado: ${res.errorStock.cantidadSolicitada ?? '?'}`)
        } else setErrorStock(res.message)
        return
      }
    }
    setGuardando(false)
    toast.success(esEdicion ? 'Salida actualizada' : 'Salida registrada')
    onExito()
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="bg-white dark:bg-[#1A2332] rounded-xl w-full max-w-md shadow-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between p-5 border-b border-gray-100 dark:border-white/5">
          <h3 className="font-bold text-gray-800 dark:text-white">{esEdicion ? 'Editar salida' : 'Registrar salida'}</h3>
          <button onClick={onClose} className="text-gray-400 dark:text-slate-500 hover:text-gray-600 dark:hover:text-slate-300 cursor-pointer"><X size={20} /></button>
        </div>
        <div className="p-5 flex flex-col gap-4">
          {cargando ? (
            <div className="flex justify-center py-8"><RefreshCw size={24} className="animate-spin text-green-600" /></div>
          ) : (
            <>
              <div>
                <label className="text-xs font-semibold text-gray-500 dark:text-slate-400 uppercase tracking-wide mb-1 block">Sucursal / Destino</label>
                <select value={destino} onChange={e => setDestino(e.target.value)}
                  className="w-full px-3 py-2.5 border border-gray-200 dark:border-white/10 rounded-lg text-sm text-gray-700 dark:text-slate-200 bg-white dark:bg-[#1E2C3D] outline-none focus:border-green-500 dark:focus:border-green-500 dark:[color-scheme:dark]">
                  {destinos.map(d => <option key={d.id} value={d.id}>{d.nombre}</option>)}
                </select>
              </div>
              <div>
                <label className="text-xs font-semibold text-gray-500 dark:text-slate-400 uppercase tracking-wide mb-1 block">Productos</label>
                {filas.map((fila, i) => (
                  <div key={i} className="flex gap-2 mb-2">
                    <select value={fila.idProducto}
                      onChange={e => { const f = [...filas]; f[i].idProducto = e.target.value; setFilas(f); setErrorStock(null) }}
                      className="flex-1 px-3 py-2 border border-gray-200 dark:border-white/10 rounded-lg text-sm text-gray-700 dark:text-slate-200 bg-white dark:bg-[#1E2C3D] outline-none focus:border-green-500 dark:focus:border-green-500 dark:[color-scheme:dark]">
                      {stock.map(s => <option key={s.idProducto} value={s.idProducto}>{s.nombreProducto} (stock: {s.stockActual})</option>)}
                    </select>
                    <input type="number" placeholder="Cant." value={fila.cantidad} min={1}
                      onChange={e => { const f = [...filas]; f[i].cantidad = e.target.value; setFilas(f); setErrorStock(null) }}
                      className="w-20 px-3 py-2 border border-gray-200 dark:border-white/10 rounded-lg text-sm text-gray-700 dark:text-slate-200 bg-white dark:bg-white/5 outline-none focus:border-green-500 dark:focus:border-green-500" />
                    {filas.length > 1 && (
                      <button onClick={() => setFilas(filas.filter((_, j) => j !== i))}
                        className="text-red-400 hover:text-red-600 cursor-pointer"><X size={18} /></button>
                    )}
                  </div>
                ))}
                {!esEdicion && (
                  <button onClick={() => setFilas([...filas, { idProducto: stock[0]?.idProducto ? String(stock[0].idProducto) : '', cantidad: '' }])}
                    className="text-green-600 text-sm hover:underline flex items-center gap-1 mt-1 cursor-pointer">
                    <Plus size={14} /> Agregar otro producto
                  </button>
                )}
              </div>
              {errorStock && (
                <div className="flex items-start gap-2 bg-red-50 dark:bg-red-500/10 border border-red-200 dark:border-red-500/20 rounded-lg px-3 py-2.5 text-red-700 dark:text-red-400 text-sm">
                  <AlertTriangle size={16} className="flex-shrink-0 mt-0.5" />{errorStock}
                </div>
              )}
              <div className="flex gap-3 pt-1">
                <button onClick={onClose} className="flex-1 py-2.5 border border-gray-300 dark:border-white/10 rounded-lg text-gray-700 dark:text-slate-300 text-sm hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer">Cancelar</button>
                <button onClick={guardar} disabled={guardando}
                  className="flex-1 py-2.5 bg-green-600 hover:bg-green-700 disabled:opacity-60 rounded-lg text-white text-sm font-semibold cursor-pointer">
                  {guardando ? <RefreshCw size={16} className="animate-spin mx-auto" /> : 'Guardar'}
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
