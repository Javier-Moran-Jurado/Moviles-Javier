import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Map<String, String>> endpoints = const [
    {'name': 'Presidentes', 'endpoint': 'President'},
    {'name': 'Áreas Naturales', 'endpoint': 'NaturalArea'},
    {'name': 'Platos Típicos', 'endpoint': 'TypicalDish'},
    {'name': 'Aeropuertos', 'endpoint': 'Airport'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos Abiertos Colombia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: endpoints.length,
          itemBuilder: (context, index) {
            final endpoint = endpoints[index];
            return Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  context.pushNamed('list', pathParameters: {'endpoint': endpoint['endpoint']!});
                },
                child: Center(
                  child: Text(
                    endpoint['name']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}