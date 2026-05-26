import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/theme.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});
  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  Map<String, dynamic>? _stats;
  List<dynamic> _miembros = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (auth.hogares.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats =
          await ApiService.getEstadisticas(auth.hogares.first as String);
      final miembros =
          await ApiService.getMiembros(auth.hogares.first as String);
      setState(() {
        _stats = stats;
        _miembros = miembros;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _nombreMiembro(String uid) {
    final m = _miembros.firstWhere(
        (m) => m['firebase_uid'] == uid,
        orElse: () => null);
    return m?['nombre'] ?? uid.substring(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: auth.hogares.isEmpty
          ? const Center(
              child: Text('Necesitas un hogar para ver estadísticas',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMedium)))
          : _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary))
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.error, size: 48),
                          const SizedBox(height: 12),
                          Text(_error!,
                              style: const TextStyle(color: AppTheme.error)),
                          TextButton(
                              onPressed: _load, child: const Text('Reintentar')),
                        ],
                      ),
                    )
                  : _stats == null
                      ? const SizedBox()
                      : _buildContent(),
    );
  }

  Widget _buildContent() {
    final totales = _stats!['totales'] as Map<String, dynamic>;
    final rendimiento = _stats!['rendimiento'] as Map<String, dynamic>;
    final total = totales['tareas'] as int? ?? 0;
    final completadas = totales['tareas_completadas'] as int? ?? 0;
    final pendientes = totales['tareas_pendientes'] as int? ?? 0;
    final pct = (totales['porcentaje_cumplimiento'] as num?)?.toDouble() ?? 0;
    final miembros = totales['miembros'] as int? ?? 0;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Big progress card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cumplimiento global',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${pct.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statPill('$miembros', 'Miembros'),
                    _statPill('$total', 'Total'),
                    _statPill('$completadas', 'Hechas'),
                    _statPill('$pendientes', 'Pendientes'),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Rendimiento por miembro',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          // per member
          ...(_miembros.map((m) {
            final uid = m['firebase_uid'] as String;
            final tareasPorUsuario =
                (rendimiento['tareas_por_usuario'] as Map)[uid] as int? ?? 0;
            final completadasPorUsuario =
                (rendimiento['completadas_por_usuario'] as Map)[uid] as int? ?? 0;
            final pctUser = tareasPorUsuario > 0
                ? completadasPorUsuario / tareasPorUsuario
                : 0.0;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Text(
                        (m['nombre'] ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['nombre'] ?? 'Miembro',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pctUser.toDouble(),
                              backgroundColor:
                                  AppTheme.primary.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primary),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completadasPorUsuario/$tareasPorUsuario tareas • ${(pctUser * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: AppTheme.textMedium, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _statPill(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      );
}
