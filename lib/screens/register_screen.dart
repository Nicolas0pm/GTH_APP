import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/theme.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  Future<void> _register() async {
    setState(() => _error = null);
    if (_nombreCtrl.text.trim().length < 2) {
      setState(() => _error = 'El nombre debe tener al menos 2 caracteres');
      return;
    }
    final auth = context.read<AuthProvider>();
    try {
      await auth.register(_nombreCtrl.text.trim(), _correoCtrl.text.trim(),
          _passCtrl.text.trim());
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6), Color(0xFF34D399)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon:
                              Icon(Icons.person_outline, color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _correoCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppTheme.primary),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppTheme.error, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          color: AppTheme.error, fontSize: 13))),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      auth.loading
                          ? const CircularProgressIndicator(
                              color: AppTheme.primary)
                          : ElevatedButton(
                              onPressed: _register,
                              child: const Text('Crear cuenta'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
