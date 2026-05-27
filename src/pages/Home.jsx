import { useEffect, useState } from 'react'
import { Package, AlertTriangle, AlertCircle, TrendingDown } from 'lucide-react'
import { listarStock } from '../services/inventarioApi'
import { listarSalidas } from '../services/movimientosApi'
import { useAuth } from '../context/useAuth'
import { formatearFechahora } from '../utils/csv'

const K_CRITICO = 3
const K_BAJO    = 6

function agruparSalidas(lista) {
  const map = {}
  for (const m of lista) {
    const d = new Date(m.fecha)
    const key = isNaN(d)
      ? `${m.fecha}|${m.nombreDestino}`
      : `${d.getFullYear()}-${d.getMonth()}-${d.getDate()} ${d.getHours()}:${d.getMinutes()}|${m.nombreDestino}`
    if (!map[key]) map[key] = []
    map[key].push(m)
  }
  return Object.values(map)
    .sort((a, b) => new Date(b[0].fecha) - new Date(a[0].fecha))
    .slice(0, 8)
}

export default function Home() {
  const { user }    = useAuth()
  const [stock,    setStock]   = useState([])
  const [salidas,  setSalidas] = useState([])
  const [loading,  setLoading] = useState(true)

  useEffect(() => {
    async function cargar() {
      const [s, mov] = await Promise.all([listarStock(), listarSalidas()])
      setStock(Array.isArray(s) ? s : [])
      setSalidas(Array.isArray(mov) ? mov : [])
      setLoading(false)
    }
    cargar()
  }, [])

  const criticos = stock.filter(i => i.stockActual <= K_CRITICO)
  const bajos    = stock.filter(i => i.stockActual > K_CRITICO && i.stockActual <= K_BAJO)

  const fechaStr = new Date().toLocaleDateString('es-CL', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
  })

  return (
    <div className="p-4 md:px-10 md:pt-15 md:pb-7 overflow-y-auto h-full flex flex-col gap-5">

      <div>
        <h2 className="text-xl md:text-2xl font-bold text-slate-800 dark:text-white">
          Hola, {user?.nombre?.split(' ')[0] || 'Usuario'} 👋
        </h2>
        <p className="text-slate-500 dark:text-white/50 text-sm mt-0.5 capitalize">{fechaStr}</p>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <StatCard icon={Package}       label="Productos"    value={loading ? null : stock.length}    color="blue"   />
        <StatCard icon={AlertCircle}   label="Crítico"      value={loading ? null : criticos.length} color="red"    />
        <StatCard icon={AlertTriangle} label="Stock bajo"   value={loading ? null : bajos.length}    color="orange" />
        <StatCard icon={TrendingDown}  label="Últ. salidas" value={loading ? null : agruparSalidas(salidas).length}  color="green"  />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 flex-1 min-h-0 pb-2">

        <Panel title="Alertas de stock" icon={AlertCircle} iconColor="text-red-500">
          {loading ? <PanelSkeleton /> : criticos.length === 0 ? (
            <Empty icon={Package} text="Sin alertas críticas" sub="Todo el stock está en nivel normal" />
          ) : (
            criticos.map(item => (
              <div key={item.idProducto}
                className="flex items-center gap-3 px-3 py-2.5 mb-1.5 rounded-lg border-l-4 border-red-500 bg-red-50 dark:bg-red-500/10">
                <span className="flex-1 text-sm font-medium text-slate-800 dark:text-white truncate">{item.nombreProducto}</span>
                <span className="text-xs font-bold text-red-600 dark:text-red-400 bg-red-100 dark:bg-red-900/50 px-2 py-0.5 rounded-full flex-shrink-0">
                  {item.stockActual} uds
                </span>
              </div>
            ))
          )}
        </Panel>

        <Panel title="Últimas salidas" icon={TrendingDown} iconColor="text-green-600 dark:text-green-400">
          {loading ? <PanelSkeleton /> : salidas.length === 0 ? (
            <Empty icon={TrendingDown} text="Sin salidas recientes" sub="Los movimientos aparecerán aquí" />
          ) : (
            agruparSalidas(salidas).map((grupo, i) => {
              const primera   = grupo[0]
              const nombres   = grupo.map(m => m.nombreProducto).join(' - ')
              const totalUds  = grupo.reduce((sum, m) => sum + (m.cantidad || 0), 0)
              return (
                <div key={i} className="flex items-center gap-3 px-3 py-2.5 mb-1.5 rounded-lg bg-slate-50 dark:bg-[#1E2C3D]">
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-slate-800 dark:text-white truncate">{nombres}</p>
                    <p className="text-xs text-slate-400 dark:text-white/40 truncate">
                      {primera.nombreDestino} · {formatearFechahora(primera.fecha)}
                    </p>
                  </div>
                  <span className="text-xs font-bold text-slate-500 dark:text-white/60 flex-shrink-0">{totalUds} uds</span>
                </div>
              )
            })
          )}
        </Panel>
      </div>
    </div>
  )
}

function StatCard({ icon: Icon, label, value, color }) {
  const cfg = {
    blue:   { wrap: 'bg-blue-50   dark:bg-blue-500/10   border-blue-200   dark:border-blue-500/20',   icon: 'text-blue-500',                      val: 'text-blue-700   dark:text-blue-400'   },
    red:    { wrap: 'bg-red-50    dark:bg-red-500/10    border-red-200    dark:border-red-500/20',    icon: 'text-red-500',                        val: 'text-red-700    dark:text-red-400'    },
    orange: { wrap: 'bg-orange-50 dark:bg-orange-500/10 border-orange-200 dark:border-orange-500/20', icon: 'text-orange-500',                     val: 'text-orange-700 dark:text-orange-400' },
    green:  { wrap: 'bg-green-50  dark:bg-green-500/10  border-green-200  dark:border-green-500/20',  icon: 'text-green-600 dark:text-green-400',  val: 'text-green-700  dark:text-green-400'  },
  }[color]
  return (
    <div className={`rounded-xl border p-4 flex flex-col gap-2 ${cfg.wrap}
      hover:scale-[1.02] hover:shadow-md transition-all duration-200 cursor-default`}>
      <Icon size={20} className={cfg.icon} />
      <p className={`text-2xl font-bold ${cfg.val}`}>
        {value === null
          ? <span className="inline-block w-8 h-6 rounded bg-current opacity-20 animate-pulse" />
          : value}
      </p>
      <p className="text-xs text-slate-500 dark:text-white/50 font-medium">{label}</p>
    </div>
  )
}

function Panel({ title, icon: Icon, iconColor, children }) {
  return (
    <div className="rounded-xl border border-slate-200 dark:border-white/10 bg-white dark:bg-[#1A2332] flex flex-col overflow-hidden">
      <div className="px-5 py-4 border-b border-slate-100 dark:border-white/10 flex items-center gap-2 flex-shrink-0">
        <Icon size={16} className={iconColor} />
        <h3 className="font-semibold text-slate-800 dark:text-white text-sm">{title}</h3>
      </div>
      <div className="flex-1 overflow-y-auto p-3">{children}</div>
    </div>
  )
}

function PanelSkeleton() {
  return (
    <div className="flex flex-col gap-2 p-1 pt-2">
      {[72, 55, 88, 63].map((w, i) => (
        <div key={i} className="flex items-center gap-3 px-3 py-2.5 rounded-lg bg-slate-100 dark:bg-white/5 animate-pulse">
          <div className="h-3 rounded bg-slate-200 dark:bg-white/10 flex-1" style={{ maxWidth: `${w}%` }} />
          <div className="h-5 w-14 rounded-full bg-slate-200 dark:bg-white/10 flex-shrink-0" />
        </div>
      ))}
    </div>
  )
}

function Empty({ icon: Icon, text, sub }) {
  return (
    <div className="flex flex-col items-center justify-center py-10 gap-3 text-slate-400 dark:text-white/30">
      <div className="w-14 h-14 rounded-2xl bg-slate-100 dark:bg-white/5 flex items-center justify-center">
        <Icon size={28} strokeWidth={1.3} />
      </div>
      <div className="text-center">
        <p className="text-sm font-medium">{text}</p>
        {sub && <p className="text-xs mt-0.5 text-slate-300 dark:text-white/20">{sub}</p>}
      </div>
    </div>
  )
}
