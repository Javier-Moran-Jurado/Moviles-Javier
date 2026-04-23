#  Parcial 2 – Accidentes Tuluá + CRUD Establecimientos

**Estudiante:** Javier Moran Jurado  
**Código:** 230231043  
**Repositorio:** [parcial_2](https://github.com/Javier-Moran-Jurado/parcial_2)  
**Rama:** `feature/parcial_flutter_final`

---

##  Descripción de las APIs utilizadas

### API 1 – Accidentes de Tránsito en Tuluá

- **Fuente:** Datos Abiertos Colombia
- **URL base:** `https://www.datos.gov.co/resource/ezt8-5wyj.json`
- **Método:** GET
- **Parámetro:** `$limit=100000` para obtener la mayor cantidad de registros.
- **Campos relevantes del JSON:**

| Campo | Descripción |
|-------|-------------|
| `clase_de_accidente` | Tipo de accidente (CHOQUE, ATROPELLO, VOLCAMIENTO, etc.) |
| `gravedad_del_accidente` | Con muertos, con heridos, solo daños |
| `barrio_hecho` | Barrio donde ocurrió el accidente |
| `dia` | Día de la semana |
| `hora` | Hora del accidente |
| `area` | Urbana o rural |
| `clase_de_vehiculo` | Tipo de vehículo involucrado |

### API 2 – Establecimientos (Parqueadero)

- **Fuente:** API REST propia del sistema de parqueadero
- **URL base:** `https://parking.visiontic.com.co/api`
- **Documentación:** Swagger
- **Endpoints utilizados:**

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/establecimientos` | Listar todos los establecimientos |
| GET | `/establecimientos/{id}` | Obtener un establecimiento por ID |
| POST | `/establecimientos` | Crear un nuevo establecimiento (multipart/form-data) |
| POST | `/establecimientos/{id}` | Actualizar un establecimiento (con `_method=PUT`) |
| DELETE | `/establecimientos/{id}` | Eliminar un establecimiento |

- **Campos del JSON:**

```json
{
  "id": 1,
  "nombre": "Parqueadero Centro",
  "nit": "900123456-7",
  "direccion": "Calle 10 # 5-20",
  "telefono": "3101234567",
  "logo": "storage/logo.png"
}
```

---

##  Asincronía: Future/async/await vs Isolate

### ¿Cuándo usar cada uno?

| Mecanismo | Cuándo usarlo |
|-----------|---------------|
| **Future / async / await** | Para operaciones de E/S (red, base de datos, archivos) que no consumen mucha CPU. No bloquean la UI porque el tiempo de espera lo gestiona el sistema. |
| **Isolate (o compute)** | Para tareas intensivas en CPU (procesar miles de registros, cálculos complejos). Ejecutan código en un hilo separado, evitando que la UI se congele. |

### ¿Por qué se eligió `compute` para el procesamiento estadístico?

La API de accidentes devuelve hasta **100,000 registros**. Procesar esa cantidad de datos en el hilo principal causaría saltos de frames y una interfaz congelada. Se requiere un **Isolate** para mover esa carga a un segundo plano.

Inicialmente se intentó usar `Isolate.run()` (disponible en Dart 2.19+), pero se presentaron errores de tipo `Illegal argument in isolate message`. Por compatibilidad y simplicidad, se optó por **`compute`** (de `package:flutter/foundation.dart`), que es un wrapper de `Isolate` más fácil de usar y compatible con versiones anteriores de Flutter.

La función `calcularEstadisticas()` se ejecuta en un isolate separado y devuelve un `Map<String, dynamic>` con las cuatro estadísticas necesarias para las gráficas. En consola se imprimen los tiempos de ejecución:

```
[Isolate] Iniciado — 50000 registros recibidos
[Isolate] Completado en 234 ms
```

---

##  Arquitectura y estructura del proyecto

El proyecto sigue una **arquitectura por capas** para separar responsabilidades:

```
lib/
├── config/
│   └── app_router.dart          # Rutas con go_router
├── models/
│   ├── accidente.dart           # Modelo de accidente
│   └── establecimiento.dart     # Modelo de establecimiento
├── services/
│   ├── accidentes_service.dart  # Cliente HTTP para accidentes
│   ├── establecimientos_service.dart # Cliente HTTP para establecimientos
│   └── isolate_helper.dart      # Función de procesamiento estadístico
├── utils/
│   └── url_helper.dart          # Construcción de URLs de logos
├── views/
│   ├── dashboard_screen.dart    # Pantalla principal
│   ├── estadisticas_screen.dart # Gráficas de accidentes
│   ├── establecimiento_list_screen.dart   # Listado de establecimientos
│   ├── establecimiento_detail_screen.dart # Detalle de establecimiento
│   └── establecimiento_form_screen.dart    # Crear/Editar establecimiento
├── themes/                      # (opcional) Estilos globales
└── main.dart                    # Punto de entrada
```

### Capas principales

- **`services/`** – Contiene la lógica de comunicación con ambas APIs usando `Dio`.
- **`models/`** – Define las clases con `fromJson` para parsear respuestas.
- **`views/`** – Pantallas de la interfaz de usuario, cada una con su propio `StatefulWidget`.
- **`config/`** – Configuración de `go_router` con todas las rutas.
- **`utils/`** – Funciones auxiliares (ej. construcción de URLs de imágenes).

### Manejo de estados

Se utiliza `FutureBuilder` y `setState` combinados con `Skeletonizer` para mostrar skeletons mientras cargan los datos. Cada pantalla maneja tres estados:

- **Cargando** → Skeleton o `CircularProgressIndicator`
- **Éxito** → Datos mostrados (gráficas, listas, formularios)
- **Error** → Mensaje de error + botón "Reintentar"

---

##  Rutas implementadas con `go_router`

El archivo `lib/config/app_router.dart` define las siguientes rutas:

| Ruta | Parámetros | Pantalla |
|------|------------|----------|
| `/` | – | `DashboardScreen` |
| `/estadisticas` | – | `EstadisticasScreen` |
| `/establecimientos` | – | `EstablecimientoListScreen` |
| `/establecimiento/crear` | – | `EstablecimientoFormScreen` (creación) |
| `/establecimiento/editar/:id` | `id` (string) | `EstablecimientoFormScreen` (edición) |
| `/establecimiento/:id` | `id` (string) | `EstablecimientoDetailScreen` |

### Ejemplo de navegación

Desde el Dashboard:
```dart
context.pushNamed('estadisticas');
context.pushNamed('establecimientos');
```

Desde el listado hacia el detalle:
```dart
context.pushNamed('establecimiento_detail', pathParameters: {'id': est.id.toString()});
```

Desde el detalle hacia la edición:
```dart
context.pushNamed('establecimiento_editar', pathParameters: {'id': widget.id});
```

---

##  Capturas de pantalla
<img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/39919475-fe7e-40fe-b580-e173ea4ce66b" /> <img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/bbb8ecd2-40d6-48c8-92a7-18e3c56eafa2" /> <img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/6719ba27-b476-4d1a-a80e-4a2126c19a01" /> <img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/ec455110-e085-4c05-9628-4b5431e312dc" /> <img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/ca220664-e001-4301-8441-de3e14d9e20c" /> <img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/03877a18-1421-44b4-9a76-048658389fe6" />

---

##  Ejemplo de respuesta JSON

### API Accidentes (GET)

```json
{
  "clase_de_accidente": "CHOQUE",
  "gravedad_del_accidente": "CON HERIDOS",
  "barrio_hecho": "El Poblado",
  "dia": "SÁBADO",
  "hora": "18:30",
  "area": "URBANA",
  "clase_de_vehiculo": "AUTOMÓVIL"
}
```

### API Establecimientos (GET /establecimientos/1)

```json
{
  "id": 1,
  "nombre": "Parqueadero Centro",
  "nit": "900123456-7",
  "direccion": "Calle 10 # 5-20",
  "telefono": "3101234567",
  "logo": "storage/logos/logo123.png"
}
```


