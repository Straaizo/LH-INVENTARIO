import { Monitor } from 'lucide-react'
import PaginaActivos, { EstadoBadge } from '../components/PaginaActivos'
import { equiposApi } from '../services/activosApi'

const COLUMNAS = [
  { key: 'codigo',      label: 'Código',      truncate: true },
  { key: 'tipo',        label: 'Tipo' },
  { key: 'marca',       label: 'Marca' },
  { key: 'modelo',      label: 'Modelo',      truncate: true },
  { key: 'estado',      label: 'Estado',      render: v => <EstadoBadge estado={v} /> },
  { key: 'responsable', label: 'Responsable', truncate: true },
]

const CAMPOS = [
  { key: 'codigo',           apiKey: 'codigo_equipo',     label: 'Código' },
  { key: 'tipo',             label: 'Tipo' },
  { key: 'marca',            label: 'Marca' },
  { key: 'modelo',           label: 'Modelo' },
  { key: 'procesador',       label: 'Procesador' },
  { key: 'ram',              label: 'RAM' },
  { key: 'discoDuro',        apiKey: 'disco_duro',        label: 'Disco Duro' },
  { key: 'sistemaOperativo', apiKey: 'sistema_operativo', label: 'Sistema Operativo' },
  { key: 'office',           label: 'Office' },
  { key: 'antivirus',        label: 'Antivirus' },
  { key: 'numeroSerie',      apiKey: 'numero_serie',      label: 'N° Serie' },
  { key: 'fechaRevision',    apiKey: 'fecha_revision',    label: 'Fecha revisión' },
  { key: 'ubicacion',        label: 'Ubicación',    fullWidth: true },
  { key: 'responsable',      label: 'Responsable',  fullWidth: true },
  {
    key: 'estado', label: 'Estado',
    opciones: [
      { value: 'Activo',        label: 'Activo' },
      { value: 'En reparación', label: 'En reparación' },
      { value: 'De baja',       label: 'De baja' },
      { value: 'Inactivo',      label: 'Inactivo' },
      { value: 'Robado',        label: 'Robado' },
    ],
  },
]

const PASOS = [
  { titulo: 'Identificación', campos: ['codigo', 'tipo', 'marca', 'modelo'] },
  { titulo: 'Hardware',       campos: ['procesador', 'ram', 'discoDuro', 'sistemaOperativo'] },
  { titulo: 'Software',       campos: ['office', 'antivirus', 'numeroSerie', 'fechaRevision'] },
  { titulo: 'Asignación',     campos: ['ubicacion', 'responsable', 'estado'] },
]

export default function Equipos() {
  return (
    <PaginaActivos
      titulo="Equipos" subtitulo="Gestión de equipos informáticos"
      icono={Monitor} api={equiposApi}
      columnas={COLUMNAS} campos={CAMPOS} pasos={PASOS}
      campoId="codigo"
    />
  )
}
