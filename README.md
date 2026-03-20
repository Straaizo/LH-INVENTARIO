# 📦 LH Toner – Sistema de Inventario

Sistema de gestión de inventario desarrollado en **Flutter** para La Hornilla. Permite administrar productos, stock e inventario y registrar entregas a sucursales, con autenticación y comunicación con una API REST (Flask).

---

## 🚀 Características

- **🔐 Login** – Inicio de sesión con email y contraseña contra la API. Soporte de token JWT (header `Authorization: Bearer`).
- **📄 Página principal** – Sidebar con Salida, Entrada, Inventario y Productos; bienvenida con nombre del usuario (obtenido desde la API).
- **📤 Salida** – Movimientos SALIDA hacia `dim_destino`, listado agrupado por fecha/destino, exportar a CSV (web).
- **📥 Entrada** – Movimientos ENTRADA (alta de stock): listado agrupado, registro desde `dim_producto` + destino, export CSV.
- **📋 Inventario** – Solo consulta de stock con `GET /api/vw_stock_actual` (`data`), agrupado por categoría. El alta de stock se hace en **Entrada**.
- **📦 Productos** – CRUD de productos (nombre, categoría), listado agrupado por categoría.
- **📱 Diseño responsive** – Sidebar fijo en escritorio y drawer en pantallas &lt; 700px.
- **🌐 Despliegue web** – Build para web y publicación en Firebase Hosting (ej. `lh-toner.web.app`).

---

## 🛠 Tecnologías

| Área        | Tecnología                          |
|------------|--------------------------------------|
| Frontend   | Flutter 3.x, Dart ^3.11              |
| HTTP       | `http`                               |
| Fuentes    | `google_fonts`                       |
| Archivos   | `file_picker` (export CSV en web)    |
| Backend    | API REST (Flask) – ver sección API  |
| Hosting    | Firebase Hosting (opcional)          |

---

## 📂 Estructura del proyecto

```text
lib/
├── main.dart                    # Punto de entrada, tema Material, home: Login
├── config/
│   └── api_config.dart         # URL base de la API (dev/prod), timeout
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
│       ├── salida.dart         # Movimientos salida + export CSV
│       ├── entrada.dart        # Movimientos entrada (stock) + export CSV
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

Por defecto ambas apuntan a `http://192.168.1.225:5000`. Para producción web (HTTPS) conviene usar una URL HTTPS (ngrok o servidor con SSL).

- Timeout: `ApiConfig.timeoutSeconds` (15 s).

### Cliente HTTP (`api_client.dart`)

- **`ApiClient`** centraliza todas las peticiones:
  - `get(path)`, `post(path, [data])`, `put(path, [data])`, `delete(path)`
  - Headers: `Content-Type: application/json`, `Accept: application/json`
  - Si hay token: `Authorization: Bearer <token>` (se guarda con `ApiClient.setAuthToken(token)` tras el login)
- **`ApiResponse`**: `ok`, `statusCode`, `data`, `message`; errores con mensaje desde el backend (`message`, `error`, `msg`).

### Endpoints utilizados

| Servicio     | Ruta base                         | Uso principal                                      |
|-------------|------------------------------------|----------------------------------------------------|
| Login       | `POST /api_lh_toner/login` (o `/api/dim_usuario_lh_toner/login`, `/api/usuarios_lh_toner/login`) | Body: `email`, `contrasenia` → token, `usuario` |
| Perfil      | `GET /api/usuarios_lh_toner/perfil?email=` o `?correo=` (sin JWT) · **`GET /api/dim_usuario_lh_toner/me`** (con JWT, preferido) | `usuario` / `user` con `nombre_usuario` |
| Categorías  | `GET /api/dim_categoria_lh_toner` | Lista para enviar **`id_categoria`** al crear productos |
| Productos   | `/api/dim_producto_lh_toner`     | JSON recomendado: `nombre_producto` + **`id_categoria`** (del GET categorías) |
| Stock (vista) | `/api/vw_stock_actual`         | GET `{ "data": [...] }` → **Inventario** (stock por producto) y **Entregar** (combo); JWT |
| Destinos    | `/api/dim_destino_lh_toner`      | GET → `id_destino`, `nombre_destino`               |
| Movimientos | `/api/fact_movimientos_lh_toner` o `/api/movimientos_lh_toner` | POST con `tipo_movimiento` ENTRADA/SALIDA, `id_producto`, `id_destino`; `.../ajuste`, `.../salidas`; PUT/DELETE por `id_movimientos` |

Contratos: **`docs/API_CONTRATO_LH_TONER.md`**, **`docs/API_BACKEND_MOVIMIENTOS.md`**. Modelos: `DimCategoriaLhToner`, `DimProductoLhToner`, `VwStockActualRow`, `DimDestinoLhTonerRow`, `FactMovimientoListadoItem` (historial si se usa), `FactMovimientoSalidaItem`. Si la cantidad de una SALIDA supera el stock, la API puede responder 400 con `stock_disponible` y `cantidad_solicitada`.

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

La configuración está en `firebase.json` (carpeta `build/web`, rewrites a `index.html` para SPA).  
Pasos detallados, login en Firebase y vinculación del proyecto: **[DEPLOY_FIREBASE.md](DEPLOY_FIREBASE.md)**.

**Nota:** Si la app está en `lh-toner.web.app` (HTTPS), la API en producción debe ser accesible por HTTPS (o CORS configurado según tu caso) para que login y datos funcionen correctamente.

---

## 📄 Resumen

- **Frontend:** Flutter (web y multiplataforma), Material 3, diseño responsive.
- **API:** Cliente centralizado en `ApiClient` + `ApiConfig`; servicios nombrados como tablas/vista (`dim_*`, `fact_*`, `vw_*`).
- **Base de datos:** MySQL con tablas `DIM_*`, hecho `FACT_MOVIMIENTOS_LH_TONER` y vista `vw_stock_actual` (sección **Base de datos** más arriba en este README).
- **Flujo:** Login → Página principal (Entregar / Inventario / Productos) → Salir.
- **Backend esperado:** Flask con blueprints para usuarios, productos, inventario y entregas; respuestas JSON y, si aplica, JWT en login.

Si necesitas cambiar la URL del backend, edita **`lib/config/api_config.dart`** (`developmentBaseUrl` y/o `productionBaseUrl`).
