import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;
  bool _loading = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  bool get isLoggedIn => _token != null && _user != null;
  String get userId => _user?['firebase_uid'] ?? '';
  String get userName => _user?['nombre'] ?? 'Usuario';
  List<dynamic> get hogares => _user?['hogares'] ?? [];

  Future<void> loadSession() async {
    _token = await ApiService.getToken();
    _user = await ApiService.getUser();
    notifyListeners();
  }

  Future<void> login(String correo, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await ApiService.login(correo, password);
      final payload = (data['data'] is Map<String, dynamic>)
          ? data['data'] as Map<String, dynamic>
          : data;
      final token = payload['access_token'] ??
          payload['token'] ??
          payload['accessToken'];
      if (token is! String || token.isEmpty) {
        throw ApiException('Token de autenticacion requerido');
      }
      _token = token;
      await ApiService.saveToken(_token!);

      final user = payload['user'] ?? payload['usuario'] ?? payload['profile'];
      if (user is Map<String, dynamic>) {
        _user = user;
      } else {
        _user = await ApiService.getMe();
      }
      await ApiService.saveUser(_user!);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String nombre, String correo, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await ApiService.register(nombre, correo, password);
      await login(correo, password);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await ApiService.clearSession();
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final updated = await ApiService.getMe();
      _user = updated;
      await ApiService.saveUser(updated);
      notifyListeners();
    } catch (_) {}
  }

  void updateUserHogar(String hogarId) {
    if (_user != null) {
      final hogares = List<dynamic>.from(_user!['hogares'] ?? []);
      if (!hogares.contains(hogarId)) hogares.add(hogarId);
      _user!['hogares'] = hogares;
      ApiService.saveUser(_user!);
      notifyListeners();
    }
  }
}
