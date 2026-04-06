# 📦 LH Inventario – Sistema unificado de gestión

![Flutter](https://img.shields.io/badge/Flutter-3.11-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11-green?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

Sistema de gestión de inventario desarrollado en **Flutter** para La Hornilla. Permite administrar **productos**, consultar **stock**, registrar **entradas** y **salidas** de mercadería, y generar reportes en **CSV**.

> **Backend relacionado:** API REST en Flask — código en carpeta hermana **`API-BASE-LH`**

---

## 🚀 Características principales

- **🔐 Autenticación JWT** – Login con correo o usuario + contraseña; sesión persistente
- **📊 Dashboard intuitivo** – Sidebar (desktop) / Drawer (móvil); bienvenida personalizada
- **📤 Gestión de salidas** – Registrar movimientos a destinos, historial agrupado, exportar a CSV
- **📥 Gestión de entradas** – Ingresar stock, listado agrupado, exportación a CSV
- **📋 Inventario en tiempo real** – Vista de stock actual desde BD, agrupado por categoría
- **📦 CRUD de productos** – Crear, editar, eliminar productos + categorías
- **🌐 Diseño responsive** – Optimizado para móvil, tablet y desktop
- **💾 Persistencia de sesión** – Token JWT almacenado localmente

---

## ⚙️ Requisitos previos

- **Flutter SDK** 3.11.0 o superior ([Descargar](https://flutter.dev/docs/get-started/install))
- **Dart** 3.11.0+ (incluido en Flutter)
- **API REST** accesible en la URL configurada
- Conexión a Internet (para consumir API)

---
