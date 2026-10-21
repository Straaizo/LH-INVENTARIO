import { useEffect, useState } from 'react'
import { Monitor } from 'lucide-react'
import PaginaActivos, { EstadoBadge } from '../components/PaginaActivos'
import { equiposApi } from '../services/activosApi'
import { listarSucursales } from '../services/catalogosApi'

const COLUMNAS = [
  { key: 'codigo',      label: 'Código',      truncate: true },
  { key: 'tipo',        label: 'Tipo' },
  { key: 'marca',       label: 'Marca' },
  { key: 'modelo',      label: 'Modelo',      truncate: true },
  { key: 'estado',      label: 'Estado',      render: v => <EstadoBadge estado={v} /> },
  { key: 'responsable', label: 'Responsable', truncate: true },
]

const CAMPOS_BASE = [
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
  { key: 'sucursal',         label: 'Sucursal',     fullWidth: true },
  { key: 'responsable',      label: 'Responsable',  fullWidth: true },
  { key: 'comentario',       label: 'Comentario',   fullWidth: true, opcional: true },
  {
    key: 'estado', label: 'Estado',
    opciones: [
      { value: 'Asignado',      label: 'Asignado' },
      { value: 'Disponible',    label: 'Disponible' },
      { value: 'En reparación', label: 'En reparación' },
      { value: 'De baja',       label: 'De baja' },
      { value: 'Inactivo',      label: 'Inactivo' },
      { value: 'Robado',        label: 'Robado' },
    ],
  },
]

const FILTROS = [
  { key: 'estado',    label: 'Estado' },
  { key: 'tipo',      label: 'Tipo' },
  { key: 'marca',     label: 'Marca' },
  { key: 'sucursal',  label: 'Sucursal' },
]

const PASOS = [
  { titulo: 'Identificación', campos: ['codigo', 'tipo', 'marca', 'modelo'] },
  { titulo: 'Hardware',       campos: ['procesador', 'ram', 'discoDuro', 'sistemaOperativo'] },
  { titulo: 'Software',       campos: ['office', 'antivirus', 'numeroSerie', 'fechaRevision'] },
  { titulo: 'Asignación',     campos: ['sucursal', 'responsable', 'estado', 'comentario'] },
]

export default function Equipos() {
  const [sucursales, setSucursales] = useState([])

  useEffect(() => { listarSucursales().then(setSucursales) }, [])

  const campos = CAMPOS_BASE.map(c =>
    c.key === 'sucursal'
      ? { ...c, opciones: sucursales.map(s => ({ value: s.nombre, label: s.nombre })) }
      : c
  )

  return (
    <PaginaActivos
      titulo="Equipos" subtitulo="Gestión de equipos informáticos"
      icono={Monitor} api={equiposApi}
      columnas={COLUMNAS} campos={campos} pasos={PASOS} filtros={FILTROS}
      campoId="codigo"
    />
  )
}
