import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/theme.dart';

class HogarScreen extends StatefulWidget {
  const HogarScreen({super.key});
  @override
  State<HogarScreen> createState() => _HogarScreenState();
}

class _HogarScreenState extends State<HogarScreen> {
  Map<String, dynamic>? _hogar;
  List<dynamic> _miembros = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHogar();
  }

  Future<void> _loadHogar() async {
    final auth = context.read<AuthProvider>();
    if (auth.hogares.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final hogarId = auth.hogares.first as String;
      final hogar = await ApiService.getHogar(hogarId);
      final miembros = await ApiService.getMiembros(hogarId);
      setState(() {
        _hogar = hogar;
        _miembros = miembros;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _showCrearHogar() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crear hogar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del hogar',
                prefixIcon: Icon(Icons.home_outlined, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (ctrl.text.trim().length < 2) return;
                Navigator.pop(ctx);
                try {
                  final hogar =
                      await ApiService.crearHogar(ctrl.text.trim());
                  context.read<AuthProvider>().updateUserHogar(hogar['id']);
                  await context.read<AuthProvider>().refreshUser();
                  _loadHogar();
                } catch (e) {
                  _showSnackbar(e.toString(), error: true);
                }
              },
              child: const Text('Crear'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showUnirse() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Unirse a hogar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Código de invitación',
                prefixIcon: Icon(Icons.vpn_key_outlined, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (ctrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                try {
                  final hogar =
                      await ApiService.unirseHogar(ctrl.text.trim());
                  context.read<AuthProvider>().updateUserHogar(hogar['id']);
                  await context.read<AuthProvider>().refreshUser();
                  _loadHogar();
                } catch (e) {
                  _showSnackbar(e.toString(), error: true);
                }
              },
              child: const Text('Unirse'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppTheme.error : AppTheme.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hasHogar = auth.hogares.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Mi Hogar')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : !hasHogar
              ? _noHogarView()
              : RefreshIndicator(
                  onRefresh: _loadHogar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (_hogar != null) ...[
                        // Hogar card
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.home, color: Colors.white, size: 32),
                              const SizedBox(height: 12),
                              Text(
                                _hogar!['nombre_hogar'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Código de invitación:',
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: _hogar!['codigo_invitacion']));
                                  _showSnackbar('Código copiado al portapapeles');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _hogar!['codigo_invitacion'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: 3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.copy,
                                          color: Colors.white70, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Miembros (${_miembros.length})',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 12),
                        ..._miembros.map((m) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppTheme.primary.withOpacity(0.1),
                                  child: Text(
                                    (m['nombre'] ?? '?')[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                title: Text(m['nombre'] ?? 'Miembro'),
                                subtitle: Text(m['correo'] ?? ''),
                                trailing: m['rol'] == 'admin'
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text('Admin',
                                            style: TextStyle(
                                                color: AppTheme.accent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      )
                                    : null,
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _noHogarView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_outlined,
                    size: 50, color: AppTheme.primary),
              ),
              const SizedBox(height: 20),
              const Text('No tienes hogar aún',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark)),
              const SizedBox(height: 8),
              const Text(
                'Crea tu propio hogar o únete al de alguien con su código de invitación',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMedium),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _showCrearHogar,
                icon: const Icon(Icons.add_home),
                label: const Text('Crear hogar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _showUnirse,
                icon: const Icon(Icons.group_add),
                label: const Text('Unirme con código'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppTheme.primary),
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
}
