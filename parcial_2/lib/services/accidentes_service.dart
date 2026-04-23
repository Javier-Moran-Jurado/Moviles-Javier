import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccidentesService {
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['ACCIDENTES_API_URL'] ?? '';

  Future<List<dynamic>> fetchAllAccidentes() async {
    try {
      final response = await _dio.get('$baseUrl?\$limit=100000');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al cargar accidentes');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}