import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../services/establecimientos_service.dart';
import '../models/establecimiento.dart';
import '../utils/logo_local_storage.dart';

class EstablecimientoDetailScreen extends StatefulWidget {
  final String id;
  const EstablecimientoDetailScreen({super.key, required this.id});

  @override
  State<EstablecimientoDetailScreen> createState() => _EstablecimientoDetailScreenState();
}

class _EstablecimientoDetailScreenState extends State<EstablecimientoDetailScreen> {
  final EstablecimientosService _service = EstablecimientosService();
  Establecimiento? _establecimiento;
  String? _logoLocalPath;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final idParsed = int.tryParse(widget.id);
    if (idParsed == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID inválido')));
        context.goNamed('establecimientos');
      });
      return;
    }
    _cargarDetalle(idParsed);
  }

  Future<void> _cargarDetalle(int id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final est = await _service.getById(id);

      // Cargar logo local
      final logoPath = await LogoLocalStorage.getLogo(id);

      setState(() {
        _establecimiento = est;
        _logoLocalPath = (logoPath != null && File(logoPath).existsSync()) ? logoPath : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildLogo() {
    // 1. Logo guardado localmente
    if (_logoLocalPath != null) {
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_logoLocalPath!),
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    // 2. Sin logo
    return const Center(
      child: Icon(Icons.store, size: 100, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del establecimiento')),
      body: Skeletonizer(
        enabled: _loading,
        child: _loading
            ? const Center(child: Text('Cargando...'))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final idParsed = int.tryParse(widget.id);
                            if (idParsed != null) _cargarDetalle(idParsed);
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 16),
                        Text('Nombre: ${_establecimiento!.nombre}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('NIT: ${_establecimiento!.nit}'),
                        Text('Dirección: ${_establecimiento!.direccion}'),
                        Text('Teléfono: ${_establecimiento!.telefono}'),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await context.pushNamed(
                                  'establecimiento_editar',
                                  pathParameters: {'id': widget.id},
                                );
                                // Recargar al volver del form por si cambió el logo
                                final idParsed = int.tryParse(widget.id);
                                if (idParsed != null) _cargarDetalle(idParsed);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final idInt = int.tryParse(widget.id);
                                if (idInt == null) return;
                                await _service.delete(idInt);
                                if (context.mounted) context.goNamed('establecimientos');
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Eliminar'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}