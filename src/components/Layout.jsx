import { useState, useEffect } from 'react'
import {
  LogOut, Menu, X, PackageOpen, PackagePlus, LayoutList,
  ShoppingBag, Monitor, Smartphone, Tablet, Printer,
  LayoutDashboard, Sun, Moon, Clock, WifiOff, BarChart2,
} from 'lucide-react'
import { useAuth } from '../context/useAuth'
import { useTheme } from '../context/ThemeContext'
import { listarStock } from '../services/inventarioApi'
import { capitalizarNombre } from '../utils/texto'

const NAV_ITEMS = [
  { key: 'dashboard',  label: 'Inicio',     icon: LayoutDashboard },
  { key: 'analisis',   label: 'Análisis',   icon: BarChart2 },
  { section: 'Movimientos' },
  { key: 'salida',     label: 'Salida',     icon: PackageOpen },
  { key: 'entrada',    label: 'Entrada',    icon: PackagePlus },
  { key: 'inventario', label: 'Inventario', icon: LayoutList },
  { key: 'productos',  label: 'Productos',  icon: ShoppingBag },
  { section: 'Activos' },
  { key: 'equipos',    label: 'Equipos',    icon: Monitor },
  { key: 'celulares',  label: 'Celulares',  icon: Smartphone },
  { key: 'tablets',    label: 'Tablets',    icon: Tablet },
  { key: 'impresoras', label: 'Impresoras', icon: Printer },
]

function NavItem({ item, active, onClick, badge }) {
  const Icon = item.icon
  return (
    <button onClick={() => onClick(item.key)}
      className={`w-full flex items-center gap-3 px-5 py-2.5 text-sm font-medium transition-all text-left
        border-l-[3px] cursor-pointer
        ${active
          ? 'bg-green-50 dark:bg-green-500/10 text-green-800 dark:text-green-400 border-green-600 dark:border-green-500'
          : 'border-transparent text-slate-600 dark:text-slate-400 hover:bg-slate-50 dark:hover:bg-white/5 hover:text-slate-900 dark:hover:text-slate-200'
        }`}>
      <Icon size={18} strokeWidth={1.7} />
      <span className="flex-1">{item.label}</span>
      {badge > 0 && (
        <span className="text-[10px] font-bold px-1.5 py-0.5 rounded-full bg-red-500 text-white leading-none">
          {badge}
        </span>
      )}
    </button>
  )
}

function NavList({ items, page, onNav, criticalCount }) {
  return (
    <nav className="flex-1 py-6 overflow-y-auto">
      {items.map((item, i) =>
        item.section
          ? <p key={i} className="px-4 pt-5 pb-1.5 text-[10px] font-bold uppercase tracking-widest text-slate-400 dark:text-slate-500 select-none">
              {item.section}
            </p>
          : <NavItem key={item.key} item={item} active={page === item.key} onClick={onNav}
              badge={item.key === 'inventario' ? criticalCount : 0} />
      )}
    </nav>
  )
}

function InactivityModal({ onExtend, onLogout }) {
  const [secs, setSecs] = useState(60)

  useEffect(() => {
    const id = setInterval(() => setSecs(s => s - 1), 1000)
    return () => clearInterval(id)
  }, [])

  useEffect(() => {
    if (secs <= 0) onLogout()
  }, [secs])

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/60">
      <div className="bg-white dark:bg-[#1A2332] rounded-xl p-7 w-80 shadow-2xl">
        <div className="flex flex-col items-center gap-4">
          <div className="w-14 h-14 rounded-full bg-amber-100 dark:bg-amber-500/10 flex items-center justify-center">
            <Clock size={26} className="text-amber-500" />
          </div>
          <div className="text-center">
            <p className="text-slate-800 dark:text-white font-semibold">Sesión por expirar</p>
            <p className="text-slate-500 dark:text-slate-400 text-sm mt-1">
              Cerrando sesión en <span className="font-bold text-amber-500">{secs}s</span>
            </p>
          </div>
          <div className="flex gap-3 w-full">
            <button onClick={onLogout}
              className="flex-1 py-2.5 border border-slate-300 dark:border-white/10 rounded-lg text-slate-700 dark:text-slate-300 text-sm hover:bg-slate-50 dark:hover:bg-white/5 cursor-pointer">
              Cerrar sesión
            </button>
            <button onClick={onExtend}
              className="flex-1 py-2.5 bg-green-600 hover:bg-green-700 rounded-lg text-white text-sm font-semibold cursor-pointer">
              Continuar
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

const activeLabel = (key) => NAV_ITEMS.find(i => i?.key === key)?.label || ''

export default function Layout({ page, setPage, children }) {
  const { user, doLogout, inactivityWarning, extendSession } = useAuth()
  const { dark, toggle }     = useTheme()
  const [drawerOpen,        setDrawerOpen]        = useState(false)
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false)
  const [criticalCount,     setCriticalCount]     = useState(0)
  const [online,            setOnline]            = useState(navigator.onLine)

  useEffect(() => {
    listarStock().then(data => {
      if (Array.isArray(data)) setCriticalCount(data.filter(p => p.stockActual <= 3).length)
    })
  }, [])

  useEffect(() => {
    const on  = () => setOnline(true)
    const off = () => setOnline(false)
    window.addEventListener('online',  on)
    window.addEventListener('offline', off)
    return () => {
      window.removeEventListener('online',  on)
      window.removeEventListener('offline', off)
    }
  }, [])

  function handleNav(key) { setPage(key); setDrawerOpen(false) }
  function handleLogoutClick() { setShowLogoutConfirm(true); setDrawerOpen(false) }
  async function confirmLogout() { setShowLogoutConfirm(false); await doLogout() }

  const logoutBtn = (
    <div className="p-4 border-t border-slate-200 dark:border-white/8 flex-shrink-0">
      <button onClick={handleLogoutClick}
        className="w-full flex items-center gap-3 px-3 py-2.5 text-sm rounded-lg transition-colors cursor-pointer
          text-slate-500 dark:text-slate-400 hover:text-red-600 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-500/10">
        <LogOut size={16} />
        Cerrar sesión
      </button>
    </div>
  )

  return (
    <div className="flex h-[100dvh] overflow-hidden bg-slate-50 dark:bg-[#0F172A]">

      {/* ── Sidebar desktop ── */}
      <aside className="hidden md:flex flex-col w-56 flex-shrink-0
        bg-white dark:bg-[#1A2332] border-r border-slate-200 dark:border-white/5 shadow-sm dark:shadow-none">
        <div className="h-14 md:h-16 px-5 border-b border-slate-200 dark:border-white/5 flex-shrink-0 flex items-center gap-2.5">
          <img src="/logo_lh.png" alt="LH" className="h-7 w-7 object-contain flex-shrink-0" />
          <span className="font-bold text-slate-800 dark:text-white text-sm">LH Inventario</span>
        </div>
        <NavList items={NAV_ITEMS} page={page} onNav={handleNav} criticalCount={criticalCount} />
        {logoutBtn}
      </aside>

      {/* ── Drawer mobile ── */}
      {drawerOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div className="fixed inset-0 bg-black/50" onClick={() => setDrawerOpen(false)} />
          <aside className="relative z-10 w-64 flex flex-col h-full shadow-2xl
            bg-white dark:bg-[#1A2332]">
            <button onClick={() => setDrawerOpen(false)}
              className="absolute top-3 right-3 text-slate-400 dark:text-slate-500 hover:text-slate-700 dark:hover:text-slate-200 cursor-pointer">
              <X size={22} />
            </button>
            <div className="px-5 py-5 border-b border-slate-200 dark:border-white/8 flex-shrink-0">
              <p className="text-slate-400 dark:text-slate-500 text-xs">Bienvenido,</p>
              <p className="text-slate-800 dark:text-white font-semibold text-sm mt-0.5 truncate">{capitalizarNombre(user?.nombre) || 'Usuario'}</p>
            </div>
            <NavList items={NAV_ITEMS} page={page} onNav={handleNav} criticalCount={criticalCount} />
            {logoutBtn}
          </aside>
        </div>
      )}

      {/* ── Main ── */}
      <div className="flex flex-col flex-1 min-h-0 min-w-0 ">

        {/* Header */}
        <header className="flex items-center px-5 gap-4 flex-shrink-0
          bg-white dark:bg-[#1A2332] border-b border-slate-200 dark:border-white/5 shadow-sm dark:shadow-none"
          style={{ paddingTop: 'calc(env(safe-area-inset-top) + 0.875rem)', paddingBottom: '0.875rem', minHeight: 'calc(env(safe-area-inset-top) + 3.5rem)' }}>

          <button className="md:hidden text-slate-500 dark:text-slate-400 hover:text-slate-800 dark:hover:text-slate-200 cursor-pointer"
            onClick={() => setDrawerOpen(true)}>
            <Menu size={22} />
          </button>

          <div className="hidden md:flex flex-col flex-1 justify-center">
            <p className="text-slate-400 dark:text-slate-500 text-[11px] font-medium leading-none">Bienvenido,</p>
            <p className="text-slate-800 dark:text-white font-semibold text-base leading-snug mt-0.5">
              {capitalizarNombre(user?.nombre) || 'Usuario'}
            </p>
          </div>

          <span className="hidden md:block text-xs font-semibold text-slate-400 dark:text-slate-500 uppercase tracking-widest">
            {activeLabel(page)}
          </span>

          <h1 className="md:hidden text-slate-800 dark:text-white font-semibold text-base flex-1 truncate">
            LH Inventario
          </h1>

          <button onClick={toggle}
            title={dark ? 'Modo claro' : 'Modo oscuro'}
            className="p-2 rounded-lg transition-colors cursor-pointer
              text-slate-500 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-white/8 hover:text-slate-800 dark:hover:text-slate-200">
            {dark ? <Sun size={18} /> : <Moon size={18} />}
          </button>
        </header>

        {/* Offline banner */}
        {!online && (
          <div className="flex items-center gap-2 px-4 py-2 bg-red-500 text-white text-xs font-semibold flex-shrink-0">
            <WifiOff size={13} />
            Sin conexión — algunas funciones pueden no estar disponibles
          </div>
        )}

        {/* Content */}
        <main className="flex-1 min-h-0 overflow-y-auto"
          style={{ paddingBottom: 'env(safe-area-inset-bottom)' }}>
          {children}
        </main>
      </div>

      {/* Inactivity warning */}
      {inactivityWarning && (
        <InactivityModal onExtend={extendSession} onLogout={doLogout} />
      )}

      {/* Logout confirm */}
      {showLogoutConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
          <div className="bg-white dark:bg-[#1A2332] rounded-xl p-7 w-80 shadow-2xl">
            <div className="flex flex-col items-center gap-4">
              <div className="w-14 h-14 rounded-full bg-red-100 dark:bg-red-500/10 flex items-center justify-center">
                <LogOut size={26} className="text-red-500" />
              </div>
              <p className="text-slate-800 dark:text-white font-semibold text-center">¿Cerrar sesión?</p>
              <div className="flex gap-3 w-full mt-1">
                <button onClick={() => setShowLogoutConfirm(false)}
                  className="flex-1 py-2.5 border border-slate-300 dark:border-white/10 rounded-lg text-slate-700 dark:text-slate-300 text-sm hover:bg-slate-50 dark:hover:bg-white/5 cursor-pointer">
                  Cancelar
                </button>
                <button onClick={confirmLogout}
                  className="flex-1 py-2.5 bg-red-500 hover:bg-red-600 rounded-lg text-white text-sm font-semibold cursor-pointer">
                  Salir
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
