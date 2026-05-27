import { useState } from 'react'
import { Routes, Route, Navigate, useLocation } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from './context/AuthContext'
import { useAuth } from './context/useAuth'
import { ThemeProvider, useTheme } from './context/ThemeContext'
import Layout     from './components/Layout'
import Login      from './pages/Login'
import Home       from './pages/Home'
import Salida     from './pages/Salida'
import Entrada    from './pages/Entrada'
import Inventario from './pages/Inventario'
import Productos  from './pages/Productos'
import Equipos    from './pages/Equipos'
import Celulares  from './pages/Celulares'
import Tablets    from './pages/Tablets'
import Impresoras from './pages/Impresoras'

const PAGE_MAP = {
  dashboard:  <Home />,
  salida:     <Salida />,
  entrada:    <Entrada />,
  inventario: <Inventario />,
  productos:  <Productos />,
  equipos:    <Equipos />,
  celulares:  <Celulares />,
  tablets:    <Tablets />,
  impresoras: <Impresoras />,
}

function AppLayout() {
  const [page, setPage] = useState('dashboard')
  return (
    <Layout page={page} setPage={setPage}>
      {PAGE_MAP[page] ?? <Home />}
    </Layout>
  )
}

function ProtectedRoute({ children }) {
  const { user } = useAuth()
  const location = useLocation()
  if (!user) return <Navigate to="/login" state={{ from: location }} replace />
  return children
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/*" element={
        <ProtectedRoute>
          <AppLayout />
        </ProtectedRoute>
      } />
    </Routes>
  )
}

function ToasterWrapper() {
  const { dark } = useTheme()
  return (
    <Toaster
      position="top-center"
      toastOptions={{
        duration: 3000,
        style: dark
          ? { background: '#1A2332', color: '#e2e8f0', border: '1px solid rgba(255,255,255,0.08)', fontSize: '14px' }
          : { background: '#fff', color: '#1e293b', border: '1px solid #e2e8f0', fontSize: '14px' },
        success: { iconTheme: { primary: '#16a34a', secondary: '#fff' } },
        error:   { iconTheme: { primary: '#ef4444', secondary: '#fff' } },
      }}
    />
  )
}

export default function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <ToasterWrapper />
        <AppRoutes />
      </AuthProvider>
    </ThemeProvider>
  )
}
