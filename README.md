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
│   ├── api_client.dart         # Cliente HTTP (GET/POST/PUT/DELETE), token, ApiResponse
│   ├── login_api.dart          # Login y perfil de usuario
│   ├── products_api.dart       # CRUD productos (PRODUCTOS_LH_TONER)
│   ├── inventario_api.dart     # CRUD inventario (INVENTARIO_LH_TONER)
│   └── entregar_api.dart       # CRUD entregas (ENTREGAR_LH_TONER)
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
| Login       | `POST /api/usuarios_lh_toner/login`| Body: `email`, `password` → token, nombre          |
| Perfil      | `GET /api/usuarios_lh_toner/perfil?email=...` | Nombre del usuario                         |
| Productos   | `/api/productos_lh_toner`          | GET lista, POST crear, PUT `/:id`, DELETE `/:id`  |
| Inventario  | `/api/inventario_lh_toner`         | GET lista, POST añadir stock, PUT/DELETE `/:id`    |
| Entregas    | `/api/entregar_lh_toner`           | GET lista, POST crear (descuenta stock), PUT/DELETE `/:id` |

Los servicios (`login_api`, `products_api`, `inventario_api`, `entregar_api`) parsean las respuestas (listas o objetos anidados como `productos`, `data`, `items`) y devuelven modelos Dart (p. ej. `Producto`, `InventarioItem`, `EntregaItem`). Para entregas, si la cantidad supera el stock, la API puede devolver 400 con `stock_disponible` y `cantidad_solicitada`.

---

## ▶ Cómo funciona la aplicación

1. **Arranque** – `main.dart` muestra la pantalla de **Login**.
2. **Login** – El usuario ingresa email y contraseña. Se llama a `LoginApi.validar()`. Si la API responde éxito, se guarda el token con `ApiClient.setAuthToken()` y se navega a **Página principal** (sin back stack).
3. **Página principal** – Muestra sidebar (Entregar, Inventario, Productos, Salir). El nombre en el header se obtiene con `LoginApi.obtenerNombreUsuario(email)` si hay email. El contenido central cambia según la opción elegida (por defecto: Entregar).
4. **Entregar** – Lista entregas desde `EntregarApi.listar()`, agrupadas por fecha y sucursal. Se pueden crear entregas (descuento en inventario) y exportar la lista a CSV en web.
5. **Inventario** – Lista ítems desde `InventarioApi.listar()` (agrupados por categoría), con opciones para añadir stock, editar y eliminar.
6. **Productos** – Lista productos desde `ProductsApi.listar()` (agrupados por categoría), con CRUD completo.
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
- **API:** Cliente centralizado en `ApiClient` + `ApiConfig`; servicios por dominio (login, productos, inventario, entregas).
- **Flujo:** Login → Página principal (Entregar / Inventario / Productos) → Salir.
- **Backend esperado:** Flask con blueprints para usuarios, productos, inventario y entregas; respuestas JSON y, si aplica, JWT en login.

Si necesitas cambiar la URL del backend, edita **`lib/config/api_config.dart`** (`developmentBaseUrl` y/o `productionBaseUrl`).
