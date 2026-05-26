import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://gthapi-production.up.railway.app/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr == null) return null;
    return jsonDecode(userStr);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> register(
      String nombre, String correo, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(auth: false),
      body: jsonEncode({'nombre': nombre, 'correo': correo, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) return data;
    throw ApiException(data['detail'] ?? 'Error al registrar');
  }

  static Future<Map<String, dynamic>> login(
      String correo, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({'correo': correo, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw ApiException(data['detail'] ?? 'Correo o contraseña inválidos');
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _headers(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw ApiException(data['detail'] ?? 'Error obteniendo perfil');
  }

  // HOGARES
  static Future<Map<String, dynamic>> crearHogar(String nombre) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hogares'),
      headers: await _headers(),
      body: jsonEncode({'nombre_hogar': nombre}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) return data;
    throw ApiException(data['detail'] ?? 'Error al crear hogar');
  }

  static Future<Map<String, dynamic>> unirseHogar(String codigo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hogares/unirse'),
      headers: await _headers(),
      body: jsonEncode({'codigo_invitacion': codigo}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw ApiException(data['detail'] ?? 'Código inválido');
  }

  static Future<Map<String, dynamic>> getHogar(String hogarId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/hogares/$hogarId'),
      headers: await _headers(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw ApiException(data['detail'] ?? 'Error obteniendo hogar');
  }

  static Future<List<dynamic>> getMiembros(String hogarId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/hogares/$hogarId/miembros'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw ApiException('Error obteniendo miembros');
  }

  // TAREAS
  static Future<List<dynamic>> getTareas({String? hogarId, String? estado}) async {
    String url = '$baseUrl/tareas';
    final params = <String, String>{};
    if (hogarId != null) params['hogar_id'] = hogarId;
    if (estado != null) params['estado'] = estado;
    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    final response = await http.get(Uri.parse(url), headers: await _headers());
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw ApiException('Error obteniendo tareas');
  }

  static Future<Map<String, dynamic>> crearTarea(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tareas'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 201) return result;
    throw ApiException(result['detail'] ?? 'Error al crear tarea');
  }

  static Future<Map<String, dynamic>> actualizarTarea(
      String tareaId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tareas/$tareaId'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) return result;
    throw ApiException(result['detail'] ?? 'Error al actualizar tarea');
  }

  static Future<void> eliminarTarea(String tareaId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tareas/$tareaId'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw ApiException('Error al eliminar tarea');
    }
  }

  static Future<Map<String, dynamic>> completarTarea(String tareaId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tareas/$tareaId/completar'),
      headers: await _headers(),
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) return result;
    throw ApiException(result['detail'] ?? 'Error al completar tarea');
  }

  static Future<Map<String, dynamic>> asignarTarea(
      String tareaId, String asignadoA) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tareas/$tareaId/asignar'),
      headers: await _headers(),
      body: jsonEncode({'asignado_a': asignadoA}),
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 200) return result;
    throw ApiException(result['detail'] ?? 'Error al asignar tarea');
  }

  // DISPONIBILIDAD
  static Future<Map<String, dynamic>> crearDisponibilidad(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/disponibilidad'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    final result = jsonDecode(response.body);
    if (response.statusCode == 201) return result;
    throw ApiException(result['detail'] ?? 'Error al guardar disponibilidad');
  }

  static Future<List<dynamic>> getDisponibilidad(String hogarId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/disponibilidad/$hogarId'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw ApiException('Error obteniendo disponibilidad');
  }

  // ESTADISTICAS
  static Future<Map<String, dynamic>> getEstadisticas(String hogarId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/estadisticas/$hogarId'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw ApiException('Error obteniendo estadísticas');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
