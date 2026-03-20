# 📦 LH Toner – Sistema de Inventario

Sistema de gestión de inventario desarrollado en **Flutter** para La Hornilla. Permite administrar productos, stock e inventario y registrar entregas a sucursales, con autenticación y comunicación con una API REST (Flask).

---

## 🚀 Características

- **🔐 Login** – Inicio de sesión con email y contraseña contra la API. Soporte de token JWT (header `Authorization: Bearer`).
- **📄 Página principal** – Sidebar con navegación a Entregar, Inventario y Productos; bienvenida con nombre del usuario (obtenido desde la API).
- **📤 Entregar** – Registrar entregas a sucursales (descuento de stock), listar entregas agrupadas por fecha/sucursal, exportar a CSV (web).
- **📋 Inventario** – Listar stock por producto/categoría, añadir stock, editar y eliminar ítems. Indicador de stock bajo (≤ 5).
- **📦 Productos** – CRUD de productos (nombre, categoría), listado agrupado por categoría.
- **📱 Diseño responsive** – Sidebar fijo en escritorio y drawer en pantallas &lt; 700px.
- **🌐 Despliegue web** – Build para web y publicación en Firebase Hosting (ej. `lh-toner.web.app`).

---

## 🛠 Tecnologías

| Área        | Tecnología                          |
|------------|--------------------------------------|
| Frontend   | Flutter, Dart               |
| Fuentes    | `google_fonts`                       |
| Archivos   | `file_picker` (export CSV en web)    |
| Backend    | API REST (Flask) – vr sección API  |
| Hosting    | Firebase Hosting      |

---

## 📂 Estructura del proyecto

```text
lib/
├── main.dart                    # Punto de entrada, tema Material, home: Login
├── config/
│   └── api_config.dart         # URL base de la API (dev/prod)
├── services/
│   ├── api_client.dart                    # Cliente HTTP (GET/POST/PUT/DELETE), token, ApiResponse
│   ├── dim_usuario_lh_toner_api.dart      # Login y perfil (/me + /perfil)
│   ├── dim_categoria_lh_toner_api.dart    # GET categorías → id_categoria para productos
│   ├── dim_producto_lh_toner_api.dart     # CRUD productos → dim_producto_lh_toner
│   ├── vw_stock_actual_api.dart           # GET vista SQL vw_stock_actual
│   ├── dim_destino_lh_toner_api.dart      # GET destinos/sucursales → dim_destino_lh_toner
│   └── fact_movimientos_lh_toner_api.dart # ENTRADA / SALIDA / ajuste → fact_movimientos_lh_toner
├── Pages/
│   ├── Login/
│   │   └── Login.dart          # Pantalla de login
│   └── Pag Principal/
│       ├── pagina_principal.dart  # Layout, sidebar, contenido según menú
│       ├── entregar.dart       # Entregas + export CSV
│       ├── inventario.dart     # Inventario
│       └── productos.dart      # Productos
└── utils/
    ├── descarga_csv_stub.dart  # Stub para plataformas no web
    └── descarga_csv_web.dart   # Descarga de CSV en navegador
```

---

## 🗄 Base de datos

El backend persiste la información en **MySQL**. El diseño sigue un esquema tipo **almacén dimensional**: una **tabla de hechos** registra cada movimiento de stock y varias **tablas de dimensión** describen productos, categorías, destinos, tipos de movimiento y usuarios.

### Rol en el sistema

| Componente | Función |
|------------|---------|
| **Dimensiones (`DIM_*`)** | Catálogos maestros: qué productos existen, a qué categoría pertenecen, sucursales/destinos, tipos de movimiento (entrada, salida, etc.) y usuarios. |
| **Hecho (`FACT_*`)** | Cada fila es un **movimiento**: cantidad, fecha, vínculos a producto, tipo, destino y usuario que lo registró. |
| **Vista `vw_stock_actual`** | Agrega el stock actual por producto (suele derivarse de movimientos); la app la usa para **Inventario** y para elegir productos al **Entregar**. |

### Tablas principales

| Tabla | Contenido típico |
|-------|------------------|
| `DIM_CATEGORIA_LH_TONER` | Categorías de producto (`id_categoria`, `nombre_categoria`, …). |
| `DIM_PRODUCTO_LH_TONER` | Productos (`id_producto`, `nombre_producto`, FK a categoría `id_categoria`, …). |
| `DIM_DESTINO_LH_TONER` | Sucursales u oficinas destino (`id_destino`, `nombre_destino`, …). |
| `DIM_TIPO_MOVIMIENTO_LH_TONER` | Tipos de operación, p. ej. entradas y salidas (`id_tipo_movimiento`, `nombre_movimiento`, …). |
| `DIM_USUARIO_LH_TONER` | Usuarios de la app: login (`nombre_usuario`), correo, contraseña hash, **nombre** para mostrar en pantalla. |
| `FACT_MOVIMIENTOS_LH_TONER` | Movimientos: cantidad, fecha, `id_producto`, `id_tipo_mov`, `id_destino`, `id_usuario` (quién registró la operación). |

Las columnas exactas deben coincidir con lo definido en MySQL Workbench / scripts de la BD; la API Flask solo **lee y escribe** sobre tablas ya creadas.

### Relaciones (resumen)

- **Producto → categoría:** `DIM_PRODUCTO` referencia `DIM_CATEGORIA` por `id_categoria`.
- **Movimiento → dimensiones:** cada fila en `FACT_MOVIMIENTOS_LH_TONER` apunta a producto, tipo de movimiento, destino (cuando aplica) y usuario.
- **Listado “Entregar”:** las salidas se filtran por tipo de movimiento cuyo nombre contiene “SALIDA”; el nombre mostrado del repartidor puede resolverse cruzando `id_usuario` con `DIM_USUARIO` (nombre para mostrar vs. login).

### Vista de stock

- **`vw_stock_actual`:** expone por producto el stock consolidado que ve la pantalla **Inventario** y el selector de productos en **Entregar**. Debe estar creada en el servidor MySQL y ser coherente con las reglas de negocio (entradas suman, salidas restan, etc., según cómo esté definida la vista).

> **Nota:** La app Flutter no se conecta directamente a MySQL; solo habla con la API REST. Cualquier cambio de esquema (nuevas columnas, índices) se hace en la base de datos y, si hace falta, en los endpoints del backend.

---

## 🔌 Comunicación con la API

### Configuración

La URL base de la API se define en **`lib/config/api_config.dart`**:

- **Desarrollo** (`flutter run`): `ApiConfig.developmentBaseUrl`
- **Release** (ej. app desplegada): `ApiConfig.productionBaseUrl`

### Endpoints utilizados

| Servicio     | Ruta base                         | Uso principal                                      |
|-------------|------------------------------------|----------------------------------------------------|
| Login       | `POST /api/usuarios_lh_toner/login`| Body: `email`, `password` → token, nombre          |
| Perfil      | `GET /api/usuarios_lh_toner/perfil?email=...` | Nombre del usuario                         |
| Productos   | `/api/productos_lh_toner`          | GET lista, POST crear, PUT `/:id`, DELETE `/:id`  |
| Inventario  | `/api/inventario_lh_toner`         | GET lista, POST añadir stock, PUT/DELETE `/:id`    |
| Entregas    | `/api/entregar_lh_toner`           | GET lista, POST crear (descuenta stock), PUT/DELETE `/:id` |

Los servicios (`login_api`, `products_api`, `inventario_api`, `entregar_api`) parsean las respuestas (listas o objetos anidados como `productos`, `data`, `items`) y devuelven modelos Dart (p. ej. `Producto`, `InventarioItem`, `EntregaItem`). Para entregas, si la cantidad supera el stock, la API puede devolver 400 con `stock_disponible` y `cantidad_solicitada`.

---

## ▶ Cómo funciona la aplicación

1. **Arranque** – `main.dart` muestra la pantalla de **Login**.
2. **Login** – El usuario ingresa email y contraseña. Se llama a `DimUsuarioLhTonerApi.validar()`. Si la API responde éxito, se guarda el token con `ApiClient.setAuthToken()` y se navega a **Página principal** (sin back stack).
3. **Página principal** – Muestra sidebar (Entregar, Inventario, Productos, Salir). El nombre en el header se obtiene con `DimUsuarioLhTonerApi.obtenerNombreUsuario(email)` si hay email. El contenido central cambia según la opción elegida (por defecto: Entregar).
4. **Entregar** – Lista salidas con `FactMovimientosLhTonerApi.listarSalidas()`, agrupadas por fecha y destino. Destinos desde `DimDestinoLhTonerApi`. Stock del formulario desde `VwStockActualApi`. Export CSV en web.
5. **Inventario** – `VwStockActualApi.listarConEstado()` / vista `vw_stock_actual`; lista agrupada por categoría (producto + `stock_actual`). **Entregar** – tras guardar o eliminar salida, se incrementa un token para volver a pedir `vw_stock_actual` al reabrir el modal.
6. **Productos** – Lista productos desde `DimProductoLhTonerApi.listar()` (agrupados por categoría), con CRUD completo.
7. **Salir** – Diálogo de confirmación; se limpia el token con `ApiClient.setAuthToken(null)` y se vuelve al Login.

---

## ⚙ Requisitos y ejecución

### Requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (SDK ^3.11.0)
- Backend Flask corriendo y accesible en la URL configurada en `api_config.dart` (misma red o URL pública si aplica)

### Ejecución local

```bash
# Dependencias
flutter pub get

# Web (Chrome)
flutter run -d chrome

# O para otro dispositivo/emulador
flutter run
```

### Build web (para desplegar)

```bash
flutter build web --release
```

La salida queda en `build/web/`. Para publicar en Firebase Hosting, ver **[DEPLOY_FIREBASE.md](DEPLOY_FIREBASE.md)**.

---

## 🌐 Despliegue en Firebase

La app está preparada para Firebase Hosting:

1. `flutter build web --release`
2. `firebase deploy`


---

## 📄 Resumen

- **Frontend:** Flutter (web y multiplataforma), Material 3, diseño responsive.
- **API:** Cliente centralizado en `ApiClient` + `ApiConfig`; servicios nombrados como tablas/vista (`dim_*`, `fact_*`, `vw_*`).
- **Base de datos:** MySQL con tablas `DIM_*`, hecho `FACT_MOVIMIENTOS_LH_TONER` y vista `vw_stock_actual` (sección **Base de datos** más arriba en este README).
- **Flujo:** Login → Página principal (Entregar / Inventario / Productos) → Salir.
- **Backend esperado:** Flask con blueprints para usuarios, productos, inventario y entregas; respuestas JSON y, si aplica, JWT en login.

Si necesitas cambiar la URL del backend, edita **`lib/config/api_config.dart`** (`developmentBaseUrl` y/o `productionBaseUrl`).
