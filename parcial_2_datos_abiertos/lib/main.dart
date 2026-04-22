import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_router.dart';   // Importa el archivo de rutas

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {   // ← Cambiado StatelessWorker → StatelessWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Datos Abiertos Colombia',
      routerConfig: appRouter,        // ← appRouter está definido en app_router.dart
    );
  }
}