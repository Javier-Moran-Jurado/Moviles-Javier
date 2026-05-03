# 📱 App Distribution — Firebase App Distribution

> **Ejercicio:** Distribución incremental de APK mediante Firebase App Distribution  
> **Asignatura:** Desarrollo Móvil · 7.° Semestre  
> **Fecha:** 03 de mayo de 2026  
> **Responsables:** Javier Morán Jurado

---

## 📋 Tabla de contenidos

1. [Descripción del flujo](#flujo)
2. [Preparación del APK](#preparacion)
3. [Publicación en Firebase App Distribution](#publicacion)
4. [Versionado](#versionado)
5. [Release Notes](#release-notes)
6. [Bitácora de QA](#bitacora-qa)
7. [Cómo replicar el proceso](#replicar)
8. [Estructura del proyecto](#estructura)

---

## 🔄 Flujo general <a name="flujo"></a>

```
Generar APK (flutter build apk)
        │
        ▼
Firebase App Distribution
  (consola web / CLI)
        │
        ▼
  Invitar Testers
  (correo electrónico)
        │
        ▼
Tester recibe correo
  → instala la app
        │
        ▼
Nueva versión disponible
  → actualización incremental
```

El flujo completo parte de la compilación en modo **release** del proyecto Flutter, pasando por la consola de Firebase para cargar el APK, definir grupos de testers y escribir las *release notes*. Los testers reciben un correo automático con el enlace de descarga e instalación. Al publicar una nueva versión con `versionCode` superior, la consola notifica a los testers la actualización disponible.

---

## 🛠️ Preparación del APK <a name="preparacion"></a>

### 1. Verificar permisos en `AndroidManifest.xml`

El archivo `android/app/src/main/AndroidManifest.xml` ya incluye el permiso mínimo necesario:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Este permiso es requerido para que la app pueda comunicarse con servicios de red (Firebase, backend, etc.).

### 2. Actualizar la versión en `pubspec.yaml`

```yaml
# Versión inicial
version: 1.0.0+1

# Versión actualizada (incremento de patch + build number)
version: 1.0.1+2
```

| Campo | Valor | Descripción |
|-------|-------|-------------|
| `versionName` | `1.0.1` | Versión legible para el usuario |
| `versionCode` | `2` | Código de build para Android (debe ser siempre mayor) |

### 3. Generar el APK de release

```bash
# Limpiar compilaciones anteriores (recomendado)
flutter clean

# Obtener dependencias
flutter pub get

# Generar APK de release
flutter build apk --release
```

El APK generado se ubica en:
```
build/app/outputs/flutter-apk/app-release.apk
```

> **Nota:** El proyecto usa `signingConfig = signingConfigs.getByName("debug")` para el release.  
> En producción real, se debe configurar una clave de firma propia en `build.gradle.kts`.

---

## 🚀 Publicación en Firebase App Distribution <a name="publicacion"></a>

### Opción A — Consola Web (Manual)

1. Ir a [console.firebase.google.com](https://console.firebase.google.com)
2. Seleccionar el proyecto → **App Distribution**
3. Clic en **"Subir"** y seleccionar `app-release.apk`
4. Escribir las *Release Notes* (ver sección más abajo)
5. Seleccionar grupo(s) de testers o agregar correos
6. Clic en **"Distribuir"** → los testers reciben correo automáticamente

### Opción B — Firebase CLI (Automatizado)

```bash
# Instalar Firebase CLI (si aún no está instalado)
npm install -g firebase-tools

# Autenticar
firebase login

# Distribuir el APK
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <FIREBASE_APP_ID> \
  --release-notes "v1.0.1 - Corrección de permisos y mejoras de estabilidad" \
  --groups "testers-internos"
```

### Pasos que siguen los Testers

1. Reciben un **correo de Firebase** con el asunto *"[Nombre App] — Nueva versión disponible"*
2. Hacen clic en **"Descargar la última versión"**
3. En Android: habilitan *"Instalar apps de fuentes desconocidas"* (sólo la primera vez)
4. Instalan el APK descargado
5. Para actualizaciones: el correo llega automáticamente al publicar una nueva versión

---

## 🔢 Versionado <a name="versionado"></a>

Se usa el formato estándar de Flutter/Android:

```
version: <versionName>+<versionCode>
```

### Historial de versiones

| versionName | versionCode | Descripción | Fecha |
|-------------|-------------|-------------|-------|
| `1.0.0` | `1` | Versión inicial — contador básico | 03/05/2026 |
| `1.0.1` | `2` | Añadido permiso INTERNET · descripción actualizada | 03/05/2026 |

### Reglas de versionado

- **`versionCode`**: Entero que **siempre** debe incrementarse. Android lo usa para detectar actualizaciones.
- **`versionName`**: Cadena legible. Sigue semántica `MAJOR.MINOR.PATCH`.
  - `MAJOR` → cambios incompatibles / rediseño completo
  - `MINOR` → nuevas funcionalidades
  - `PATCH` → correcciones de bugs / mejoras menores

---

## 📝 Release Notes <a name="release-notes"></a>

### Formato recomendado

```
v{versionName} — {fecha corta}
Responsable(s): {nombre(s)}

✅ Novedades:
- [lista de nuevas funcionalidades]

🐛 Correcciones:
- [lista de bugs resueltos]

⚠️ Conocido / Pendiente:
- [limitaciones conocidas en esta versión]
```

---

### Release Notes — v1.0.0 (build 1)

```
v1.0.0 — 03/05/2026
Responsable: Javier Morán Jurado

✅ Novedades:
- Versión inicial del proyecto Flutter.
- Contador interactivo con FloatingActionButton.
- Tema Material Design con colorScheme deepPurple.

⚠️ Conocido / Pendiente:
- Permiso INTERNET no declarado aún.
- Sin firma de release configurada (usa debug key).
```

---

### Release Notes — v1.0.1 (build 2)

```
v1.0.1 — 03/05/2026
Responsable: Javier Morán Jurado

✅ Novedades:
- Añadido permiso android.permission.INTERNET en AndroidManifest.xml.
- Descripción del proyecto actualizada en pubspec.yaml.
- versionCode incrementado de 1 → 2 para actualización incremental correcta.

🐛 Correcciones:
- Corrección de configuración de permisos mínimos para conectividad.

⚠️ Conocido / Pendiente:
- signingConfig apunta aún a debug keys (pendiente configurar keystore de producción).
```

---

## 🧪 Bitácora de QA <a name="bitacora-qa"></a>

### v1.0.0 — Pruebas iniciales (03/05/2026)

| # | Escenario | Resultado | Estado |
|---|-----------|-----------|--------|
| 1 | Instalar APK en dispositivo físico Android 11 | App se instala correctamente | ✅ OK |
| 2 | Abrir la app — pantalla inicial visible | Muestra contador en 0 | ✅ OK |
| 3 | Pulsar FAB varias veces | Contador incrementa correctamente | ✅ OK |
| 4 | Rotar pantalla | Estado del contador se preserva | ✅ OK |
| 5 | Verificar que Firebase envió correo a testers | Correo recibido en < 2 min | ✅ OK |

**Incidencias encontradas y resueltas:**

- ⚠️ **Incidencia #1:** El `AndroidManifest.xml` no declaraba `INTERNET`.  
  → **Resolución:** Agregado en `v1.0.1` antes de la segunda distribución.

---

### v1.0.1 — Pruebas de actualización incremental (03/05/2026)

| # | Escenario | Resultado | Estado |
|---|-----------|-----------|--------|
| 1 | Tester con v1.0.0 instalada recibe notificación de v1.0.1 | Correo recibido correctamente | ✅ OK |
| 2 | Instalar v1.0.1 sobre v1.0.0 | Actualización exitosa sin desinstalar | ✅ OK |
| 3 | Verificar versionCode en "Acerca de" del SO | Muestra build 2 | ✅ OK |
| 4 | App funciona tras actualización | Sin regresiones | ✅ OK |

---

## ♻️ Cómo replicar el proceso en el equipo <a name="replicar"></a>

### Requisitos previos

- Flutter SDK `^3.11.0`
- Android SDK configurado (`flutter doctor` sin errores)
- Cuenta de Firebase con proyecto creado y App Distribution habilitado
- Firebase CLI instalado (`npm install -g firebase-tools`)

### Pasos resumidos

```bash
# 1. Clonar el repositorio
git clone <URL_REPO>
cd app_distribution

# 2. Instalar dependencias
flutter pub get

# 3. Incrementar versión en pubspec.yaml
#    Editar: version: X.Y.Z+N  (N debe ser mayor al anterior)

# 4. Generar APK release
flutter clean && flutter build apk --release

# 5. Distribuir via Firebase CLI
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app <FIREBASE_APP_ID> \
  --release-notes "vX.Y.Z — Descripción del cambio" \
  --groups "nombre-grupo-testers"
```

### Variables que cada miembro del equipo debe configurar

| Variable | Dónde obtenerla |
|----------|-----------------|
| `FIREBASE_APP_ID` | Firebase Console → Configuración del proyecto → Apps |
| `nombre-grupo-testers` | Firebase Console → App Distribution → Grupos |

---

## 📁 Estructura del proyecto <a name="estructura"></a>

```
app_distribution/
├── android/
│   └── app/
│       ├── build.gradle.kts          # Configuración de build Android
│       └── src/main/
│           └── AndroidManifest.xml   # Permisos y configuración de la app
├── lib/
│   └── main.dart                     # Punto de entrada de la aplicación
├── pubspec.yaml                      # Dependencias y versión del proyecto
└── README.md                         # Este documento
```

---

## 📚 Referencias

- [Firebase App Distribution — Documentación oficial](https://firebase.google.com/docs/app-distribution)
- [Flutter — Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Android Versioning](https://developer.android.com/studio/publish/versioning)
- [Semantic Versioning](https://semver.org/lang/es/)
