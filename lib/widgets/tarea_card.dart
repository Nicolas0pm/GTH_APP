import 'package:flutter/material.dart';
import '../services/theme.dart';

class TareaCard extends StatelessWidget {
  final Map<String, dynamic> tarea;
  final VoidCallback onCompletar;
  final VoidCallback onEliminar;
  final VoidCallback onTap;

  const TareaCard({
    super.key,
    required this.tarea,
    required this.onCompletar,
    required this.onEliminar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estado = tarea['estado'] ?? 'pendiente';
    final completada = tarea['completada'] == true;
    final color = AppTheme.estadoColor(estado);
    final categoria = tarea['categoria'];
    final fechaLimite = tarea['fecha_limite'];
    final asignado = _asignadoLabel(tarea);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Estado icon
                  GestureDetector(
                    onTap: completada ? null : onCompletar,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: completada
                            ? AppTheme.success.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: completada
                            ? null
                            : Border.all(color: AppTheme.textLight, width: 2),
                      ),
                      child: completada
                          ? const Icon(Icons.check,
                              size: 16, color: AppTheme.success)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tarea['titulo'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: completada
                            ? AppTheme.textLight
                            : AppTheme.textDark,
                        decoration: completada
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 20, color: AppTheme.textLight),
                    onSelected: (val) {
                      if (val == 'completar') onCompletar();
                      if (val == 'eliminar') onEliminar();
                    },
                    itemBuilder: (_) => [
                      if (!completada)
                        const PopupMenuItem(
                          value: 'completar',
                          child: Row(children: [
                            Icon(Icons.check_circle_outline,
                                size: 18, color: AppTheme.success),
                            SizedBox(width: 8),
                            Text('Marcar completada'),
                          ]),
                        ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: AppTheme.error),
                          SizedBox(width: 8),
                          Text('Eliminar',
                              style: TextStyle(color: AppTheme.error)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
              if (tarea['descripcion'] != null &&
                  tarea['descripcion'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    tarea['descripcion'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.textMedium, fontSize: 13),
                  ),
                ),
              ],
              if (asignado != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Asignado a: $asignado',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 40),
                  // Estado badge
                  _badge(
                    AppTheme.estadoLabel(estado),
                    color.withOpacity(0.12),
                    color,
                  ),
                  if (categoria != null) ...[
                    const SizedBox(width: 8),
                    _badge(
                      categoria,
                      AppTheme.categoriaColor(categoria).withOpacity(0.15),
                      AppTheme.categoriaColor(categoria),
                    ),
                  ],
                  const Spacer(),
                  if (fechaLimite != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: AppTheme.textLight),
                        const SizedBox(width: 4),
                        Text(fechaLimite,
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textLight)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style:
                TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
      );

  String? _asignadoLabel(Map<String, dynamic> tarea) {
    final labelKeys = [
      'asignado_a_nombre',
      'asignado_nombre',
      'asignado_a_label',
      'asignado_label',
    ];
    for (final key in labelKeys) {
      final val = tarea[key];
      if (val is String && val.trim().isNotEmpty) return val.trim();
    }

    final asignado = tarea['asignado_a'];
    if (asignado is Map) {
      final nombre = asignado['nombre'];
      if (nombre is String && nombre.trim().isNotEmpty) return nombre.trim();
      final correo = asignado['correo'];
      if (correo is String && correo.trim().isNotEmpty) return correo.trim();
    }

    if (asignado is String && asignado.trim().isNotEmpty) {
      return asignado.trim();
    }

    return null;
  }
}
