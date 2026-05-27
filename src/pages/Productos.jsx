import { useEffect, useState } from 'react'
import { Plus, Edit2, Trash2, ShoppingBag, X, RefreshCw, Search, Tag } from 'lucide-react'
import toast from 'react-hot-toast'
import { listarProductos, crearProducto, actualizarProducto, eliminarProducto, listarCategorias } from '../services/inventarioApi'

function SkeletonItems() {
  return (
    <>
      {[68, 50, 82, 58, 75, 45].map((w, i) => (
        <div key={i} className="flex items-center gap-3 px-4 py-2.5 mb-1 rounded-lg border-l-4 border-slate-200 dark:border-white/10 bg-slate-50 dark:bg-[#1E2C3D] animate-pulse">
          <div className="w-4 h-4 rounded bg-slate-200 dark:bg-white/10 flex-shrink-0" />
          <div className="flex-1 h-3.5 rounded bg-slate-200 dark:bg-white/10" style={{ maxWidth: `${w}%` }} />
          <div className="w-7 h-7 rounded bg-slate-200 dark:bg-white/10 flex-shrink-0" />
          <div className="w-7 h-7 rounded bg-slate-200 dark:bg-white/10 flex-shrink-0" />
        </div>
      ))}
    </>
  )
}

export default function Productos() {
  const [productos,  setProductos]  = useState([])
  const [categorias, setCategorias] = useState([])
  const [loading,    setLoading]    = useState(true)
  const [busqueda,   setBusqueda]   = useState('')
  const [modal,      setModal]      = useState(null)
  const [confirm,    setConfirm]    = useState(null)

  async function cargar() {
    setLoading(true)
    const [p, c] = await Promise.all([listarProductos(), listarCategorias()])
    setProductos(p); setCategorias(c); setLoading(false)
  }

  useEffect(() => { cargar() }, [])

  const filtrados = busqueda.trim()
    ? productos.filter(p => p.nombreProducto.toLowerCase().includes(busqueda.toLowerCase()))
    : productos

  const agrupados = {}
  for (const p of filtrados) {
    const cat = p.nombreCategoria?.trim() || 'Sin categoría'
    if (!agrupados[cat]) agrupados[cat] = []
    agrupados[cat].push(p)
  }
  const cats = Object.keys(agrupados).sort((a, b) => {
    if (a === 'Sin categoría') return 1; if (b === 'Sin categoría') return -1
    return a.localeCompare(b)
  })

  async function handleEliminar(p) {
    const res = await eliminarProducto(p.idProducto)
    if (res.ok) { setConfirm(null); cargar(); toast.success('Producto eliminado') }
    else toast.error(res.message || 'Error al eliminar')
  }

  return (
    <div className="flex flex-col h-full p-4 md:p-7 gap-4">

      <div>
        <h2 className="text-xl md:text-2xl font-bold text-slate-800 dark:text-white">Productos</h2>
        <p className="text-slate-500 dark:text-white/60 text-xs mt-0.5">Gestión de productos de inventario</p>
      </div>

      {/* Búsqueda + botón */}
      <div className="flex items-center gap-2">
        <div className="flex-1 relative">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 dark:text-white/40" />
          <input type="text" placeholder="Buscar producto…" value={busqueda}
            onChange={e => setBusqueda(e.target.value)}
            className="w-full pl-8 pr-4 py-2 rounded-lg text-sm outline-none transition-colors
              text-slate-800 dark:text-white bg-white dark:bg-[#1A2332]
              border border-slate-200 dark:border-white/10
              placeholder:text-slate-400 dark:placeholder:text-slate-500
              focus:border-green-500 dark:focus:border-green-500" />
        </div>
        <button onClick={() => setModal({ mode: 'nuevo' })}
          className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-green-600 hover:bg-green-700 text-white text-sm font-medium transition-colors cursor-pointer flex-shrink-0">
          <Plus size={16} /> <span className="hidden sm:inline">Nuevo producto</span>
        </button>
      </div>

      <div className="flex-1 flex flex-col rounded-xl border border-slate-200 dark:border-white/10 overflow-hidden min-h-0 bg-white dark:bg-[#1A2332]">
        <div className="flex-1 min-h-0 overflow-y-auto px-4 pb-4 pt-3">
          {loading ? (
            <SkeletonItems />
          ) : filtrados.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full min-h-[200px] gap-3 text-slate-400 dark:text-white/40">
              <div className="w-16 h-16 rounded-2xl bg-slate-100 dark:bg-white/5 flex items-center justify-center">
                <ShoppingBag size={32} strokeWidth={1.3} />
              </div>
              <div className="text-center">
                <p className="text-sm font-medium">{busqueda ? `Sin resultados para "${busqueda}"` : 'Sin productos'}</p>
                {!busqueda && <p className="text-xs mt-0.5 text-slate-300 dark:text-white/20">Creá el primer producto con el botón Nuevo producto</p>}
              </div>
            </div>
          ) : (
            cats.map(cat => (
              <div key={cat}>
                <div className="mt-4 mb-1.5">
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded
                    bg-green-100 dark:bg-green-900/30 border border-green-300 dark:border-green-600/50">
                    <Tag size={11} className="text-green-700 dark:text-green-400 flex-shrink-0" />
                    <span className="text-[11px] font-bold text-green-800 dark:text-green-300">{cat}</span>
                    <span className="text-[10px] font-bold px-1.5 py-0.5 rounded-full ml-1
                      bg-green-600 text-white">{agrupados[cat].length}</span>
                  </div>
                </div>
                {agrupados[cat].map(p => (
                  <div key={p.idProducto}
                    className="flex items-center gap-3 px-4 py-2.5 mb-1 rounded-lg border-l-4 border-green-500 bg-slate-50 dark:bg-[#1E2C3D]">
                    <ShoppingBag size={15} className="text-slate-300 dark:text-white/35 flex-shrink-0" />
                    <span className="flex-1 text-sm font-semibold text-slate-800 dark:text-white truncate">{p.nombreProducto}</span>
                    <div className="flex gap-1">
                      <button onClick={() => setModal({ mode: 'editar', producto: p })}
                        className="p-1.5 text-slate-400 dark:text-white/50 hover:text-slate-800 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-white/10 rounded transition-colors cursor-pointer">
                        <Edit2 size={14} />
                      </button>
                      <button onClick={() => setConfirm(p)}
                        className="p-1.5 text-slate-400 dark:text-white/50 hover:text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 rounded transition-colors cursor-pointer">
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            ))
          )}
        </div>
      </div>

      {modal && (
        <ModalProducto mode={modal.mode} producto={modal.producto} categorias={categorias}
          onClose={() => setModal(null)} onExito={() => { setModal(null); cargar() }} />
      )}

      {confirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60">
          <div className="bg-white dark:bg-[#1A2332] rounded-xl p-6 w-80 shadow-2xl">
            <h3 className="font-semibold text-gray-800 dark:text-white mb-2">Eliminar producto</h3>
            <p className="text-gray-600 dark:text-slate-400 text-sm mb-5">¿Eliminar "{confirm.nombreProducto}"?</p>
            <div className="flex gap-3">
              <button onClick={() => setConfirm(null)} className="flex-1 py-2 border border-gray-300 dark:border-white/10 rounded-lg text-gray-700 dark:text-slate-300 text-sm hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer">Cancelar</button>
              <button onClick={() => handleEliminar(confirm)} className="flex-1 py-2 bg-red-500 hover:bg-red-600 rounded-lg text-white text-sm font-semibold cursor-pointer">Eliminar</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function ModalProducto({ mode, producto, categorias, onClose, onExito }) {
  const [nombre,    setNombre]    = useState(producto?.nombreProducto || '')
  const [categoria, setCategoria] = useState(producto?.idCategoria ? String(producto.idCategoria) : (categorias[0]?.id ? String(categorias[0].id) : ''))
  const [guardando, setGuardando] = useState(false)
  const [error,     setError]     = useState(null)

  async function guardar() {
    if (!nombre.trim()) { setError('Ingrese un nombre'); return }
    setGuardando(true); setError(null)
    const idCat = categoria ? Number(categoria) : null
    const res = mode === 'nuevo'
      ? await crearProducto(nombre.trim(), idCat)
      : await actualizarProducto(producto.idProducto, nombre.trim(), idCat)
    setGuardando(false)
    if (res.ok) {
      toast.success(mode === 'nuevo' ? 'Producto creado' : 'Producto actualizado')
      onExito()
    } else {
      setError(res.message)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
      <div className="bg-white dark:bg-[#1A2332] rounded-xl w-full max-w-sm shadow-2xl">
        <div className="flex items-center justify-between p-5 border-b border-gray-100 dark:border-white/5">
          <h3 className="font-bold text-gray-800 dark:text-white">{mode === 'nuevo' ? 'Nuevo producto' : 'Editar producto'}</h3>
          <button onClick={onClose} className="text-gray-400 dark:text-slate-500 hover:text-gray-600 dark:hover:text-slate-300 cursor-pointer"><X size={20} /></button>
        </div>
        <div className="p-5 flex flex-col gap-4">
          <div>
            <label className="text-xs font-semibold text-gray-500 dark:text-slate-400 uppercase tracking-wide mb-1 block">Nombre del producto <span className="text-red-400">*</span></label>
            <input type="text" value={nombre} onChange={e => { setNombre(e.target.value); setError(null) }}
              className="w-full px-3 py-2.5 border border-gray-200 dark:border-white/10 rounded-lg text-sm text-gray-700 dark:text-slate-200 bg-white dark:bg-white/5 outline-none focus:border-green-500 dark:focus:border-green-500" />
          </div>
          <div>
            <label className="text-xs font-semibold text-gray-500 dark:text-slate-400 uppercase tracking-wide mb-1 block">Categoría</label>
            <select value={categoria} onChange={e => setCategoria(e.target.value)}
              className="w-full px-3 py-2.5 border border-gray-200 dark:border-white/10 rounded-lg text-sm text-gray-700 dark:text-slate-200 bg-white dark:bg-[#1E2C3D] outline-none focus:border-green-500 dark:focus:border-green-500 dark:[color-scheme:dark]">
              {categorias.map(c => <option key={c.id} value={c.id}>{c.nombre}</option>)}
            </select>
          </div>
          {error && <p className="text-red-500 text-sm">{error}</p>}
          <div className="flex gap-3">
            <button onClick={onClose} className="flex-1 py-2.5 border border-gray-300 dark:border-white/10 rounded-lg text-gray-700 dark:text-slate-300 text-sm hover:bg-gray-50 dark:hover:bg-white/5 cursor-pointer">Cancelar</button>
            <button onClick={guardar} disabled={guardando}
              className="flex-1 py-2.5 bg-green-600 hover:bg-green-700 disabled:opacity-60 rounded-lg text-white text-sm font-semibold cursor-pointer">
              {guardando ? <RefreshCw size={16} className="animate-spin mx-auto" /> : 'Guardar'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
