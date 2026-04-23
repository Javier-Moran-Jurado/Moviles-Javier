import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../services/accidentes_service.dart';
import '../services/isolate_helper.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final AccidentesService _service = AccidentesService();
  Map<String, dynamic>? _estadisticas;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rawData = await _service.fetchAllAccidentes();
      final resultado = await compute(calcularEstadisticas, rawData);
      setState(() {
        _estadisticas = resultado;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas de accidentes')),
      body: Skeletonizer(
        enabled: _loading,
        child: _loading
            ? _buildSkeleton()
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarEstadisticas,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if ((_estadisticas!['clase'] as Map?)?.isNotEmpty ?? false)
                          _buildPieChart('Clase de accidente', _estadisticas!['clase']),
                        if ((_estadisticas!['gravedad'] as Map?)?.isNotEmpty ?? false)
                          _buildPieChart('Gravedad', _estadisticas!['gravedad']),
                        if ((_estadisticas!['barrios'] as Map?)?.isNotEmpty ?? false)
                          _buildBarChart('Top 5 barrios con más accidentes', _estadisticas!['barrios']),
                        if ((_estadisticas!['dias'] as Map?)?.isNotEmpty ?? false)
                          _buildBarChart('Accidentes por día de la semana', _estadisticas!['dias']),
                        if (_estadisticas!['clase'].isEmpty &&
                            _estadisticas!['gravedad'].isEmpty &&
                            _estadisticas!['barrios'].isEmpty &&
                            _estadisticas!['dias'].isEmpty)
                          const Center(child: Text('No hay datos para mostrar')),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPieChart(String title, Map<String, int> data) {
    final entries = data.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 50, // dona en lugar de pie lleno
                  sections: entries.asMap().entries.map((e) {
                    final idx = e.key;
                    final entry = e.value;
                    final pct = (entry.value / total * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '$pct%',  // solo porcentaje dentro
                      radius: 70,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      color: Colors.primaries[idx % Colors.primaries.length],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Leyenda externa
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: entries.asMap().entries.map((e) {
                final idx = e.key;
                final entry = e.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.primaries[idx % Colors.primaries.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key} (${entry.value})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(String title, Map<String, int> data) {
    if (data.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('No hay datos suficientes'),
            ],
          ),
        ),
      );
    }

    final entries = data.entries.toList();
    final maxY = entries.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.2,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) return const Text('');
                          String label = entries[index].key;
                          if (label.length > 10) label = '${label.substring(0, 9)}…';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: RotatedBox(
                              quarterTurns: 1, // etiquetas rotadas para que no se amontonen
                              child: Text(label, style: const TextStyle(fontSize: 10)),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: entries.asMap().entries.map((e) {
                    final idx = e.key;
                    final entry = e.value;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.primaries[idx % Colors.primaries.length],
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Skeletonizer(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Cargando gráfica...'),
                  SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Skeletonizer(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Cargando gráfica...'),
                  SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}