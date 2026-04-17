# Taller Segundo Plano


## ¿Cuándo usar cada uno?

### Future / async / await
- **Uso**: Operaciones asincrónicas que pueden demorarse pero **no bloquean la UI** (llamadas HTTP, lectura de archivos, consultas a base de datos, `Future.delayed`).
- **Cómo funciona**: `Future` representa un valor que estará disponible en el futuro. `async` marca una función que puede usar `await` para pausar su ejecución sin bloquear el hilo principal.
- **Ventaja**: Sintaxis limpia y fácil manejo de errores con `try-catch`.
- **Ejemplo en el código**: Simulación de un servicio que tarda 2 segundos. Se muestra estado "Cargando...", éxito o error.

### Timer
- **Uso**: Ejecutar código de forma repetitiva o con retraso (cronómetros, cuentas regresivas, polling cada cierto tiempo).
- **Cómo funciona**: `Timer.periodic` dispara una función a intervalos regulares. Se debe **cancelar** (`timer.cancel()`) cuando ya no se necesita (por ejemplo, en `dispose` del State) para evitar fugas de memoria.
- **Características**: No es asincrónico en el sentido de `Future`, sino basado en eventos. La acción se ejecuta en el mismo hilo principal, pero si es liviana no afecta el rendimiento.
- **Ejemplo en el código**: Cronómetro con botones Iniciar, Pausar (cancela el Timer), Reanudar (crea uno nuevo), Reiniciar.

### Isolate
- **Uso**: Cómputo **pesado y síncrono** (CPU-bound) que bloquearía la UI si se ejecuta en el hilo principal: cálculos matemáticos intensivos, procesamiento de imágenes, análisis de grandes listas, etc.
- **Cómo funciona**: Un Isolate es un hilo independiente con su propio heap y ciclo de eventos. No comparte memoria con el hilo principal, se comunican mediante mensajes (`SendPort` / `ReceivePort`).
- **Ventaja**: La UI permanece fluida mientras la tarea pesada corre en segundo plano.
- **Ejemplo en el código**: Suma de 100 millones de números enteros. Se mide el tiempo de ejecución y se muestra en pantalla junto al resultado.

## Diagrama de flujo de pantallas y componentes
<img width="1080" height="537" alt="imagen" src="https://github.com/user-attachments/assets/01df0a97-8180-451a-8d27-88377ac70d43" />
<img width="1080" height="505" alt="imagen" src="https://github.com/user-attachments/assets/fd51808f-ed45-4db0-8d38-2d089d5c116d" />
<img width="1080" height="879" alt="imagen" src="https://github.com/user-attachments/assets/0ac983c4-a5a8-417e-9172-4dc222768d3d" />
<img width="1078" height="842" alt="imagen" src="https://github.com/user-attachments/assets/1cda02e9-2f13-4c12-a7f1-3c2abf5747a6" />
<img width="1080" height="500" alt="imagen" src="https://github.com/user-attachments/assets/296683bf-a012-4aa1-b90e-aa66867507b6" />
<img width="1080" height="545" alt="imagen" src="https://github.com/user-attachments/assets/e3367fd6-659a-4a54-ae57-50a1c9a6e965" />
<img width="720" height="1600" alt="imagen" src="https://github.com/user-attachments/assets/e18c6ff1-69d7-44b4-9119-b54e76b358c3" />





