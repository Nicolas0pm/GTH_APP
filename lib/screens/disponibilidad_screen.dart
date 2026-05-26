import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/theme.dart';

class DisponibilidadScreen extends StatefulWidget {
  const DisponibilidadScreen({super.key});
  @override
  State<DisponibilidadScreen> createState() => _DisponibilidadScreenState();
}

class _DisponibilidadScreenState extends State<DisponibilidadScreen> {
  static const List<String> _dias = [
    'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'
  ];
  static const List<String> _diasLabel = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  // dia -> list of {inicio, fin}
  Map<String, List<Map<String, String>>> _horarios = {};
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final d in _dias) {
      _horarios[d] = [];
    }
    _loadDisponibilidad();
  }

  Future<void> _loadDisponibilidad() async {
    final auth = context.read<AuthProvider>();
    if (auth.hogares.isEmpty) return;
    setState(() => _loading = true);
    try {
      final data = await ApiService.getDisponibilidad(auth.hogares.first);
      final userId = auth.userId;
      // find my availability
      final mine = (data as List).firstWhere(
        (d) => d['usuario_id'] == userId,
        orElse: () => null,
      );
      if (mine != null) {
        for (final d in _dias) {
          final ranges = mine[d] as List? ?? [];
          _horarios[d] = ranges
              .map<Map<String, String>>((r) => {
                    'inicio': r['inicio'] ?? '08:00',
                    'fin': r['fin'] ?? '10:00',
                  })
              .toList();
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _guardar() async {
    final auth = context.read<AuthProvider>();
    if (auth.hogares.isEmpty) return;
    setState(() => _saving = true);
    try {
      final data = {
        'usuario_id': auth.userId,
        'hogar_id': auth.hogares.first,
      };
      for (final d in _dias) {
        data[d] = _horarios[d]!;
      }
      await ApiService.crearDisponibilidad(data);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Disponibilidad guardada'),
        backgroundColor: AppTheme.success,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppTheme.error,
      ));
    }
    setState(() => _saving = false);
  }

  Future<void> _addRango(String dia) async {
    TimeOfDay? inicio = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
    if (inicio == null) return;
    TimeOfDay? fin = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (fin == null) return;

    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    setState(() {
      _horarios[dia]!.add({'inicio': fmt(inicio), 'fin': fmt(fin)});
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mi Disponibilidad'),
        actions: [
          if (auth.hogares.isNotEmpty)
            TextButton(
              onPressed: _saving ? null : _guardar,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Guardar',
                      style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: auth.hogares.isEmpty
          ? const Center(
              child: Text('Necesitas un hogar para registrar disponibilidad',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMedium)))
          : _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _dias.length,
                  itemBuilder: (ctx, i) {
                    final dia = _dias[i];
                    final label = _diasLabel[i];
                    final rangos = _horarios[dia]!;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: rangos.isNotEmpty
                                        ? AppTheme.success
                                        : AppTheme.textLight,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppTheme.textDark)),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () => _addRango(dia),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Agregar'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.primary),
                                ),
                              ],
                            ),
                            if (rangos.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 4, left: 16),
                                child: Text('No disponible',
                                    style: TextStyle(
                                        color: AppTheme.textLight,
                                        fontSize: 13)),
                              ),
                            ...rangos.asMap().entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8, left: 16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 14,
                                          color: AppTheme.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${e.value['inicio']} - ${e.value['fin']}',
                                        style: const TextStyle(
                                            color: AppTheme.textMedium,
                                            fontSize: 13),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => setState(() =>
                                            _horarios[dia]!.removeAt(e.key)),
                                        child: const Icon(Icons.close,
                                            size: 16,
                                            color: AppTheme.textLight),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
