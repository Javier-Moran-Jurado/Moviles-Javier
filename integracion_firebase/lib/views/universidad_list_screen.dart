import 'package:flutter/material.dart';
import '../models/universidad.dart';
import '../services/firestore_service.dart';
import 'universidad_form_screen.dart';

class UniversidadListScreen extends StatelessWidget {
  UniversidadListScreen({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Universidad'),
          content: const Text('¿Estás seguro de que deseas eliminar este registro?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _firestoreService.deleteUniversidad(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universidades'),
      ),
      body: StreamBuilder<List<Universidad>>(
        stream: _firestoreService.getUniversidades(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final universidades = snapshot.data ?? [];

          if (universidades.isEmpty) {
            return const Center(child: Text('No hay universidades registradas'));
          }

          return ListView.builder(
            itemCount: universidades.length,
            itemBuilder: (context, index) {
              final universidad = universidades[index];
              return ListTile(
                title: Text(universidad.nombre),
                subtitle: Text('NIT: ${universidad.nit}\nTel: ${universidad.telefono}'),
                isThreeLine: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UniversidadFormScreen(universidad: universidad),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, universidad.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UniversidadFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
