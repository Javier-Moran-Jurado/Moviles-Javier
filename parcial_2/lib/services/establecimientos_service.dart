import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/establecimiento.dart';

class EstablecimientosService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['PARQUEADERO_API_URL'] ?? '';

  Future<List<Establecimiento>> getAll() async {
    final response = await _dio.get('$baseUrl/establecimientos');
    if (response.statusCode == 200) {
      dynamic data = response.data;
      if (data is Map) {
        if (data.containsKey('data')) {
          data = data['data'];
        } else if (data.containsKey('establecimientos')) {
          data = data['establecimientos'];
        } else {
          throw Exception('Formato inesperado: no se encontró una lista');
        }
      }
      if (data is List) {
        return data.map((json) => Establecimiento.fromJson(json)).toList();
      } else {
        throw Exception('Se esperaba una lista, se obtuvo ${data.runtimeType}');
      }
    } else {
      throw Exception('Error al cargar establecimientos: ${response.statusCode}');
    }
  }

  Future<Establecimiento> getById(int id) async {
    final response = await _dio.get('$baseUrl/establecimientos/$id');
    if (response.statusCode == 200) {
      dynamic data = response.data;
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }
      return Establecimiento.fromJson(data);
    } else {
      throw Exception('Error al cargar detalle: ${response.statusCode}');
    }
  }

  Future<Establecimiento> create(FormData formData) async {
    final response = await _dio.post(
      '$baseUrl/establecimientos',
      data: formData,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic data = response.data;
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }
      return Establecimiento.fromJson(data);
    } else {
      throw Exception('Error al crear: ${response.statusCode}');
    }
  }

  Future<Establecimiento> update(int id, FormData formData) async {
    final newFormData = FormData();

    // Sin _method=PUT — POST directo
    for (final field in formData.fields) {
      if (field.key != '_method') newFormData.fields.add(field);
    }
    for (final file in formData.files) {
      newFormData.files.add(file);
    }

    print('=== URL: $baseUrl/establecimientos/$id');
    print('=== FIELDS: ${newFormData.fields.map((e) => '${e.key}=${e.value}').toList()}');
    print('=== FILES: ${newFormData.files.map((e) => e.key).toList()}');

    final response = await _dio.post(
      '$baseUrl/establecimientos/$id',
      data: newFormData,
      options: Options(
        headers: {'Accept': 'application/json'},
        validateStatus: (status) => true,
      ),
    );

    print('=== STATUS: ${response.statusCode}');
    print('=== RESPONSE: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic data = response.data;
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }
      return Establecimiento.fromJson(data);
    } else {
      throw Exception('Error al actualizar: ${response.statusCode} - ${response.data}');
    }
  }

  Future<void> delete(int id) async {
    final response = await _dio.delete('$baseUrl/establecimientos/$id');
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar: ${response.statusCode}');
    }
  }
}