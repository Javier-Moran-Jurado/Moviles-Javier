import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<List<dynamic>> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar $endpoint');
    }
  }

  Future<Map<String, dynamic>> fetchDetail(String endpoint, String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar detalle de $endpoint con id $id');
    }
  }
}