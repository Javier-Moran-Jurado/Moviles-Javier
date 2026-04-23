import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../services/establecimientos_service.dart';
import '../models/establecimiento.dart';
import '../utils/url_helper.dart';

class EstablecimientoListScreen extends StatefulWidget {
  const EstablecimientoListScreen({super.key});

  @override
  State<EstablecimientoListScreen> createState() => _EstablecimientoListScreenState();
}

class _EstablecimientoListScreenState extends State<EstablecimientoListScreen> {
  final EstablecimientosService _service = EstablecimientosService();
  List<Establecimiento> _establecimientos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarLista();
  }

  Future<void> _cargarLista() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getAll();
      setState(() {
        _establecimientos = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _eliminarEstablecimiento(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este establecimiento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.delete(id);
        _cargarLista();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Establecimientos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('establecimiento_crear'),
        child: const Icon(Icons.add),
      ),
      body: Skeletonizer(
        enabled: _loading,
        child: _loading
            ? ListView.builder(
                itemCount: 5,
                itemBuilder: (_, __) => const ListTile(
                  leading: CircleAvatar(),
                  title: Text('Cargando...'),
                  subtitle: Text('...'),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _cargarLista, child: const Text('Reintentar')),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _establecimientos.length,
                    itemBuilder: (context, index) {
                      final est = _establecimientos[index];
                      final logoUrl = getFullLogoUrl(est.logo);
                      return ListTile(
                        leading: logoUrl.isNotEmpty
                            ? Image.network(logoUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CircleAvatar(child: Icon(Icons.store)))
                            : const CircleAvatar(child: Icon(Icons.store)),
                        title: Text(est.nombre),
                        subtitle: Text('${est.nit} - ${est.direccion}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => context.pushNamed('establecimiento_editar', pathParameters: {'id': est.id.toString()}),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _eliminarEstablecimiento(est.id),
                            ),
                          ],
                        ),
                        onTap: () => context.pushNamed('establecimiento_detail', pathParameters: {'id': est.id.toString()}),
                      );
                    },
                  ),
      ),
    );
  }
}