import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/theme.dart';
import '../widgets/tarea_card.dart';
import 'crear_tarea_screen.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});
  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _tareas = [];
  bool _loading = true;
  String? _error;
  String _filtroEstado = 'todos';
  late TabController _tabController;
  Map<String, String> _miembrosLabel = {};

  final List<String> _estados = ['todos', 'pendiente', 'en_progreso', 'completada'];
  final List<String> _estadosLabel = ['Todos', 'Pendientes', 'En progreso', 'Completadas'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _filtroEstado = _estados[_tabController.index]);
        _loadTareas();
      }
    });
    _loadTareas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTareas() async {
    final auth = context.read<AuthProvider>();
    if (auth.hogares.isEmpty) {
      setState(() {
        _loading = false;
        _tareas = [];
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final hogarId = auth.hogares.first;
      final estado = _filtroEstado == 'todos' ? null : _filtroEstado;
      final results = await Future.wait([
        ApiService.getTareas(hogarId: hogarId, estado: estado),
        ApiService.getMiembros(hogarId),
      ]);
      final data = results[0] as List<dynamic>;
      final miembros = results[1] as List<dynamic>;
      _miembrosLabel = _buildMiembrosLabel(miembros);
      final mapped = data.map((item) {
        final tarea = Map<String, dynamic>.from(item as Map);
        _applyAsignadoLabel(tarea);
        return tarea;
      }).toList();
      setState(() {
        _tareas = mapped;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<String, String> _buildMiembrosLabel(List<dynamic> miembros) {
    final map = <String, String>{};
    for (final m in miembros) {
      if (m is! Map) continue;
      final uid = m['firebase_uid'];
      if (uid is! String || uid.trim().isEmpty) continue;
      final nombre = m['nombre'];
      final correo = m['correo'];
      final label = (nombre is String && nombre.trim().isNotEmpty)
          ? nombre.trim()
          : (correo is String && correo.trim().isNotEmpty)
              ? correo.trim()
              : null;
      if (label != null) map[uid] = label;
    }
    return map;
  }

  void _applyAsignadoLabel(Map<String, dynamic> tarea) {
    final labelKeys = [
      'asignado_a_nombre',
      'asignado_nombre',
      'asignado_a_label',
      'asignado_label',
    ];
    for (final key in labelKeys) {
      final val = tarea[key];
      if (val is String && val.trim().isNotEmpty) return;
    }
    final asignado = tarea['asignado_a'];
    if (asignado is String && asignado.trim().isNotEmpty) {
      final label = _miembrosLabel[asignado.trim()];
      if (label != null) tarea['asignado_a_nombre'] = label;
    }
  }

  Future<void> _completarTarea(String tareaId) async {
    try {
      await ApiService.completarTarea(tareaId);
      _loadTareas();
    } catch (e) {
      _showSnackbar(e.toString(), error: true);
    }
  }

  Future<void> _eliminarTarea(String tareaId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Estás seguro de que deseas eliminar esta tarea?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Eliminar', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.eliminarTarea(tareaId);
        _showSnackbar('Tarea eliminada');
        _loadTareas();
      } catch (e) {
        _showSnackbar(e.toString(), error: true);
      }
    }
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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
            const Text('Mis Tareas'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabAlignment: TabAlignment.start,
          tabs: _estadosLabel.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: !hasHogar
          ? _noHogarView()
          : _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _error != null
                  ? _errorView()
                  : _tareas.isEmpty
                      ? _emptyView()
                      : RefreshIndicator(
                          onRefresh: _loadTareas,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _tareas.length,
                            itemBuilder: (ctx, i) => TareaCard(
                              tarea: _tareas[i],
                              onCompletar: () =>
                                  _completarTarea(_tareas[i]['id']),
                              onEliminar: () =>
                                  _eliminarTarea(_tareas[i]['id']),
                              onTap: () async {
                                await Navigator.push(
                                    ctx,
                                    MaterialPageRoute(
                                        builder: (_) => CrearTareaScreen(
                                            hogarId: auth.hogares.first,
                                            tarea: _tareas[i])));
                                _loadTareas();
                              },
                            ),
                          ),
                        ),
      floatingActionButton: hasHogar
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CrearTareaScreen(
                            hogarId: auth.hogares.first)));
                _loadTareas();
              },
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nueva tarea'),
            )
          : null,
    );
  }

  Widget _noHogarView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_outlined,
                    size: 40, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),
              const Text('Sin hogar asignado',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
              const SizedBox(height: 8),
              const Text(
                'Ve a la pestaña Hogar para crear o unirte a uno',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMedium),
              ),
            ],
          ),
        ),
      );

  Widget _emptyView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, size: 64, color: AppTheme.accent),
            const SizedBox(height: 16),
            const Text('¡Sin tareas por aquí!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark)),
            const SizedBox(height: 8),
            const Text('Crea una nueva tarea con el botón +',
                style: TextStyle(color: AppTheme.textMedium)),
          ],
        ),
      );

  Widget _errorView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppTheme.error),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppTheme.error)),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadTareas, child: const Text('Reintentar')),
          ],
        ),
      );
}
