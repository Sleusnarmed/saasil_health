import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InsulinLogPage extends StatefulWidget {
  const InsulinLogPage({super.key});

  @override
  State<InsulinLogPage> createState() => _InsulinLogPageState();
}

class _InsulinLogPageState extends State<InsulinLogPage> {
  final TextEditingController _unitsController = TextEditingController();
  String _selectedType = 'Bolo'; 
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.colorPrimary,
              onPrimary: AppTheme.colorTextSecondary,
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

  void _saveEntry() {
    final units = _unitsController.text;
    print("Guardando: $units U de $_selectedType el $_selectedDate a las $_selectedTime");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Registro guardado correctamente!', style: TextStyle(fontSize: 16)),
        backgroundColor: AppTheme.colorPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    _unitsController.clear();
  }

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.colorBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.colorPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Registro de Insulina', style: textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.colorPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosis (Unidades)', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _unitsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: textTheme.displayLarge?.copyWith(fontSize: 28), // Número muy grande
              decoration: InputDecoration(
                hintText: '0.0',
                filled: true,
                fillColor: AppTheme.colorBgSecondary,
                suffixIcon: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.vaccines, color: AppTheme.colorPrimary, size: 32),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
            const SizedBox(height: 20),

            Text('Tipo de Insulina', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTypeSelector(
                    title: 'Bolo\n(Rápida / Comidas)',
                    icon: Icons.restaurant,
                    isSelected: _selectedType == 'Bolo',
                    onTap: () => setState(() => _selectedType = 'Bolo'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTypeSelector(
                    title: 'Basal\n(Lenta / Fondo)',
                    icon: Icons.bedtime,
                    isSelected: _selectedType == 'Basal',
                    onTap: () => setState(() => _selectedType = 'Basal'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha', style: textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _buildDateTimeField(
                        text: "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hora', style: textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _buildDateTimeField(
                        text: _selectedTime.format(context),
                        icon: Icons.access_time,
                        onTap: () => _selectTime(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppTheme.colorPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text('Guardar Entrada', style: textTheme.titleMedium?.copyWith(color: AppTheme.colorTextSecondary, fontSize: 20)),
              ),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Historial Reciente', style: textTheme.titleMedium),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Ver Todo", style: TextStyle(color: AppTheme.colorPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('HOY', style: textTheme.bodySmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Lista Mockeada (Aquí iría un ListView.builder leyendo de la Base de Datos)
            _buildHistoryCard(context, units: "8.5", type: "Bolo", time: "08:30 AM", icon: Icons.restaurant),
            _buildHistoryCard(context, units: "12.0", type: "Bolo", time: "01:15 PM", icon: Icons.restaurant),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField({required String text, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.colorBgSecondary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Icon(icon, color: AppTheme.colorPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector({required String title, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.colorPrimary : AppTheme.colorBgSecondary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? AppTheme.colorPrimary : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.colorPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? AppTheme.colorTextSecondary : AppTheme.colorPrimary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.colorTextSecondary : AppTheme.colorTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, {required String units, required String type, required String time, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colorBgSecondary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.colorSecondary.withOpacity(0.2), // Light blue background
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.colorPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$units Unidades", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("$type • $time", style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}