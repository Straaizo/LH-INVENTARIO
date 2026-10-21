import { useEffect, useState } from 'react'
import { Printer } from 'lucide-react'
import PaginaActivos, { EstadoBadge } from '../components/PaginaActivos'
import { impresorasApi } from '../services/activosApi'
import { listarSucursales } from '../services/catalogosApi'

const COLUMNAS = [
  { key: 'impresora',   label: 'Impresora',   truncate: true },
  { key: 'conexion',    label: 'Conexión' },
  { key: 'sucursal',    label: 'Sucursal',    truncate: true },
  { key: 'responsable', label: 'Responsable', truncate: true },
  { key: 'fecha',       label: 'Fecha' },
  { key: 'estado',      label: 'Estado',      render: v => <EstadoBadge estado={v} /> },
]

const CAMPOS_BASE = [
  { key: 'impresora',   label: 'Impresora',   fullWidth: true },
  { key: 'conexion',    label: 'Conexión' },
  { key: 'sucursal',    label: 'Sucursal' },
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
  { titulo: 'Datos de la impresora', campos: ['impresora', 'conexion', 'sucursal', 'fecha'] },
  { titulo: 'Asignación',            campos: ['responsable', 'estado'] },
]

const FILTROS = [
  { key: 'estado',    label: 'Estado' },
  { key: 'conexion',  label: 'Conexión' },
  { key: 'sucursal',  label: 'Sucursal' },
]

export default function Impresoras() {
  const [sucursales, setSucursales] = useState([])

  useEffect(() => { listarSucursales().then(setSucursales) }, [])

  const campos = CAMPOS_BASE.map(c =>
    c.key === 'sucursal'
      ? { ...c, opciones: sucursales.map(s => ({ value: s.nombre, label: s.nombre })) }
      : c
  )

  return (
    <PaginaActivos
      titulo="Impresoras" subtitulo="Gestión de impresoras corporativas"
      icono={Printer} api={impresorasApi}
      columnas={COLUMNAS} campos={campos} pasos={PASOS} filtros={FILTROS}
      campoId="impresora"
    />
  )
}
