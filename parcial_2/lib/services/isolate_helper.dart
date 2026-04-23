
import '../models/accidente.dart';

Map<String, dynamic> calcularEstadisticas(List<dynamic> rawData) {
  final stopwatch = Stopwatch()..start();
  print('[Isolate] Iniciado — ${rawData.length} registros recibidos');

  Map<String, int> clase = {};
  Map<String, int> gravedad = {};
  Map<String, int> barrios = {};
  Map<String, int> dias = {};

  for (var item in rawData) {
    final acc = Accidente.fromJson(item);

    // Clase de accidente (normalizado a mayúsculas)
    if (acc.clase != null) {
      String key = acc.clase!.toUpperCase();
      if (key.contains('CHOQUE')) key = 'Choque';
      else if (key.contains('ATROPELLO')) key = 'Atropello';
      else if (key.contains('VOLCAMIENTO')) key = 'Volcamiento';
      else key = 'Otros';
      clase[key] = (clase[key] ?? 0) + 1;
    }

    // Gravedad
    if (acc.gravedad != null) {
      String g = acc.gravedad!.toUpperCase();
      if (g.contains('MUERTO')) g = 'Con muertos';
      else if (g.contains('HERIDO')) g = 'Con heridos';
      else g = 'Solo daños';
      gravedad[g] = (gravedad[g] ?? 0) + 1;
    }

    // Barrios
    if (acc.barrio != null && acc.barrio!.trim().isNotEmpty) {
      barrios[acc.barrio!] = (barrios[acc.barrio!] ?? 0) + 1;
    }

    // Días
    if (acc.dia != null && acc.dia!.trim().isNotEmpty) {
      dias[acc.dia!] = (dias[acc.dia!] ?? 0) + 1;
    }
  }

  // Top 5 barrios
  final topBarrios = barrios.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top5Barrios = Map.fromEntries(topBarrios.take(5));

  final resultado = {
    'clase': clase,
    'gravedad': gravedad,
    'barrios': top5Barrios,
    'dias': dias,
  };

  stopwatch.stop();
  print('[Isolate] Completado en ${stopwatch.elapsedMilliseconds} ms');
  return resultado;
}