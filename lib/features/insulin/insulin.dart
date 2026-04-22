import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/reg_insulin.dart';
import '../../core/database/database_helper.dart';

class InsulinLogPage extends StatefulWidget {
  const InsulinLogPage({super.key});

  @override
  State<InsulinLogPage> createState() => _InsulinLogPageState();
}

class _InsulinLogPageState extends State<InsulinLogPage> {
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String? _selectedActionType;
  final List<String> _actionTypes = [
    'Rápida',
    'Corta',
    'Intermedia',
    'Prolongada',
  ];

  @override
  void dispose() {
    _doseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final doseText = _doseController.text;
    final dose = int.tryParse(doseText) ?? 0;
    final notesText = _notesController.text;

    if (dose == 0 || _selectedActionType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, ingresa una dosis válida y selecciona un tipo de acción.'),
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

    // Sumamos 1 al index para que empate con los IDs de tu catálogo (1, 2, 3...)
    // evitando así errores de Foreign Key en SQLite.
    final newEntry = RegInsulina(
      unidades: dose,
      idTipoInsu: _actionTypes.indexOf(_selectedActionType!) + 1,
      fechaHora: finalDateTime,
      notas: notesText.trim().isNotEmpty ? notesText.trim() : null,
    );

    try {
      // 1. Abrimos la instancia de la BD
      final db = await DatabaseHelper.instance.database;
      
      // 2. Insertamos el registro
      await db.insert(
        DatabaseHelper.tableRegInsulina,
        newEntry.toMap(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro de insulina guardado correctamente!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Limpiamos o regresamos
        _doseController.clear();
        _notesController.clear();
        setState(() {
          _selectedActionType = null;
        });
        
        // Opcional: si quieres que se cierre la pantalla tras guardar, descomenta la siguiente línea
        // Navigator.pop(context);
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

  // Decoración reutilizable para usar los colores de tu AppTheme
  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: AppTheme.colorBgSecondary, // Fondo blanco de tu tema
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade300, width: 1), // Borde sutil para que resalte
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground, // Fondo gris/azulado claro de tu tema
      appBar: AppBar(
        title: const Text(
          'Registro de Insulina',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
        ),
        backgroundColor: Colors.transparent, // Transparente para que tome el colorBackground
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
              'Dosis (Unidades)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: _inputDecoration(),
              child: TextField(
                controller: _doseController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.colorTextPrimary),
                decoration: const InputDecoration(
                  hintText: '0.0',
                  suffixIcon: Icon(Icons.vaccines, color: AppTheme.colorPrimary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Tipo de Acción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.colorTextPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: _inputDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedActionType,
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
                      _selectedActionType = newValue;
                    });
                  },
                  items: _actionTypes.map<DropdownMenuItem<String>>((String value) {
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
                  hintText: 'Ej: Aplicada en el abdomen antes del desayuno...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Botón de Guardar
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