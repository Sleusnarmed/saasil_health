import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/reg_symptoms.dart';
import '../../core/database/database_helper.dart';

class SymptomsLogPage extends StatefulWidget {
  const SymptomsLogPage({super.key});

  @override
  State<SymptomsLogPage> createState() => _SymptomsLogPageState();
}

class _SymptomsLogPageState extends State<SymptomsLogPage> {
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String? _selectedSeverity;
  
  final List<String> _selectedSymptoms = [];

  final List<Map<String, dynamic>> _symptomsOptions = [
    {'name': 'Mareo', 'emoji': '🤢'},
    {'name': 'Fatiga', 'emoji': '😴'},
    {'name': 'Sed excesiva', 'emoji': '🧊'},
    {'name': 'Visión borrosa', 'emoji': '👓'},
    {'name': 'Dolor de cabeza', 'emoji': '🤕'},
    {'name': 'Náuseas', 'emoji': '🤮'},
    {'name': 'Confusión', 'emoji': '😵'},
    {'name': 'Sudoración', 'emoji': '💦'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_selectedSeverity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona la severidad de los síntomas.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    String finalNotes = '';
    if (_selectedSymptoms.isNotEmpty) {
      finalNotes += 'Síntomas: ${_selectedSymptoms.join(", ")}. ';
    }
    if (_notesController.text.trim().isNotEmpty) {
      finalNotes += _notesController.text.trim();
    }

    final newEntry = RegSintomas(
      severidad: _selectedSeverity!,
      fechaHora: finalDateTime,
      notas: finalNotes.isNotEmpty ? finalNotes : null,
    );

    try {
      final db = await DatabaseHelper.instance.database;
      
      await db.insert(
        DatabaseHelper.tableRegSintomas, 
        newEntry.toMap(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro de síntomas guardado correctamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppTheme.colorError,
          ),
        );
      }
    }
  }

  void _showSymptomsSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Selecciona tus síntomas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _symptomsOptions.length,
                        itemBuilder: (context, index) {
                          final symptom = _symptomsOptions[index];
                          final isSelected = _selectedSymptoms.contains(symptom['name']);
                          
                          return CheckboxListTile(
                            title: Row(
                              children: [
                                Text(symptom['emoji'], style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 12),
                                Text(symptom['name'], style: const TextStyle(color: AppTheme.colorTextPrimary)),
                              ],
                            ),
                            value: isSelected,
                            activeColor: AppTheme.colorPrimary,
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (value == true) {
                                  _selectedSymptoms.add(symptom['name']);
                                } else {
                                  _selectedSymptoms.remove(symptom['name']);
                                }
                              });
                              setState(() {}); 
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => _themePicker(context, child),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => _themePicker(context, child),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Widget _themePicker(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppTheme.colorPrimary,
          onPrimary: Colors.white,
          onSurface: AppTheme.colorTextPrimary,
        ),
      ),
      child: child!,
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: AppTheme.colorBgSecondary,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade300, width: 1),
    );
  }

  Widget _buildSeverityButton(String label, Color color) {
    final isSelected = _selectedSeverity == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSeverity = label;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 12, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        title: const Text(
          'Registro de Síntomas',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.colorPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Síntomas presentados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showSymptomsSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: _inputDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedSymptoms.isEmpty 
                            ? 'Toca para seleccionar síntomas' 
                            : '${_selectedSymptoms.length} síntoma(s) seleccionado(s)',
                        style: TextStyle(
                          color: _selectedSymptoms.isEmpty ? Colors.grey.shade500 : AppTheme.colorTextPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: AppTheme.colorPrimary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Severidad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSeverityButton('Leve', Colors.green),
                _buildSeverityButton('Moderado', Colors.orange),
                _buildSeverityButton('Severa', Colors.red), // Ajustado a "Severa" o "Severo" según prefieras
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fecha',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: _inputDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(fontSize: 16, color: AppTheme.colorTextPrimary),
                              ),
                              const Icon(Icons.calendar_today, color: AppTheme.colorPrimary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hora',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: _inputDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime.format(context),
                                style: const TextStyle(fontSize: 16, color: AppTheme.colorTextPrimary),
                              ),
                              const Icon(Icons.access_time, color: AppTheme.colorPrimary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              'Notas adicionales (opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: _inputDecoration(),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                minLines: 2,
                maxLength: 255,
                style: const TextStyle(color: AppTheme.colorTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Ej: Sentí esto después de caminar...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Guardar registro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colorTextSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}