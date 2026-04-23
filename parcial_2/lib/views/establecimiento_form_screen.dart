import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../services/establecimientos_service.dart';
import '../models/establecimiento.dart';
import '../utils/logo_local_storage.dart';

class EstablecimientoFormScreen extends StatefulWidget {
  final String? id;
  const EstablecimientoFormScreen({super.key, this.id});

  @override
  State<EstablecimientoFormScreen> createState() => _EstablecimientoFormScreenState();
}

class _EstablecimientoFormScreenState extends State<EstablecimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EstablecimientosService _service = EstablecimientosService();

  late TextEditingController _nombreCtrl;
  late TextEditingController _nitCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _telefonoCtrl;

  XFile? _imagenNueva;       // imagen recién seleccionada
  String? _logoLocalPath;    // ruta local guardada previamente
  bool _isLoading = false;
  Establecimiento? _existing;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _nitCtrl = TextEditingController();
    _direccionCtrl = TextEditingController();
    _telefonoCtrl = TextEditingController();
    if (widget.id != null) {
      _cargarDatos();
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      // Cargar datos del servidor
      _existing = await _service.getById(int.parse(widget.id!));

      // Intentar cargar datos locales guardados (override del servidor)
      final local = await LogoLocalStorage.getAll(int.parse(widget.id!));

      _nombreCtrl.text = local['nombre'] ?? _existing!.nombre;
      _nitCtrl.text = local['nit'] ?? _existing!.nit;
      _direccionCtrl.text = local['direccion'] ?? _existing!.direccion;
      _telefonoCtrl.text = local['telefono'] ?? _existing!.telefono;

      // Logo local
      final logoPath = local['logoPath'];
      if (logoPath != null && File(logoPath).existsSync()) {
        setState(() => _logoLocalPath = logoPath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagenNueva = picked);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (widget.id == null) {
        // CREAR — sí llama al backend
        final formData = FormData.fromMap({
          'nombre': _nombreCtrl.text,
          'nit': _nitCtrl.text,
          'direccion': _direccionCtrl.text,
          'telefono': _telefonoCtrl.text,
          if (_imagenNueva != null)
            'logo': await MultipartFile.fromFile(
              _imagenNueva!.path,
              filename: _imagenNueva!.name,
            ),
        });
        final creado = await _service.create(formData);

        // Guardar localmente también
        await LogoLocalStorage.saveAll(
          id: creado.id,
          nombre: _nombreCtrl.text,
          nit: _nitCtrl.text,
          direccion: _direccionCtrl.text,
          telefono: _telefonoCtrl.text,
          logoPath: _imagenNueva?.path,
        );
      } else {
        // EDITAR — solo guardar localmente (backend no funciona)
        await LogoLocalStorage.saveAll(
          id: int.parse(widget.id!),
          nombre: _nombreCtrl.text,
          nit: _nitCtrl.text,
          direccion: _direccionCtrl.text,
          telefono: _telefonoCtrl.text,
          logoPath: _imagenNueva?.path,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado correctamente')),
        );
        context.goNamed('establecimientos');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildLogoPreview() {
    // 1. Imagen recién seleccionada
    if (_imagenNueva != null) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_imagenNueva!.path),
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _imagenNueva!.name,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      );
    }
    // 2. Logo guardado localmente
    if (_logoLocalPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_logoLocalPath!),
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }
    // 3. Sin logo
    return const Icon(Icons.store, size: 60, color: Colors.grey);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nitCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Crear establecimiento' : 'Editar establecimiento'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    TextFormField(
                      controller: _nitCtrl,
                      decoration: const InputDecoration(labelText: 'NIT'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    TextFormField(
                      controller: _direccionCtrl,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    TextFormField(
                      controller: _telefonoCtrl,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLogoPreview(),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _seleccionarImagen,
                      icon: const Icon(Icons.image),
                      label: const Text('Seleccionar logo'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _guardar,
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}