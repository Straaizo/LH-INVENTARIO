import { useEffect, useState } from 'react'
import { Smartphone } from 'lucide-react'
import PaginaActivos, { EstadoBadge } from '../components/PaginaActivos'
import { celularesApi } from '../services/activosApi'
import { listarSucursales } from '../services/catalogosApi'

const COLUMNAS = [
  { key: 'numero',      label: 'Número' },
  { key: 'marca',       label: 'Marca' },
  { key: 'modelo',      label: 'Modelo',      truncate: true },
  { key: 'compania',    label: 'Compañía' },
  { key: 'imei',        label: 'IMEI',         truncate: true },
  { key: 'responsable', label: 'Responsable',  truncate: true },
  { key: 'identificador', label: 'Identificador', truncate: true },
  { key: 'estado',      label: 'Estado',       render: v => <EstadoBadge estado={v} /> },
]

const CAMPOS_BASE = [
  { key: 'numero',        label: 'Número' },
  { key: 'identificador', label: 'Identificador', opcional: true },
  { key: 'marca',         label: 'Marca' },
  { key: 'modelo',        label: 'Modelo' },
  { key: 'tipoCelular',   apiKey: 'tipo_celular', label: 'Tipo' },
  { key: 'compania',      label: 'Compañía' },
  { key: 'imei',          label: 'IMEI' },
  { key: 'fechaEntrega',  apiKey: 'fecha_entrega', label: 'Fecha entrega' },
  { key: 'responsable',   label: 'Responsable', fullWidth: true },
  { key: 'sucursal',      label: 'Sucursal',    fullWidth: true },
  { key: 'comentario',    label: 'Comentario',  fullWidth: true, opcional: true },
  {
    key: 'estado', label: 'Estado',
    opciones: [
      { value: 'Asignado',      label: 'Asignado' },
      { value: 'Disponible',    label: 'Disponible' },
      { value: 'De baja',       label: 'De baja' },
      { value: 'En reparación', label: 'En reparación' },
      { value: 'Inactivo',      label: 'Inactivo' },
    ],
  },
]

const PASOS = [
  { titulo: 'Identificación', campos: ['numero', 'identificador', 'marca', 'modelo', 'tipoCelular'] },
  { titulo: 'Detalles',       campos: ['compania', 'imei', 'fechaEntrega'] },
  { titulo: 'Asignación',     campos: ['responsable', 'sucursal', 'estado', 'comentario'] },
]

const FILTROS = [
  { key: 'estado',       label: 'Estado' },
  { key: 'tipoCelular',  label: 'Tipo' },
  { key: 'marca',        label: 'Marca' },
  { key: 'compania',     label: 'Compañía' },
  { key: 'sucursal',     label: 'Sucursal' },
]

export default function Celulares() {
  const [sucursales, setSucursales] = useState([])

  useEffect(() => { listarSucursales().then(setSucursales) }, [])

  const campos = CAMPOS_BASE.map(c =>
    c.key === 'sucursal'
      ? { ...c, opciones: sucursales.map(s => ({ value: s.nombre, label: s.nombre })) }
      : c
  )

  return (
    <PaginaActivos
      titulo="Celulares" subtitulo="Gestión de celulares corporativos"
      icono={Smartphone} api={celularesApi}
      columnas={COLUMNAS} campos={campos} pasos={PASOS} filtros={FILTROS}
      campoId="numero"
    />
  )
}
