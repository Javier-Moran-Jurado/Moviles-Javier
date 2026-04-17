import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asincronía, Timer e Isolate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Future / async / await
  String _futureStatus = 'Presiona el boton';
  bool _futureLoading = false;

  // Timer (Cronometro)
  int _seconds = 0;
  Timer? _timer;
  bool _timerRunning = false;

  // Isolate
  String _isolateResult = 'Sin resultado';
  bool _isolateComputing = false;

  // ------------------------------------------------------------
  // 1) Simulacion de servicio con Future.delayed
  // ------------------------------------------------------------
  Future<String> _simulatedService() async {
    print('Antes del Future.delayed');
    await Future.delayed(const Duration(seconds: 2));
    print('Despues del Future.delayed (simulando exito)');
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    if (random < 2) {
      throw Exception('Error simulado en el servicio');
    }
    return 'Datos recibidos: ${DateTime.now()}';
  }

  Future<void> _fetchData() async {
    setState(() {
      _futureLoading = true;
      _futureStatus = 'Cargando...';
    });
    print('Inicio de _fetchData');
    try {
      final result = await _simulatedService();
      print('Resultado obtenido: $result');
      setState(() {
        _futureStatus = 'Exito: $result';
      });
    } catch (e) {
      print('Error capturado: $e');
      setState(() {
        _futureStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _futureLoading = false;
      });
      print('Fin de _fetchData');
    }
  }

  // ------------------------------------------------------------
  // 2) Timer: Cronometro con iniciar/pausar/reanudar/reiniciar
  // ------------------------------------------------------------
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
    _timerRunning = true;
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _timerRunning = false;
  }

  void _resumeTimer() {
    if (!_timerRunning) {
      _startTimer();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _seconds = 0;
      _timerRunning = false;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ------------------------------------------------------------
  // 3) Isolate para tarea pesada (CPU-bound) con medicion de tiempo
  // ------------------------------------------------------------
  static Future<void> _heavyComputation(SendPort sendPort) async {
    int sum = 0;
    for (int i = 0; i < 100000000; i++) {
      sum += i;
    }
    sendPort.send(sum);
  }

  Future<void> _runHeavyTask() async {
    setState(() {
      _isolateComputing = true;
      _isolateResult = 'Calculando en Isolate...';
    });
    print('Iniciando Isolate pesado');
    
    final stopwatch = Stopwatch()..start();
    
    final receivePort = ReceivePort();
    await Isolate.spawn(_heavyComputation, receivePort.sendPort);
    final result = await receivePort.first;
    receivePort.close();
    
    stopwatch.stop();
    final durationMs = stopwatch.elapsedMilliseconds;
    final durationSec = durationMs / 1000;
    
    print('Resultado del Isolate: $result');
    print('Tiempo de ejecucion: ${durationMs}ms (${durationSec.toStringAsFixed(2)}s)');
    
    setState(() {
      _isolateResult = 'Resultado de suma pesada: $result\nTiempo: ${durationMs}ms (${durationSec.toStringAsFixed(2)}s)';
      _isolateComputing = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asincronia, Timer e Isolate'),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFE9ECF3)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seccion Future (sin icono)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Future / async / await',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _futureLoading ? null : _fetchData,
                        icon: _futureLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: const Text('Consultar servicio simulado'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _futureStatus.contains('Exito')
                                  ? Icons.check_circle
                                  : _futureStatus.contains('Error')
                                  ? Icons.error
                                  : Icons.info,
                              color: _futureStatus.contains('Exito')
                                  ? Colors.green
                                  : _futureStatus.contains('Error')
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _futureStatus,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seccion Timer (sin icono)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Timer (Cronometro)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            _formatTime(_seconds),
                            style: const TextStyle(
                              fontSize: 64,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTimerButton('Iniciar', Icons.play_arrow, _startTimer, Colors.green),
                          _buildTimerButton('Pausar', Icons.pause, _pauseTimer, Colors.orange),
                          _buildTimerButton('Reanudar', Icons.refresh, _resumeTimer, Colors.blue),
                          _buildTimerButton('Reiniciar', Icons.restart_alt, _resetTimer, Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seccion Isolate (sin icono)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Isolate para tarea pesada',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isolateComputing ? null : _runHeavyTask,
                        icon: _isolateComputing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.calculate),
                        label: const Text('Ejecutar suma pesada (Isolate)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.computer, color: Colors.purple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isolateResult,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerButton(String label, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}