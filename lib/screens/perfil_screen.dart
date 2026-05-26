import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/theme.dart';
import 'login_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user ?? {};

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar header
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (user['nombre'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user['nombre'] ?? 'Usuario',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark),
                ),
                Text(
                  user['correo'] ?? '',
                  style: const TextStyle(color: AppTheme.textMedium),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['rol'] ?? 'miembro',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow(Icons.person_outline, 'Nombre', user['nombre'] ?? ''),
                  const Divider(height: 24),
                  _infoRow(Icons.email_outlined, 'Correo', user['correo'] ?? ''),
                  const Divider(height: 24),
                  _infoRow(Icons.home_outlined, 'Hogares',
                      '${(user['hogares'] as List?)?.length ?? 0} hogar(es)'),
                  const Divider(height: 24),
                  _infoRow(Icons.badge_outlined, 'Rol', user['rol'] ?? 'miembro'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // App info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.asset('assets/images/logo.png'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GTH App',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark)),
                          Text('Gestión de Tareas del Hogar',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textMedium)),
                        ],
                      ),
                      const Spacer(),
                      const Text('v1.0.0',
                          style: TextStyle(
                              color: AppTheme.textLight, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Logout
          ElevatedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Deseas cerrar tu sesión?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Salir',
                            style: TextStyle(color: AppTheme.error))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<AuthProvider>().logout();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMedium, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textDark, fontWeight: FontWeight.w600)),
        ],
      );
}
