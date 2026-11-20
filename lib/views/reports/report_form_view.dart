import 'package:flutter/material.dart';
import 'package:uts_qr_mantenimiento/providers/app_provider.dart';

class ReportFormView extends StatefulWidget {
  final AppProvider appProvider;

  const ReportFormView({super.key, required this.appProvider});

  @override
  State<ReportFormView> createState() => _ReportFormViewState();
}

class _ReportFormViewState extends State<ReportFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descripcion = TextEditingController();
  String? _recursoId;
  String? _categoria;
  String _prioridad = 'MEDIA';

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    widget.appProvider.agregarReporteDemo(
      recursoId: _recursoId!,
      descripcion: _descripcion.text,
      categoria: _categoria!,
      prioridad: _prioridad,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final recursos = widget.appProvider.recursos;
    final esDemo = widget.appProvider.isDemo;
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar reporte')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!esDemo)
                const Text(
                  'El registro institucional estará disponible cuando se conecte el inicio de sesión con Supabase.',
                )
              else if (recursos.isEmpty)
                const Text('No hay recursos disponibles para reportar.')
              else ...[
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Recurso'),
                  items: [
                    for (final recurso in recursos)
                      DropdownMenuItem(
                        value: recurso.id,
                        child: Text(
                          '${recurso.codigo} · ${recurso.nombre}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (valor) => _recursoId = valor,
                  validator: (valor) =>
                      valor == null ? 'Selecciona un recurso' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcion,
                  decoration: const InputDecoration(
                    labelText: 'Descripción de la avería',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 5,
                  validator: (valor) => (valor ?? '').trim().isEmpty
                      ? 'Describe la avería'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: const [
                    DropdownMenuItem(
                      value: 'ELECTRICA',
                      child: Text('Eléctrica'),
                    ),
                    DropdownMenuItem(value: 'FISICA', child: Text('Física')),
                    DropdownMenuItem(
                      value: 'SOFTWARE',
                      child: Text('Software'),
                    ),
                    DropdownMenuItem(
                      value: 'CONECTIVIDAD',
                      child: Text('Conectividad'),
                    ),
                    DropdownMenuItem(value: 'OTRA', child: Text('Otra')),
                  ],
                  onChanged: (valor) => _categoria = valor,
                  validator: (valor) =>
                      valor == null ? 'Selecciona una categoría' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _prioridad,
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                  items: const [
                    DropdownMenuItem(value: 'BAJO', child: Text('Baja')),
                    DropdownMenuItem(value: 'MEDIA', child: Text('Media')),
                    DropdownMenuItem(value: 'ALTO', child: Text('Alta')),
                    DropdownMenuItem(value: 'CRITICO', child: Text('Crítica')),
                  ],
                  onChanged: (valor) => _prioridad = valor ?? 'MEDIA',
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _guardar,
                  child: const Text('Guardar reporte de prueba'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
