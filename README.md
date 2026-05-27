<h1 align="center">LH Inventario — Frontend</h1>

<p align="center">
  Sistema web de gestión de inventario y activos tecnológicos para <strong>La Hornilla</strong>, empresa agrícola chilena.
  <br/>
  Reemplazó dos aplicaciones separadas de AppSheet por una única plataforma moderna desplegada en la nube.
</p>

<p align="center">
  <a href="https://lh-inventario.lahornilla.cl" target="_blank">
    <img src="https://img.shields.io/badge/🌐 Ver en producción-lh--inventario.lahornilla.cl-16a34a?style=for-the-badge" alt="Live" />
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/React-19-61DAFB?style=for-the-badge&logo=react&logoColor=black" />
  <img src="https://img.shields.io/badge/Vite-8-646CFF?style=for-the-badge&logo=vite&logoColor=white" />
  <img src="https://img.shields.io/badge/Tailwind_CSS-3-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase_Hosting-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Axios-5A29E4?style=for-the-badge&logo=axios&logoColor=white" />
  <img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black" />
</p>

---

## Contexto

La Hornilla gestionaba su inventario a través de dos aplicaciones independientes en AppSheet: **LH Toner** (insumos de impresión) y **LH Inventario** (activos tecnológicos). La información estaba dispersa, los flujos eran separados y la plataforma tenía limitaciones importantes para el crecimiento de la empresa.

Este proyecto unificó ambas herramientas en un sistema propio, desarrollado desde cero, con una interfaz moderna, acceso desde cualquier dispositivo y control total sobre los datos.

---

## Funcionalidades

### 📊 Dashboard
- Resumen en tiempo real del estado del inventario
- Alertas automáticas de stock crítico y stock bajo
- Panel de últimas salidas agrupadas por movimiento
- Tarjetas de métricas con animación de carga

### 📦 Inventario de insumos
- Registro de entradas y salidas de productos
- Control de stock calculado en tiempo real
- Historial completo de movimientos
- Exportación a Excel/CSV

### 💻 Activos tecnológicos
Gestión completa de cuatro categorías de activos:

| Módulo | Descripción |
|---|---|
| **Equipos** | Notebooks, desktops, servidores y mini PCs |
| **Celulares** | Líneas móviles corporativas (Voz y Datos, M2M, BAM) |
| **Tablets** | Dispositivos móviles asignados |
| **Impresoras** | Impresoras en red y USB por ubicación |

Cada módulo incluye:
- Tabla con búsqueda y paginación
- Modal de detalle por activo
- Formulario wizard por pasos para crear/editar
- Eliminación con confirmación
- Exportación a Excel

### 🎨 UX / Interfaz
- Modo oscuro y modo claro con persistencia
- Diseño responsive (móvil y escritorio)
- Skeleton loaders durante la carga de datos
- Notificaciones toast para feedback de acciones
- Atajos de teclado (Escape para cerrar modales)

### 🔐 Autenticación
- Login con JWT
- Refresh token automático sin cerrar sesión
- Rutas protegidas
- Cierre de sesión con revocación de token

---

## Stack tecnológico

| Categoría | Tecnología |
|---|---|
| Framework UI | React 19 |
| Build tool | Vite 8 |
| Estilos | Tailwind CSS 3 |
| Routing | React Router DOM 7 |
| HTTP client | Axios 1 |
| Iconos | Lucide React |
| Notificaciones | React Hot Toast |
| Hosting | Firebase Hosting |
| CI/CD | Firebase CLI |

---

## Estructura del proyecto

```
src/
├── assets/               # Imágenes y recursos estáticos
├── components/
│   ├── Layout.jsx            # Sidebar + estructura principal
│   └── PaginaActivos.jsx     # Componente genérico reutilizable para todos los activos
├── context/
│   ├── AuthContext.jsx        # Estado global de autenticación
│   ├── ThemeContext.jsx       # Estado global de tema (dark/light)
│   └── useAuth.js
├── pages/
│   ├── Home.jsx               # Dashboard
│   ├── Login.jsx
│   ├── Entrada.jsx            # Registro de entradas de inventario
│   ├── Salida.jsx             # Registro de salidas de inventario
│   ├── Inventario.jsx         # Vista de stock actual
│   ├── Productos.jsx          # Catálogo de productos
│   ├── Equipos.jsx
│   ├── Celulares.jsx
│   ├── Tablets.jsx
│   └── Impresoras.jsx
├── services/
│   ├── apiClient.js           # Axios + interceptores JWT y refresh automático
│   ├── authApi.js
│   ├── activosApi.js          # Equipos, celulares, tablets, impresoras
│   ├── inventarioApi.js
│   ├── movimientosApi.js
│   └── catalogosApi.js
└── utils/
    └── csv.js                 # Helpers para exportación y formateo de fechas
```

---

## Variables de entorno

Crear un archivo `.env` en la raíz del proyecto:

```env
VITE_API_URL=https://tu-api.run.app
VITE_API_TIMEOUT=15000
```

---

## Instalación y desarrollo local

```bash
# Instalar dependencias
npm install

# Levantar servidor de desarrollo
npm run dev

# Compilar para producción
npm run build
```

---

## Deploy

El proyecto se despliega en **Firebase Hosting**. Los assets estáticos tienen caché de un año (`immutable`), mientras que el HTML se sirve sin caché para garantizar actualizaciones inmediatas.

```bash
npm run build
firebase deploy --only hosting
```

---

## Backend

Este frontend consume una API REST desarrollada en **FastAPI**, desplegada en **Google Cloud Run**.

➡️ Repositorio de la API: [API-LH-INVENTARIO](https://github.com/Straaizo/API-LH-INVENTARIO)

---

<p align="center">
  Desarrollado por <strong>Enzo Sabattini</strong> · Soporte TI & Desarrollo — La Hornilla
</p>
