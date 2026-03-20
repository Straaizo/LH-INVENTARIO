# 📦 LH Toner – Sistema de Inventario

Sistema de gestión de inventario desarrollado en **Flutter** para La Hornilla. Permite administrar **productos**, consultar **stock** (**Inventario**), registrar **entradas** de mercadería y **salidas** hacia sucursales/destinos, con autenticación y comunicación con una **API REST (Flask)**.

> **Backend:** el código del servidor suele vivir en la carpeta hermana **`API-LH-TONER`** (mismo workspace). Este README describe sobre todo el **frontend** (`lh_tonner`).

---

## 🚀 Características

- **🔐 Login** – Inicio de sesión con **correo o nombre de usuario** y contraseña. La app envía varias claves compatibles (`correo`, `email`, `nombre_usuario`, `contrasenia`, `password`, etc.). Tras el login se usa **JWT** en el header `Authorization: Bearer`. La API puede devolver códigos de error por campo (`USER_NOT_FOUND`, `WRONG_PASSWORD`, `INVALID_EMAIL`, …) para mostrar mensajes en el formulario.
- **📄 Página principal** – Sidebar (escritorio) o **drawer** (ancho &lt; 700px): **Salida**, **Entrada**, **Inventario**, **Productos**, **Salir**; bienvenida con **nombre** del usuario (desde `/me` con JWT o perfil por correo).
- **📤 Salida** – Registrar movimientos de **salida** (descuento de stock hacia un destino), listar historial **agrupado** (fecha/hora y destino), exportar a **CSV** en web (`file_picker` + descarga en navegador).
- **📥 Entrada** – Registrar **entradas** de stock, listado agrupado, exportación **CSV** en web (misma mecánica que Salida).
- **📋 Inventario** – Vista de **stock actual** desde la API/vista SQL `vw_stock_actual`, listado **agrupado por categoría** (refuerzo con datos de `dim_producto`). **No** incluye “agregar stock” desde esta pantalla: el stock se refleja vía movimientos en **Entrada** / **Salida** (y la vista en BD).
- **📦 Productos** – CRUD de productos (nombre, categoría, etc.) contra.
- **📱 Diseño responsive** – Sidebar fijo en escritorio y drawer en móvil.
- **🌐 Despliegue web** – Build para web y publicación en **Firebase Hosting** en proceso (ej. `lh-toner.web.app`).

---

## 🛠 Tecnologías

| Área       | Tecnología                                      |
|-----------|--------------------------------------------------|
| Frontend  | Flutter, Dart                                   |
| SDK       | `^3.11.0` (ver `pubspec.yaml`)                  |
| Fuentes   | `google_fonts`                                  |
| Archivos  | `file_picker` + utilidades CSV (export en web)   |
| Backend   | API REST **Flask** – blueprints en `API-LH-TONER` |
| Hosting   | Firebase Hosting  / por desplegar                 |

---

## 📂 Estructura del proyecto (Flutter)

```text
lib/
├── main.dart                         # Entrada: tema Material, home → Login
├── config/
│   └── api_config.dart               # URL base API (desarrollo / producción)
├── services/
│   ├── api_client.dart               # HTTP (GET/POST/PUT/DELETE), token, ApiResponse
│   ├── dim_usuario_lh_toner_api.dart # Login, /me, listado usuarios, perfil
│   ├── dim_categoria_lh_toner_api.dart
│   ├── dim_producto_lh_toner_api.dart
│   ├── dim_destino_lh_toner_api.dart
│   ├── dim_tipo_movimiento_lh_toner_api.dart
│   ├── vw_stock_actual_api.dart      # Stock actual (vista)
│   └── fact_movimientos_lh_toner_api.dart  # Entradas, salidas, ajustes → hecho
├── Pages/
│   ├── Login/
│   │   └── Login.dart
│   └── Pag Principal/
│       ├── pagina_principal.dart     # Layout, menú, contenido según opción
│       ├── salida.dart               # Salidas + CSV (web)
│       ├── entrada.dart              # Entradas + CSV (web)
│       ├── inventario.dart           # Solo lectura stock (vw_stock_actual)
│       └── productos.dart            # CRUD productos
└── utils/
    ├── descarga_csv_stub.dart        # No web
    └── descarga_csv_web.dart         # Descarga CSV en navegador
```

---

## 🗄 Base de datos (resumen)

El backend persiste en **MySQL** con esquema tipo **almacén dimensional**: tabla de **hechos** (`FACT_MOVIMIENTOS_LH_TONER`) para movimientos y **dimensiones** (`DIM_*`) para catálogos.

| Componente | Función |
|------------|---------|
| **Dimensiones (`DIM_*`)** | Productos, categorías, destinos, tipos de movimiento, usuarios. |
| **Hecho (`FACT_*`)** | Cada fila = movimiento (cantidad, fechas, producto, tipo, destino, usuario). |
| **`vw_stock_actual`** | Stock consolidado por producto; usa la app en **Inventario** y para elegir producto/cantidad en **Entrada** / **Salida**. |

### Tablas principales (referencia)

| Tabla | Contenido típico |
|-------|------------------|
| `DIM_CATEGORIA_LH_TONER` | Categorías (`id_categoria`, `nombre_categoria`, …). |
| `DIM_PRODUCTO_LH_TONER` | Productos (`id_producto`, `nombre_producto`, `id_categoria`, …). |
| `DIM_DESTINO_LH_TONER` | Sucursales / destinos (`id_destino`, `nombre_destino`, …). |
| `DIM_TIPO_MOVIMIENTO_LH_TONER` | Tipos (entrada, salida, ajuste, …). |
| `DIM_USUARIO_LH_TONER` | Usuarios (`nombre_usuario`, correo, hash contraseña, nombre para mostrar). |
| `FACT_MOVIMIENTOS_LH_TONER` | Movimientos vinculados a producto, tipo, destino, usuario. |

---

## 🔌 Comunicación con la API

### Configuración

Archivo **`lib/config/api_config.dart`**:

- `ApiConfig.developmentBaseUrl` – desarrollo (`flutter run`).
- `ApiConfig.productionBaseUrl` – build release / web por desplegar.

### Rutas que usa el frontend (referencia)

| Uso | Ruta base (ejemplo) |
|-----|---------------------|
| Login | `POST /api_lh_toner/login` (también disponible bajo prefijos compat: `/api/dim_usuario_lh_toner`, `/api/usuarios_lh_toner`) |
| Usuario actual | `GET /api/dim_usuario_lh_toner/me` (JWT) |
| Perfil / nombre | `GET /api/usuarios_lh_toner/perfil?email=` o `correo=` |
| Categorías | `GET /api/dim_categoria_lh_toner` |
| Productos | `/api/dim_producto_lh_toner` (CRUD según backend) |
| Destinos | `GET /api/dim_destino_lh_toner` |
| Tipos movimiento | `GET /api/dim_tipo_movimiento_lh_toner` |
| Stock actual | `GET /api/vw_stock_actual` |
| Movimientos | `/api/fact_movimientos_lh_toner` |


---

## ▶ Flujo de la aplicación

1. **Arranque** – `main.dart` → **Login**.
2. **Login** – `DimUsuarioLhTonerApi.validar()` → token `ApiClient.setAuthToken()` → **Página principal** (sin volver atrás con el stack).
3. **Página principal** – Menú: **Salida**, **Entrada**, **Inventario**, **Productos**, **Salir**. Nombre en cabecera: JWT + `/me` o perfil por email.
4. **Salida** – `FactMovimientosLhTonerApi` (salidas), destinos, stock desde `VwStockActualApi`; CSV en web.
5. **Entrada** – Registro de entradas vía la misma API de movimientos; listado y CSV en web.
6. **Inventario** – `VwStockActualApi` + categorías desde productos; solo consulta.
7. **Productos** – `DimProductoLhTonerApi` (listado agrupado por categoría, CRUD).
8. **Salir** – Confirmación, `ApiClient.setAuthToken(null)` → Login.

---

## ⚙ Requisitos y ejecución

### Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible con **SDK ^3.11.0** (`pubspec.yaml`).
- API Flask accesible en la URL configurada en `api_config.dart`.



## 📄 Resumen

| | |
|--|--|
| **Frontend** | Flutter, Material, responsive |
| **API** | `ApiClient` + `ApiConfig` + servicios `dim_*`, `fact_*`, `vw_*` |
| **Datos** | MySQL (dimensiones + hecho + vista stock); la app solo habla REST |
| **Flujo** | Login → Salida / Entrada / Inventario / Productos → Salir |

**Cambiar URL del backend:** `lib/config/api_config.dart`.




