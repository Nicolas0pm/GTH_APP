import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'services/theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const GTHApp(),
    ),
  );
}

class GTHApp extends StatelessWidget {
  const GTHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GTH - Gestión de Tareas del Hogar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();
  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<AuthProvider>().loadSession();
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6), Color(0xFF34D399)],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('GTH',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      );
    }
    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
