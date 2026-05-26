import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/theme.dart';

class CrearTareaScreen extends StatefulWidget {
  final String hogarId;
  final Map<String, dynamic>? tarea; // if editing

  const CrearTareaScreen({super.key, required this.hogarId, this.tarea});

  @override
  State<CrearTareaScreen> createState() => _CrearTareaScreenState();
}

class _CrearTareaScreenState extends State<CrearTareaScreen> {
  static const String _autoAsignarValue = '__auto_asignar__';

  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _categoria;
  String? _fechaLimite;
  String _estado = 'pendiente';
  String? _asignadoA;
  List<dynamic> _miembros = [];
  bool _loading = false;
  String? _error;

  final List<String> _categorias = [
    'Cocina', 'Limpieza', 'Baño', 'Jardín', 'Compras', 'Otro'
  ];

  bool get isEditing => widget.tarea != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _tituloCtrl.text = widget.tarea!['titulo'] ?? '';
      _descCtrl.text = widget.tarea!['descripcion'] ?? '';
      _categoria = widget.tarea!['categoria'];
      _fechaLimite = widget.tarea!['fecha_limite'];
      _estado = widget.tarea!['estado'] ?? 'pendiente';
      final asignarAuto = widget.tarea!['asignar_auto'];
      if (asignarAuto == true) {
        _asignadoA = _autoAsignarValue;
      } else {
        _asignadoA = widget.tarea!['asignado_a'];
      }
    }
    _loadMiembros();
  }

  Future<void> _loadMiembros() async {
    try {
      final data = await ApiService.getMiembros(widget.hogarId);
      setState(() => _miembros = data);
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setState(() =>
          _fechaLimite = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().length < 2) {
      setState(() => _error = 'El título debe tener al menos 2 caracteres');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final autoAsignar = _asignadoA == _autoAsignarValue;
      final data = {
        'titulo': _tituloCtrl.text.trim(),
        'descripcion': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'categoria': _categoria,
        'fecha_limite': _fechaLimite,
        'estado': _estado,
        'hogar_id': widget.hogarId,
        'asignado_a': autoAsignar ? null : _asignadoA,
        if (autoAsignar) 'asignar_auto': true,
      };
      if (isEditing) {
        final update = {
          'titulo': data['titulo'],
          'descripcion': data['descripcion'],
          'categoria': data['categoria'],
          'fecha_limite': data['fecha_limite'],
          'estado': data['estado'],
          'asignado_a': data['asignado_a'],
          if (autoAsignar) 'asignar_auto': true,
        };
        await ApiService.actualizarTarea(widget.tarea!['id'], update);
      } else {
        await ApiService.crearTarea(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar tarea' : 'Nueva tarea'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('Título *'),
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                hintText: 'Ej: Lavar los platos',
              ),
            ),
            const SizedBox(height: 20),
            _section('Descripción'),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Descripción opcional...',
              ),
            ),
            const SizedBox(height: 20),
            _section('Categoría'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categorias.map((cat) {
                final selected = _categoria == cat;
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _categoria = selected ? null : cat),
                  selectedColor: AppTheme.primary.withOpacity(0.15),
                  checkmarkColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: selected ? AppTheme.primary : AppTheme.textMedium,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _section('Estado'),
            DropdownButtonFormField<String>(
              value: _estado,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(
                    value: 'en_progreso', child: Text('En progreso')),
                DropdownMenuItem(
                    value: 'completada', child: Text('Completada')),
              ],
              onChanged: (v) => setState(() => _estado = v!),
            ),
            const SizedBox(height: 20),
            _section('Fecha límite'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppTheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      _fechaLimite ?? 'Seleccionar fecha',
                      style: TextStyle(
                        color: _fechaLimite != null
                            ? AppTheme.textDark
                            : AppTheme.textLight,
                      ),
                    ),
                    const Spacer(),
                    if (_fechaLimite != null)
                      GestureDetector(
                        onTap: () => setState(() => _fechaLimite = null),
                        child: const Icon(Icons.close,
                            size: 16, color: AppTheme.textLight),
                      ),
                  ],
                ),
              ),
            ),
            if (_miembros.isNotEmpty) ...[
              const SizedBox(height: 20),
              _section('Asignar a'),
              DropdownButtonFormField<String>(
                value: _asignadoA,
                decoration:
                    const InputDecoration(hintText: 'Seleccionar asignacion'),
                items: [
                  const DropdownMenuItem(
                      value: _autoAsignarValue,
                      child: Text('Asignar automaticamente')),
                  const DropdownMenuItem(
                      value: null, child: Text('Sin asignar')),
                  ..._miembros.map((m) => DropdownMenuItem(
                        value: m['firebase_uid'] as String,
                        child: Text(m['nombre'] ?? m['correo'] ?? 'Miembro'),
                      )),
                ],
                onChanged: (v) => setState(() => _asignadoA = v),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
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
                            style: const TextStyle(color: AppTheme.error))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : ElevatedButton(
                    onPressed: _guardar,
                    child: Text(isEditing ? 'Guardar cambios' : 'Crear tarea'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
                fontSize: 14)),
      );
}
