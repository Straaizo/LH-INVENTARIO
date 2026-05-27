import { Smartphone } from 'lucide-react'
import PaginaActivos, { EstadoBadge } from '../components/PaginaActivos'
import { celularesApi } from '../services/activosApi'

const COLUMNAS = [
  { key: 'numero',      label: 'Número' },
  { key: 'marca',       label: 'Marca' },
  { key: 'modelo',      label: 'Modelo',      truncate: true },
  { key: 'compania',    label: 'Compañía' },
  { key: 'imei',        label: 'IMEI',         truncate: true },
  { key: 'responsable', label: 'Responsable',  truncate: true },
  { key: 'estado',      label: 'Estado',       render: v => <EstadoBadge estado={v} /> },
]

const CAMPOS = [
  { key: 'numero',        label: 'Número' },
  { key: 'identificador', label: 'Identificador' },
  { key: 'marca',         label: 'Marca' },
  { key: 'modelo',        label: 'Modelo' },
  { key: 'tipoCelular',   apiKey: 'tipo_celular', label: 'Tipo' },
  { key: 'compania',      label: 'Compañía' },
  { key: 'imei',          label: 'IMEI' },
  { key: 'fechaEntrega',  apiKey: 'fecha_entrega', label: 'Fecha entrega' },
  { key: 'responsable',   label: 'Responsable', fullWidth: true },
  {
    key: 'estado', label: 'Estado',
    opciones: [
      { value: 'Activo',        label: 'Activo' },
      { value: 'De baja',       label: 'De baja' },
      { value: 'En reparación', label: 'En reparación' },
      { value: 'Inactivo',      label: 'Inactivo' },
    ],
  },
]

const PASOS = [
  { titulo: 'Identificación', campos: ['numero', 'identificador', 'marca', 'modelo', 'tipoCelular'] },
  { titulo: 'Detalles',       campos: ['compania', 'imei', 'fechaEntrega'] },
  { titulo: 'Asignación',     campos: ['responsable', 'estado'] },
]

export default function Celulares() {
  return (
    <PaginaActivos
      titulo="Celulares" subtitulo="Gestión de celulares corporativos"
      icono={Smartphone} api={celularesApi}
      columnas={COLUMNAS} campos={CAMPOS} pasos={PASOS}
      campoId="numero"
    />
  )
}
