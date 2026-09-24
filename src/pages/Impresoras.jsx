import { Printer } from 'lucide-react'
import PaginaActivos, { EstadoBadge } from '../components/PaginaActivos'
import { impresorasApi } from '../services/activosApi'

const COLUMNAS = [
  { key: 'impresora',   label: 'Impresora',   truncate: true },
  { key: 'conexion',    label: 'Conexión' },
  { key: 'ubicacion',   label: 'Ubicación',   truncate: true },
  { key: 'responsable', label: 'Responsable', truncate: true },
  { key: 'fecha',       label: 'Fecha' },
  { key: 'estado',      label: 'Estado',      render: v => <EstadoBadge estado={v} /> },
]

const CAMPOS = [
  { key: 'impresora',   label: 'Impresora',   fullWidth: true },
  { key: 'conexion',    label: 'Conexión' },
  { key: 'ubicacion',   label: 'Ubicación' },
  { key: 'fecha',       label: 'Fecha' },
  { key: 'responsable', label: 'Responsable', fullWidth: true },
  {
    key: 'estado', label: 'Estado',
    opciones: [
      { value: 'Asignado',      label: 'Asignado' },
      { value: 'De baja',       label: 'De baja' },
      { value: 'En reparación', label: 'En reparación' },
      { value: 'Inactivo',      label: 'Inactivo' },
    ],
  },
]

const PASOS = [
  { titulo: 'Datos de la impresora', campos: ['impresora', 'conexion', 'ubicacion', 'fecha'] },
  { titulo: 'Asignación',            campos: ['responsable', 'estado'] },
]

const FILTROS = [
  { key: 'estado',    label: 'Estado' },
  { key: 'conexion',  label: 'Conexión' },
  { key: 'ubicacion', label: 'Ubicación' },
]

export default function Impresoras() {
  return (
    <PaginaActivos
      titulo="Impresoras" subtitulo="Gestión de impresoras corporativas"
      icono={Printer} api={impresorasApi}
      columnas={COLUMNAS} campos={CAMPOS} pasos={PASOS} filtros={FILTROS}
      campoId="impresora"
    />
  )
}
