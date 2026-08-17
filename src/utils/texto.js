export function capitalizarNombre(nombre) {
  if (!nombre) return ''
  return nombre
    .toLowerCase()
    .split(' ')
    .filter(Boolean)
    .map(p => p[0].toUpperCase() + p.slice(1))
    .join(' ')
}
