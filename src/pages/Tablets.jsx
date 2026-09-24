import { Tablet } from 'lucide-react'
import PaginaActivos, { EstadoBadge } from '../components/PaginaActivos'
import { tabletsApi } from '../services/activosApi'

const COLUMNAS = [
  { key: 'codigo',       label: 'Código' },
  { key: 'marca',        label: 'Marca' },
  { key: 'modelo',       label: 'Modelo',      truncate: true },
  { key: 'capacidad',    label: 'Capacidad' },
  { key: 'fechaEntrega', label: 'F. Entrega' },
  { key: 'responsable',  label: 'Responsable', truncate: true },
  { key: 'estado',       label: 'Estado',      render: v => <EstadoBadge estado={v} /> },
]

const CAMPOS = [
  { key: 'codigo',       apiKey: 'codigo_tablet', label: 'Código' },
  { key: 'marca',        label: 'Marca' },
  { key: 'modelo',       label: 'Modelo' },
  { key: 'capacidad',    label: 'Capacidad' },
  { key: 'fechaEntrega', apiKey: 'fecha_entrega', label: 'Fecha entrega' },
  { key: 'responsable',  label: 'Responsable', fullWidth: true },
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
  { titulo: 'Identificación', campos: ['codigo', 'marca', 'modelo', 'capacidad'] },
  { titulo: 'Detalles',       campos: ['fechaEntrega'] },
  { titulo: 'Asignación',     campos: ['responsable', 'estado'] },
]

const FILTROS = [
  { key: 'estado', label: 'Estado' },
  { key: 'marca',  label: 'Marca' },
]

export default function Tablets() {
  return (
    <PaginaActivos
      titulo="Tablets" subtitulo="Gestión de tablets corporativas"
      icono={Tablet} api={tabletsApi}
      columnas={COLUMNAS} campos={CAMPOS} pasos={PASOS} filtros={FILTROS}
      campoId="codigo"
    />
  )
}
