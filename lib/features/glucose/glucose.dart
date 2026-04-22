import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/reg_glucose.dart';
import '../../core/database/database_helper.dart';

class GlucoseLogPage extends StatefulWidget {
  const GlucoseLogPage({super.key});

  @override
  State<GlucoseLogPage> createState() => _GlucoseLogPageState();
}

class _GlucoseLogPageState extends State<GlucoseLogPage> {
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String? _selectedMoment;
  final List<String> _momentOptions = [
    'En ayunas',
    'Antes de comer',
    'Después de comer',
    'Antes de dormir',
  ];

  @override
  void dispose() {
    _glucoseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final glucoseText = _glucoseController.text;
    final glucoseValue = int.tryParse(glucoseText) ?? 0;
    final notesText = _notesController.text;

    if (glucoseValue <= 0 || _selectedMoment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, ingresa un nivel de glucosa válido y selecciona el momento del día.'),
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

    final newEntry = RegGlucosa(
      valor: glucoseValue,
      momentoDia: _selectedMoment!,
      fechaHora: finalDateTime,
      notas: notesText.trim().isNotEmpty ? notesText.trim() : null,
    );

    try {
      final db = await DatabaseHelper.instance.database;
      
      await db.insert(
        DatabaseHelper.tableRegGlucosa, 
        newEntry.toMap(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro de glucosa guardado correctamente!'),
            backgroundColor: Colors.green,
          ),
        );

        _glucoseController.clear();
        _notesController.clear();
        setState(() {
          _selectedMoment = null;
        });
        
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
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
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
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
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: AppTheme.colorBgSecondary,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade300, width: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        title: const Text(
          'Registro de Glucosa',
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
              'Nivel de glucosa (mg/dL)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: _inputDecoration(),
              child: TextField(
                controller: _glucoseController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.colorTextPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ej: 110',
                  suffixIcon: Icon(Icons.water_drop, color: Colors.redAccent), // Icono de gota rojo
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Momento del día',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: _inputDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMoment,
                  hint: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text('Toca para seleccionar', style: TextStyle(color: Colors.grey.shade500)),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.keyboard_arrow_down, color: AppTheme.colorPrimary),
                  ),
                  isExpanded: true,
                  dropdownColor: AppTheme.colorBgSecondary,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMoment = newValue;
                    });
                  },
                  items: _momentOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(value, style: const TextStyle(color: AppTheme.colorTextPrimary)),
                      ),
                    );
                  }).toList(),
                ),
              ),
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
              'Notas (opcional · máx. 255 caracteres)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: _inputDecoration(),
              child: TextField(
                controller: _notesController,
                maxLines: 6,
                minLines: 3,
                maxLength: 255,
                style: const TextStyle(color: AppTheme.colorTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Ej: Me sentí un poco mareado antes de medir...',
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
                  'Guardar Entrada',
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