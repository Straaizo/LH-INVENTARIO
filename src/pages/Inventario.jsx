import { useEffect, useState } from 'react'
import { Package, AlertTriangle, AlertCircle, Search, Tag } from 'lucide-react'
import { listarStock, listarProductos } from '../services/inventarioApi'

const K_CRITICO = 3
const K_BAJO    = 6

function SkeletonItems() {
  return (
    <>
      {[72, 55, 88, 60, 78, 50].map((w, i) => (
        <div key={i} className="flex items-center gap-3 px-4 py-2.5 mb-1 rounded-lg border-l-4 border-slate-200 dark:border-white/10 bg-slate-50 dark:bg-[#1E2C3D] animate-pulse">
          <div className="w-4 h-4 rounded bg-slate-200 dark:bg-white/10 flex-shrink-0" />
          <div className="flex-1 h-3.5 rounded bg-slate-200 dark:bg-white/10" style={{ maxWidth: `${w}%` }} />
          <div className="w-20 h-6 rounded-full bg-slate-200 dark:bg-white/10 flex-shrink-0" />
          <div className="w-7 h-7 rounded bg-slate-200 dark:bg-white/10 flex-shrink-0" />
        </div>
      ))}
    </>
  )
}

function estadoStock(stock) {
  if (stock <= K_CRITICO) return 'critico'
  if (stock <= K_BAJO)    return 'bajo'
  return 'ok'
}

const ESTADO_CFG = {
  critico: { bg: 'bg-red-500',    text: 'text-red-100',   border: 'border-red-500',   icon: AlertCircle },
  bajo:    { bg: 'bg-orange-400', text: 'text-orange-50', border: 'border-orange-400', icon: AlertTriangle },
  ok:      { bg: 'bg-green-600',  text: 'text-green-50',  border: 'border-green-500',  icon: null },
}

export default function Inventario() {
  const [items,      setItems]      = useState([])
  const [catMap,     setCatMap]     = useState({})
  const [loading,    setLoading]    = useState(true)
  const [busqueda,   setBusqueda]   = useState('')
  const [error,      setError]      = useState(null)
  async function cargar() {
    setLoading(true); setError(null)
    const [stockRes, productos] = await Promise.all([listarStock(), listarProductos()])
    if (stockRes?.error) { setError(stockRes.error); setLoading(false); return }
    const map = {}
    for (const p of productos) {
      if (p.idProducto && p.nombreCategoria?.trim()) map[p.idProducto] = p.nombreCategoria.trim()
    }
    setCatMap(map)
    setItems(stockRes)
    setLoading(false)
  }

  useEffect(() => { cargar() }, [])

  function categoriaDeItem(item) {
    return catMap[item.idProducto]?.trim() || item.nombreCategoria?.trim() || 'Sin categoría'
  }

  const filtrados = busqueda.trim()
    ? items.filter(i => i.nombreProducto.toLowerCase().includes(busqueda.toLowerCase()))
    : items

  const agrupados = {}
  for (const item of filtrados) {
    const cat = categoriaDeItem(item)
    if (!agrupados[cat]) agrupados[cat] = []
    agrupados[cat].push(item)
  }
  const categorias = Object.keys(agrupados).sort((a, b) => {
    if (a === 'Sin categoría') return 1
    if (b === 'Sin categoría') return -1
    return a.localeCompare(b)
  })

  const total    = items.length
  const bajos    = items.filter(i => estadoStock(i.stockActual) === 'bajo').length
  const criticos = items.filter(i => estadoStock(i.stockActual) === 'critico').length

  return (
    <div className="flex flex-col h-full p-4 md:p-7 gap-4">

      <div>
        <h2 className="text-xl md:text-2xl font-bold text-slate-800 dark:text-white">Inventario</h2>
        <p className="text-slate-500 dark:text-white/60 text-xs mt-0.5">Stock actual por producto</p>
      </div>

      {/* Búsqueda + chips */}
      <div className="flex flex-wrap items-center gap-2">
        <div className="flex-1 relative" style={{ minWidth: 140 }}>
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 dark:text-white/40" />
          <input
            type="text"
            placeholder="Buscar producto…"
            value={busqueda}
            onChange={(e) => setBusqueda(e.target.value)}
            className="w-full pl-8 pr-4 py-2 rounded-lg text-sm outline-none transition-colors
              text-slate-800 dark:text-white bg-white dark:bg-[#1A2332]
              border border-slate-200 dark:border-white/10
              placeholder:text-slate-400 dark:placeholder:text-slate-500
              focus:border-green-500 dark:focus:border-green-500"
          />
        </div>
        {!loading && items.length > 0 && (
          <div className="hidden sm:flex items-center gap-2">
            <Chip label={`${total} productos`}  color="#3B82F6" icon={Package} />
            <Chip label={`${bajos} bajo stock`} color="#F59E0B" icon={AlertTriangle} />
            <Chip label={`${criticos} crítico`} color="#EF4444" icon={AlertCircle} />
          </div>
        )}
      </div>

      <div className="flex-1 flex flex-col rounded-xl border border-slate-200 dark:border-white/10 overflow-hidden min-h-0
        bg-white dark:bg-[#1A2332]">

        <div className="flex-1 min-h-0 overflow-y-auto px-4 pb-4 pt-3">
          {error ? (
            <div className="flex items-center justify-center h-full min-h-[200px] text-red-500 dark:text-red-300 text-sm">{error}</div>
          ) : loading ? (
            <SkeletonItems />
          ) : filtrados.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full min-h-[200px] gap-3 text-slate-400 dark:text-white/40">
              <div className="w-16 h-16 rounded-2xl bg-slate-100 dark:bg-white/5 flex items-center justify-center">
                <Package size={32} strokeWidth={1.3} />
              </div>
              <div className="text-center">
                <p className="text-sm font-medium">{busqueda ? `Sin resultados para "${busqueda}"` : 'Sin datos de stock'}</p>
                {!busqueda && <p className="text-xs mt-0.5 text-slate-300 dark:text-white/20">Agregá productos para verlos aquí</p>}
              </div>
            </div>
          ) : (
            categorias.map(cat => (
              <div key={cat}>
                <CategoryHeader nombre={cat} cantidad={agrupados[cat].length} />
                {agrupados[cat].map(item => (
                  <ItemCard key={item.idProducto} item={item} />
                ))}
              </div>
            ))
          )}
        </div>
      </div>

    </div>
  )
}

function Chip({ label, color, icon: Icon }) {
  return (
    <div className="flex items-center gap-1.5 px-3 py-1.5 rounded border text-xs font-semibold
      text-slate-700 dark:text-slate-200 bg-white dark:bg-[#1A2332]"
      style={{ borderColor: color + '80' }}>
      <Icon size={12} className="shrink-0" style={{ color }} />
      {label}
    </div>
  )
}

function CategoryHeader({ nombre, cantidad }) {
  return (
    <div className="mt-4 mb-1.5">
      <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded w-[130px]
        bg-green-100 dark:bg-green-900/30 border border-green-300 dark:border-green-600/50">
        <Tag size={11} className="text-green-700 dark:text-green-400 flex-shrink-0" />
        <span className="text-[11px] font-bold truncate flex-1 text-green-800 dark:text-green-300">{nombre}</span>
        <span className="text-[10px] font-bold px-1.5 py-0.5 rounded-full flex-shrink-0
          bg-green-600 text-white">{cantidad}</span>
      </div>
    </div>
  )
}

function ItemCard({ item }) {
  const estado = estadoStock(item.stockActual)
  const cfg    = ESTADO_CFG[estado]
  const Icon   = cfg.icon
  const nombre = item.nombreProducto || `Producto #${item.idProducto}`

  return (
    <div className={`flex items-center gap-3 px-4 py-2.5 mb-1 rounded-lg border-l-4 ${cfg.border}
      bg-slate-50 dark:bg-[#1E2C3D]`}>
      <Package size={16} className="text-slate-300 dark:text-white/35 flex-shrink-0" />
      <span className="flex-1 text-sm font-semibold text-slate-800 dark:text-white truncate">{nombre}</span>
      <div className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${cfg.bg} ${cfg.text} flex-shrink-0`}
        style={{ minWidth: 80, justifyContent: 'center' }}>
        {Icon && <Icon size={13} />}
        {item.stockActual} uds
      </div>
    </div>
  )
}

