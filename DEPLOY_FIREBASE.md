# Despliegue en Firebase Hosting (LH Toner)

Pasos para publicar la app Flutter web en Firebase.

## Requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado
- [Firebase CLI](https://firebase.google.com/docs/cli) instalado
- Cuenta de Google

## 1. Instalar Firebase CLI (si no lo tienes)

```bash
npm install -g firebase-tools
```

## 2. Iniciar sesión en Firebase

Desde la carpeta del proyecto (`lh_tonner`):

```bash
cd lh_tonner
firebase login
```

Abre el enlace en el navegador y autoriza con tu cuenta de Google.

## 3. Vincular el proyecto con Firebase

Si aún no tienes un proyecto en [Firebase Console](https://console.firebase.google.com/):

1. Entra en la consola y crea un proyecto (o usa uno existente).
2. En la consola, activa **Hosting** en “Compilación” → “Hosting” → “Comenzar”.

Luego, en la terminal, vincula esta carpeta a tu proyecto:

```bash
firebase use --add
```

Elige el proyecto y asígnale el alias `default`.  
Si ya editaste `.firebaserc` y pusiste tu ID de proyecto, no hace falta este paso.

**Importante:** Si en `.firebaserc` sigue `"tu-proyecto-firebase"`, cámbialo por el ID real de tu proyecto (lo ves en la consola de Firebase, en “Configuración del proyecto”).

## 4. Compilar la app Flutter para web

```bash
flutter pub get
flutter build web --release
```

La salida quedará en `build/web/`, que es la carpeta que usa Firebase Hosting.

## 5. Desplegar

```bash
firebase deploy
```

Al terminar, la CLI mostrará la URL de tu sitio (por ejemplo `https://tu-proyecto.web.app`).

---

## Resumen de comandos (desde `lh_tonner`)

```bash
firebase login
firebase use --add          # solo la primera vez
flutter build web --release
firebase deploy
```

## Siguientes despliegues

Solo necesitas:

```bash
flutter build web --release
firebase deploy
```
