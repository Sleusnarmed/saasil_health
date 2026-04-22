import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

enum RecordType { glucosa, insulina, sintoma }

class RecordDetailPage extends StatelessWidget {
  final Map<String, dynamic> record;
  final RecordType recordType;

  const RecordDetailPage({
    super.key,
    required this.record,
    required this.recordType,
  });

  bool _canEdit(String dateString) {
    try {
      final recordDate = DateTime.parse(dateString);
      final now = DateTime.now();
      
      final isSameDay = now.year == recordDate.year &&
                        now.month == recordDate.month &&
                        now.day == recordDate.day;
                        
      final isWithin24h = now.difference(recordDate).inHours < 24;
      
      return isSameDay && isWithin24h;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _getGlucoseStatus(int value) {
    if (value < 70) {
      return {
        'label': 'Hipoglucemia',
        'color': AppTheme.colorError, 
        'icon': Icons.arrow_downward_rounded,
        'alert': 'Nivel peligrosamente bajo. Consume carbohidratos de acción rápida y vuelve a medir en 15 min.',
      };
    } else if (value <= 140) { 
      return {
        'label': 'Normal',
        'color': AppTheme.colorSucess, 
        'icon': Icons.check_rounded,
        'alert': null,
      };
    } else {
      return {
        'label': 'Hiperglucemia',
        'color': Colors.orange, 
        'icon': Icons.arrow_upward_rounded,
        'alert': 'Nivel elevado. Consulte con su médico si persiste por más de 2 horas.',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateString = record['fecha_hora'] ?? DateTime.now().toString();
    final DateTime parsedDate = DateTime.parse(dateString);
    final isEditable = _canEdit(dateString);

    String titleValue = "";
    String subtitle = "";
    Widget? statusChip;
    Widget? alertBanner;
    Color primaryColor = AppTheme.colorPrimary;
    IconData mainIcon = Icons.medical_information;

    if (recordType == RecordType.glucosa) {
      final valor = record['valor'] as int;
      titleValue = valor.toString();
      subtitle = "mg/dL · Registro de glucosa";
      mainIcon = Icons.water_drop;
      
      final status = _getGlucoseStatus(valor);
      primaryColor = status['color'];
      
      statusChip = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status['icon'], color: primaryColor, size: 14),
            const SizedBox(width: 4),
            Text(
              status['label'],
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      );

      if (status['alert'] != null) {
        alertBanner = Container(
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status['alert'],
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }
    } else if (recordType == RecordType.insulina) {
      titleValue = record['unidades'].toString();
      subtitle = "UI · Registro de insulina";
      mainIcon = Icons.vaccines;
      primaryColor = AppTheme.colorPrimary;
    } else if (recordType == RecordType.sintoma) {
      titleValue = record['severidad'] ?? "Síntoma";
      subtitle = "Registro de síntoma";
      mainIcon = Icons.sick_outlined;
      primaryColor = AppTheme.colorTertiary;
    }

    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        title: const Text("Detalle del registro", style: TextStyle(color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: primaryColor, width: 6)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(mainIcon, color: primaryColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              titleValue,
                              style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            if (statusChip != null) statusChip,
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (alertBanner != null) alertBanner,

            const SizedBox(height: 30),
            Text(
              "INFORMACIÓN DEL REGISTRO",
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow("Tipo", subtitle.split('·').last.trim()),
                  const Divider(height: 1),
                  if (recordType == RecordType.glucosa)
                    _buildDetailRow("Momento", record['momento_dia'] ?? "No especificado"),
                  if (recordType == RecordType.insulina) ...[
                    _buildDetailRow("Categoría", record['categoria'] ?? "No especificada"),
                    const Divider(height: 1),
                    _buildDetailRow("Subtipo", record['subtipo'] ?? "No especificado"),
                  ],
                  if (recordType == RecordType.sintoma)
                    _buildDetailRow("Síntomas", record['sintomas'] ?? "No especificados"),
                  
                  const Divider(height: 1),
                  _buildDetailRow("Fecha", DateFormat('dd MMM yyyy', 'es').format(parsedDate)),
                  const Divider(height: 1),
                  _buildDetailRow("Hora", DateFormat('hh:mm a').format(parsedDate)),
                  const Divider(height: 1),
                  _buildDetailRow("Notas", (record['notas'] == null || record['notas'].toString().isEmpty) ? "Sin notas" : record['notas']),
                ],
              ),
            ),

            const SizedBox(height: 30),

            if (isEditable)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función de edición en desarrollo')),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      label: const Text("Editar", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colorPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _confirmDelete(context);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                      label: const Text("Eliminar", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colorError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_clock_outlined, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Este registro superó las 24 horas y no puede ser modificado por seguridad de tus datos médicos.",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar registro?"),
        content: const Text("Esta acción no se puede deshacer."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Aquí va tu lógica de borrado en base de datos.
              // await DatabaseHelper.instance.database.delete(...);
              Navigator.pop(context);
              Navigator.pop(context, true); 
            },
            child: Text("Eliminar", style: TextStyle(color: AppTheme.colorError)),
          ),
        ],
      ),
    );
  }
}