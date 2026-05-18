import 'package:flutter/material.dart';
import '../models/universidad.dart';
import '../services/firestore_service.dart';

class UniversidadFormScreen extends StatefulWidget {
  final Universidad? universidad;

  const UniversidadFormScreen({super.key, this.universidad});

  @override
  State<UniversidadFormScreen> createState() => _UniversidadFormScreenState();
}

class _UniversidadFormScreenState extends State<UniversidadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nitController;
  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _paginaWebController;

  @override
  void initState() {
    super.initState();
    _nitController = TextEditingController(text: widget.universidad?.nit ?? '');
    _nombreController = TextEditingController(text: widget.universidad?.nombre ?? '');
    _direccionController = TextEditingController(text: widget.universidad?.direccion ?? '');
    _telefonoController = TextEditingController(text: widget.universidad?.telefono ?? '');
    _paginaWebController = TextEditingController(text: widget.universidad?.paginaWeb ?? '');
  }

  @override
  void dispose() {
    _nitController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _paginaWebController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  void _saveUniversidad() {
    if (_formKey.currentState!.validate()) {
      final nuevaUniversidad = Universidad(
        id: widget.universidad?.id,
        nit: _nitController.text.trim(),
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        telefono: _telefonoController.text.trim(),
        paginaWeb: _paginaWebController.text.trim(),
      );

      if (widget.universidad == null) {
        _firestoreService.addUniversidad(nuevaUniversidad);
      } else {
        _firestoreService.updateUniversidad(nuevaUniversidad);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.universidad != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Universidad' : 'Nueva Universidad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nitController,
                decoration: const InputDecoration(labelText: 'NIT'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'El NIT es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'La dirección es obligatoria' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'El teléfono es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paginaWebController,
                decoration: const InputDecoration(labelText: 'Página Web (URL)'),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La página web es obligatoria';
                  }
                  if (!_isValidUrl(value.trim())) {
                    return 'Ingresa una URL válida (ej. https://...)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveUniversidad,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
