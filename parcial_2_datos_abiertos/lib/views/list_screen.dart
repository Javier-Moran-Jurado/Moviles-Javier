import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';

// Función auxiliar (si no la tienes)
String _extractString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) return value['name']?.toString() ?? value.toString();
  return value.toString();
}

class ListScreen extends StatefulWidget {
  final String endpoint;
  const ListScreen({super.key, required this.endpoint});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = ApiService().fetchData(widget.endpoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle(widget.endpoint))),
      body: FutureBuilder<List<dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          // Determinar el estado actual
          String estadoTexto = '';
          Color estadoColor = Colors.black;

          if (snapshot.connectionState == ConnectionState.waiting) {
            estadoTexto = '🔄 Cargando...';
            estadoColor = Colors.orange;
          } else if (snapshot.hasError) {
            estadoTexto = '❌ Error: ${snapshot.error}';
            estadoColor = Colors.red;
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            estadoTexto = '✅ Éxito - Datos cargados correctamente (${snapshot.data!.length} registros)';
            estadoColor = Colors.green;
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            estadoTexto = '⚠️ Éxito pero sin datos';
            estadoColor = Colors.orange;
          } else {
            estadoTexto = '⏳ Estado desconocido';
          }

          // Construcción del contenido principal
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureData = ApiService().fetchData(widget.endpoint);
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            content = const Center(child: Text('No hay datos disponibles'));
          } else {
            final items = snapshot.data!;
            content = ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: _getLeadingIcon(widget.endpoint),
                    title: Text(
                      _getDisplayTitle(widget.endpoint, item),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_getDisplaySubtitle(widget.endpoint, item)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final id = item['id'].toString();
                      context.pushNamed('detail', pathParameters: {
                        'endpoint': widget.endpoint,
                        'id': id,
                      });
                    },
                  ),
                );
              },
            );
          }

          // Usamos un Column para mostrar el estado arriba y el contenido abajo
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

  
}

  String _getTitle(String endpoint) {
    switch (endpoint) {
      case 'President': return 'Presidentes de Colombia';
      case 'NaturalArea': return 'Áreas Naturales';
      case 'TypicalDish': return 'Platos Típicos';
      case 'Airport': return 'Aeropuertos';
      default: return endpoint;
    }
  }

  String _getDisplayTitle(String endpoint, Map<String, dynamic> item) {
    switch (endpoint) {
      case 'President': return _extractString(item['name']);
      case 'NaturalArea': return _extractString(item['name']);
      case 'TypicalDish': return _extractString(item['name']);
      case 'Airport': return _extractString(item['name']);
      default: return 'Elemento';
    }
  }

  String _getDisplaySubtitle(String endpoint, Map<String, dynamic> item) {
    switch (endpoint) {
      case 'President':
        // Muestra el partido político como subtítulo (o periodo si existe)
        final party = _extractString(item['politicalParty']);
        final period = _extractString(item['period']);
        return party.isNotEmpty ? party : (period.isNotEmpty ? period : 'Sin información');
      case 'NaturalArea':
        final area = item['landArea']?.toString() ?? '';
        final areaText = area.isNotEmpty ? '${double.tryParse(area)?.toStringAsFixed(2)} ha' : 'Área no disponible';
        final deptoId = item['departmentId']?.toString() ?? '?';
        return '$areaText | Depto ID: $deptoId';
      case 'TypicalDish':
        final desc = _extractString(item['description']);
        return desc.length > 60 ? '${desc.substring(0, 60)}...' : desc;
      case 'Airport':
        final city = _extractString(item['city']);
        final department = _extractString(item['department']);
        return '$city - $department';
      default:
        return 'ID: ${item['id']}';
    }
  }

  Icon _getLeadingIcon(String endpoint) {
    switch (endpoint) {
      case 'President': return const Icon(Icons.account_balance, color: Colors.indigo);
      case 'NaturalArea': return const Icon(Icons.nature, color: Colors.green);
      case 'TypicalDish': return const Icon(Icons.restaurant, color: Colors.orange);
      case 'Airport': return const Icon(Icons.flight, color: Colors.blue);
      default: return const Icon(Icons.info);
    }
  }
