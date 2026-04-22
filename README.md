# Taller 4: * Peticiones HTTP y Consumo de API Pública en Flutter

**Estudiante:** Javier Moran Jurado  
**Código:** 230231043  
**Repositorio:** [parcial_2_datos_abiertos](https://github.com/Javier-Moran-Jurado/parcial_2_datos_abiertos)  
**Rama:** `feature/parcial_api_colombia`

---

##  Descripción de la API y endpoints seleccionados

La aplicación consume la **API Colombia** (`https://api-colombia.com/api/v1`), una API REST pública que proporciona información geográfica, cultural, histórica y turística del país.

### Endpoints utilizados

| Endpoint | Recurso | Descripción |
|----------|---------|-------------|
| `President` | Presidentes de Colombia | Nombre, partido político, período y descripción. |
| `NaturalArea` | Áreas naturales protegidas | Nombre, área terrestre (hectáreas), ID del departamento, códigos DANE, etc. |
| `TypicalDish` | Platos típicos | Nombre, descripción, ingredientes y departamento. |
| `Airport` | Aeropuertos | Nombre, código IATA, tipo, ciudad, departamento, coordenadas. |

> **Nota:** La API no proporciona un campo `description` para el endpoint `NaturalArea`. Por ello, en el detalle se muestran los campos disponibles reales.

---

##  Arquitectura y estructura del proyecto
lib/
├── config/
│ └── app_router.dart # Rutas con go_router
├── services/
│ └── api_service.dart # Cliente HTTP (consumo de endpoints)
├── views/
│ ├── dashboard_screen.dart # Pantalla principal (cards)
│ ├── list_screen.dart # Listado genérico con estados
│ └── detail_screen.dart # Detalle con información completa
├── themes/ # (opcional) Estilos globales
├── widgets/ # (opcional) Componentes reutilizables
└── main.dart # Punto de entrada


### Manejo de estados

Se utiliza `FutureBuilder` combinado con una **barra de estado visual** que muestra explícitamente:

- **Cargando** (naranja) → `CircularProgressIndicator`
- **Éxito** (verde) → datos mostrados
- **Error** (rojo) → mensaje de error + botón "Reintentar"

Esto cumple con el requisito de evidenciar los tres estados en la interfaz.

---

##  Capturas de pantalla

<img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/0b23ff13-dd1f-41fd-b8ee-46821c6a81b2" />
<img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/bd8cf3c2-dc3e-4986-ab17-d39ef54beb58" />
<img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/a2ee8659-40e7-4ad8-9c15-3ecadaf9e1f8" />
<img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/fce5eeb5-1384-43f8-949d-ed7d0ee88e76" />
---

## Rutas implementadas con `go_router`

El archivo `lib/config/app_router.dart` define las siguientes rutas:

| Ruta | Parámetros | Pantalla |
|------|------------|----------|
| `/` | – | `DashboardScreen` |
| `/list/:endpoint` | `endpoint` (string) | `ListScreen` |
| `/detail/:endpoint/:id` | `endpoint`, `id` (string) | `DetailScreen` |

## Ejemplo de respuesta Json
Endpoint: President (GET)
{
  "id": 1,
  "name": "Simón Bolívar",
  "politicalParty": "Independentista",
  "period": "1819-1830",
  "description": "Libertador de Colombia, Venezuela, Ecuador y Perú."
}
Documentación completa: Swagger API Colombia
