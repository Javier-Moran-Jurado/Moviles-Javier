import 'package:shared_preferences/shared_preferences.dart';

class LogoLocalStorage {
  static const String _prefixLogo = 'logo_establecimiento_';
  static const String _prefixNombre = 'nombre_establecimiento_';
  static const String _prefixNit = 'nit_establecimiento_';
  static const String _prefixDireccion = 'direccion_establecimiento_';
  static const String _prefixTelefono = 'telefono_establecimiento_';

  static Future<void> saveAll({
    required int id,
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    String? logoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixNombre$id', nombre);
    await prefs.setString('$_prefixNit$id', nit);
    await prefs.setString('$_prefixDireccion$id', direccion);
    await prefs.setString('$_prefixTelefono$id', telefono);
    if (logoPath != null) {
      await prefs.setString('$_prefixLogo$id', logoPath);
    }
  }

  static Future<Map<String, String?>> getAll(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nombre': prefs.getString('$_prefixNombre$id'),
      'nit': prefs.getString('$_prefixNit$id'),
      'direccion': prefs.getString('$_prefixDireccion$id'),
      'telefono': prefs.getString('$_prefixTelefono$id'),
      'logoPath': prefs.getString('$_prefixLogo$id'),
    };
  }

  static Future<String?> getLogo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefixLogo$id');
  }
}