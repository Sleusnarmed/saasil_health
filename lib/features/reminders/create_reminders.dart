import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/config_reminder.dart';
import '../../core/database/database_helper.dart';

class CreateReminderPage extends StatefulWidget {
  const CreateReminderPage({super.key});

  @override
  State<CreateReminderPage> createState() => _CreateReminderPageState();
}

class _CreateReminderPageState extends State<CreateReminderPage> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay? _selectedTime;
  String _selectedFrequency = 'Una vez';
  bool _isActive = true;

  final List<String> _frequencies = ['Una vez', 'Diario', 'Semanal', 'Personalizado'];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.colorPrimary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Selecciona una hora";
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourString = hour.toString().padLeft(2, '0');
    return "$hourString:$minute $period";
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un título')));
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una hora')));
      return;
    }

    final newReminder = ConfigRecordatorios(
      titulo: _titleController.text.trim(),
      hora: _formatTime(_selectedTime),
      frecuencia: _selectedFrequency,
      activo: _isActive,
    );

    final db = await DatabaseHelper.instance.database;
    await db.insert(DatabaseHelper.tableConfigRecordatorios, newReminder.toMap());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardado exitosamente'), backgroundColor: Colors.green),
      );
      // AQUÍ ESTÁ EL TRUCO: Pasamos 'true' de regreso
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nuevo Recordatorio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Título del recordatorio'),
            const SizedBox(height: 8),
            Container(
              decoration: _inputDecorationBox(),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ej: Insulina nocturna',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('Hora'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: _inputDecorationBox(),
                child: Text(
                  _formatTime(_selectedTime),
                  style: TextStyle(fontSize: 16, color: _selectedTime == null ? Colors.grey.shade400 : Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('Frecuencia'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _inputDecorationBox(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFrequency,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.colorPrimary),
                  items: _frequencies.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() { _selectedFrequency = newValue!; });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Activar recordatorio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch(
                  value: _isActive,
                  onChanged: (value) { setState(() { _isActive = value; }); },
                  activeTrackColor: AppTheme.colorPrimary,
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colorPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Guardar recordatorio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontSize: 16, color: Colors.black87)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A5568)));
  }

  BoxDecoration _inputDecorationBox() {
    return BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300));
  }
}