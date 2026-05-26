import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/theme.dart';
import 'tareas_screen.dart';
import 'hogar_screen.dart';
import 'disponibilidad_screen.dart';
import 'estadisticas_screen.dart';
import 'perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TareasScreen(),
      const HogarScreen(),
      const DisponibilidadScreen(),
      const EstadisticasScreen(),
      const PerfilScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hasHogar = auth.hogares.isNotEmpty;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            )
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primary.withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 65,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist, color: AppTheme.primary),
              label: 'Tareas',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: !hasHogar,
                child: const Icon(Icons.home_outlined),
              ),
              selectedIcon: const Icon(Icons.home, color: AppTheme.primary),
              label: 'Hogar',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon:
                  Icon(Icons.calendar_month, color: AppTheme.primary),
              label: 'Horarios',
            ),
            const NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primary),
              label: 'Stats',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppTheme.primary),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
