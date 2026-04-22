import 'package:flutter/material.dart';
import '../services/api_service.dart';

String _extractString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) return value['name']?.toString() ?? value.toString();
  return value.toString();
}

class DetailScreen extends StatefulWidget {
  final String endpoint;
  final String id;
  const DetailScreen({super.key, required this.endpoint, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Map<String, dynamic>> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = ApiService().fetchDetail(widget.endpoint, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(widget.endpoint)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDetail,
        builder: (context, snapshot) {
          // Determinar el estado actual
          String estadoTexto = '';
          Color estadoColor = Colors.black;

          if (snapshot.connectionState == ConnectionState.waiting) {
            estadoTexto = '🔄 Cargando detalle...';
            estadoColor = Colors.orange;
          } else if (snapshot.hasError) {
            estadoTexto = '❌ Error: ${snapshot.error}';
            estadoColor = Colors.red;
          } else if (snapshot.hasData) {
            estadoTexto = '✅ Detalle cargado correctamente';
            estadoColor = Colors.green;
          } else {
            estadoTexto = '⏳ Estado desconocido';
          }

          // Contenido principal
          Widget content;
          if (snapshot.connectionState == ConnectionState.waiting) {
            content = const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            content = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureDetail = ApiService().fetchDetail(widget.endpoint, widget.id);
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            content = const Center(child: Text('No hay detalles disponibles'));
          } else {
            final data = snapshot.data!;
            final fields = _getFormattedFields(widget.endpoint, data);
            content = SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(_getIcon(widget.endpoint), size: 48, color: Colors.indigo),
                          const SizedBox(height: 8),
                          Text(
                            _getMainTitle(widget.endpoint, data),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...fields.map((field) => _buildInfoRow(field['label']!, field['value']!)),
                ],
              ),
            );
          }

          // Estructura con barra de estado arriba
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: estadoColor.withOpacity(0.1),
                child: Text(
                  estadoTexto,
                  style: TextStyle(color: estadoColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(String endpoint) {
    switch (endpoint) {
      case 'President': return 'Detalle del Presidente';
      case 'NaturalArea': return 'Detalle del Área Natural';
      case 'TypicalDish': return 'Detalle del Plato Típico';
      case 'Airport': return 'Detalle del Aeropuerto';
      default: return 'Detalle';
    }
  }

  String _getMainTitle(String endpoint, Map<String, dynamic> data) {
    switch (endpoint) {
      case 'President': return _extractString(data['name']);
      case 'NaturalArea': return _extractString(data['name']);
      case 'TypicalDish': return _extractString(data['name']);
      case 'Airport': return _extractString(data['name']);
      default: return 'Información';
    }
  }

  IconData _getIcon(String endpoint) {
    switch (endpoint) {
      case 'President': return Icons.account_balance;
      case 'NaturalArea': return Icons.nature;
      case 'TypicalDish': return Icons.restaurant;
      case 'Airport': return Icons.flight;
      default: return Icons.info;
    }
  }

  List<Map<String, String>> _getFormattedFields(String endpoint, Map<String, dynamic> data) {
    final fields = <Map<String, String>>[];
    switch (endpoint) {
      case 'President':
        fields.add({'label': 'Nombre', 'value': _extractString(data['name'])});
        fields.add({'label': 'Partido político', 'value': _extractString(data['politicalParty'])});
        fields.add({'label': 'Periodo', 'value': _extractString(data['period'])});
        fields.add({'label': 'Descripción', 'value': _extractString(data['description'])});
        break;
      case 'NaturalArea':
        fields.add({'label': 'Nombre', 'value': _extractString(data['name'])});
        fields.add({'label': 'Área terrestre (ha)', 'value': data['landArea']?.toString() ?? 'No disponible'});
        fields.add({'label': 'ID Departamento', 'value': data['departmentId']?.toString() ?? ''});
        fields.add({'label': 'Código DANE', 'value': data['daneCode']?.toString() ?? ''});
        fields.add({'label': 'ID Grupo de área', 'value': data['areaGroupId']?.toString() ?? ''});
        fields.add({'label': 'ID Categoría', 'value': data['categoryNaturalAreaId']?.toString() ?? ''});
        if (data['maritimeArea'] != null) {
          fields.add({'label': 'Área marina (ha)', 'value': data['maritimeArea'].toString()});
        }
        break;
      case 'TypicalDish':
        fields.add({'label': 'Nombre', 'value': _extractString(data['name'])});
        fields.add({'label': 'Descripción', 'value': _extractString(data['description'])});
        fields.add({'label': 'Ingredientes', 'value': _extractString(data['ingredients'])});
        fields.add({'label': 'Departamento', 'value': _extractString(data['department'])});
        if (_extractString(data['imageUrl']).isNotEmpty) {
          fields.add({'label': 'Imagen URL', 'value': _extractString(data['imageUrl'])});
        }
        break;
      case 'Airport':
        fields.add({'label': 'Nombre', 'value': _extractString(data['name'])});
        fields.add({'label': 'Descripción', 'value': _extractString(data['description'])});
        fields.add({'label': 'Código IATA', 'value': _extractString(data['iataCode'])});
        fields.add({'label': 'Tipo', 'value': _extractString(data['type'])});
        fields.add({'label': 'Ciudad', 'value': _extractString(data['city'])});
        fields.add({'label': 'Departamento', 'value': _extractString(data['department'])});
        fields.add({'label': 'Latitud', 'value': data['latitude']?.toString() ?? ''});
        fields.add({'label': 'Longitud', 'value': data['longitude']?.toString() ?? ''});
        break;
    }
    return fields.where((f) => f['value'] != null && f['value']!.isNotEmpty).toList();
  }
}