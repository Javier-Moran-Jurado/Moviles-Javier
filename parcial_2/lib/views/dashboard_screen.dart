import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../services/accidentes_service.dart';
import '../services/establecimientos_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AccidentesService _accService = AccidentesService();
  final EstablecimientosService _estService = EstablecimientosService();

  int _totalAccidentes = 0;
  int _totalEstablecimientos = 0;
  bool _loadingAcc = true;
  bool _loadingEst = true;
  String? _errorAcc;
  String? _errorEst;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final data = await _accService.fetchAllAccidentes();
      setState(() {
        _totalAccidentes = data.length;
        _loadingAcc = false;
      });
    } catch (e) {
      setState(() {
        _errorAcc = e.toString();
        _loadingAcc = false;
      });
    }

    try {
      final establecimientos = await _estService.getAll();
      setState(() {
        _totalEstablecimientos = establecimientos.length;
        _loadingEst = false;
      });
    } catch (e) {
      setState(() {
        _errorEst = e.toString();
        _loadingEst = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Total de accidentes cargados', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Skeletonizer(
                      enabled: _loadingAcc,
                      child: Text(
                        _errorAcc ?? '$_totalAccidentes',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_errorAcc != null)
                      TextButton(
                        onPressed: () => _cargarDatos(),
                        child: const Text('Reintentar'),
                      ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Total de establecimientos registrados', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Skeletonizer(
                      enabled: _loadingEst,
                      child: Text(
                        _errorEst ?? '$_totalEstablecimientos',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_errorEst != null)
                      TextButton(
                        onPressed: () => _cargarDatos(),
                        child: const Text('Reintentar'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed('estadisticas'),
              icon: const Icon(Icons.bar_chart),
              label: const Text('Ver estadísticas de accidentes'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed('establecimientos'),
              icon: const Icon(Icons.store),
              label: const Text('Gestionar establecimientos'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}