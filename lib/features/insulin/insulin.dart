import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:saasil_health/core/models/reg_insulin.dart';
import '../../core/database/database_helper.dart';

class InsulinLogPage extends StatefulWidget {
  const InsulinLogPage({super.key});

  @override
  State<InsulinLogPage> createState() => _InsulinLogPageState();
}

class _InsulinLogPageState extends State<InsulinLogPage> {
  final TextEditingController _unitsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  List<Map<String, dynamic>> _recentHistory = [];
  bool _isLoadingHistory = true;
  String _dayLabel = ""; 

  final Map<String, List<String>> _insulinaData = {
    'Acción Rápida': ['Aspart', 'Lispro', 'Glusilina'],
    'Acción Corta': ['Regular'],
    'Acción Intermedia': ['NPH'],
    'Acción Prolongada': ['Glargina', 'Detemir', 'Degludec'],
    'Inhalada': ['Polvo de insulina humana'],
  };

  String? _selectedCategory;
  String? _selectedSubtype;

  @override
  void initState() {
    super.initState();
    _loadHistory(); 
  }

  Future<void> _loadHistory() async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT r.unidades, r.fecha_hora, c.categoria, c.subtipo 
        FROM ${DatabaseHelper.tableRegInsulina} r
        INNER JOIN ${DatabaseHelper.tableCatTipoInsulina} c ON r.id_tipo_insu = c.id_tipo_insu
        ORDER BY r.fecha_hora DESC
      ''');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      List<Map<String, dynamic>> todayLogs = [];
      List<Map<String, dynamic>> yesterdayLogs = [];

      for (var row in result) {
        DateTime logDate = DateTime.parse(row['fecha_hora']);
        DateTime logDay = DateTime(logDate.year, logDate.month, logDate.day);
        
        if (logDay == today) {
          todayLogs.add(row);
        } else if (logDay == yesterday) {
          yesterdayLogs.add(row);
        }
      }

      if (mounted) {
        setState(() {
          if (todayLogs.isNotEmpty) {
            _recentHistory = todayLogs;
            _dayLabel = "HOY";
          } else if (yesterdayLogs.isNotEmpty) {
            _recentHistory = yesterdayLogs;
            _dayLabel = "AYER";
          } else {
            _recentHistory = []; 
            _dayLabel = "";
          }
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false; // Apagamos el loading para que no se quede trabado
        });
      }
    }
  }

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

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.colorBgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: _insulinaData.keys.map((category) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                title: Text(category, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.colorPrimary),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                    if (_insulinaData[category]!.length == 1) {
                      _selectedSubtype = _insulinaData[category]![0];
                    } else {
                      _selectedSubtype = null; 
                    }
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showSubtypePicker() {
    if (_selectedCategory == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.colorBgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: _insulinaData[_selectedCategory]!.map((subtype) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                title: Text(subtype, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.check_circle_outline, color: AppTheme.colorPrimary),
                onTap: () {
                  setState(() {
                    _selectedSubtype = subtype;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _saveEntry() async {
    final units = _unitsController.text;
    
    if (units.isEmpty || _selectedCategory == null || _selectedSubtype == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos', style: TextStyle(fontSize: 16)),
          backgroundColor: AppTheme.colorError,
        ),
      );
      return;
    }

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> resultado = await db.query(
        DatabaseHelper.tableCatTipoInsulina,
        where: 'categoria = ? AND subtipo = ?',
        whereArgs: [_selectedCategory, _selectedSubtype],
      );
      
      if (resultado.isNotEmpty) {
        final int idTipoInsu = resultado.first['id_tipo_insu'];
        
        final nuevoRegistro = RegInsulina(
          unidades: int.parse(units), 
          idTipoInsu: idTipoInsu,
          fechaHora: DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day,
            _selectedTime.hour, _selectedTime.minute
          ),
        );
        
        await db.insert(DatabaseHelper.tableRegInsulina, nuevoRegistro.toMap());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Registro guardado correctamente!', style: TextStyle(fontSize: 16)),
              backgroundColor: AppTheme.colorPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          
          setState(() {
            _unitsController.clear();
            _selectedCategory = null;
            _selectedSubtype = null;
          });

          _loadHistory(); // RSe recarga automaticamente
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontró este tipo de insulina en la base de datos.', style: TextStyle(fontSize: 16)),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("🚨 ERROR AL GUARDAR: $e");
    }
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
              style: textTheme.displayLarge?.copyWith(fontSize: 28),
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

            Text('Tipo de Acción', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildLargeSelectionButton(
              text: _selectedCategory ?? 'Toca para seleccionar',
              icon: Icons.speed,
              isPlaceholder: _selectedCategory == null,
              onTap: _showCategoryPicker,
            ),
            const SizedBox(height: 20),

            if (_selectedCategory != null) ...[
              Text('Insulina Específica', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildLargeSelectionButton(
                text: _selectedSubtype ?? 'Toca para elegir insulina',
                icon: Icons.medication,
                isPlaceholder: _selectedSubtype == null,
                onTap: _insulinaData[_selectedCategory]!.length > 1 ? _showSubtypePicker : null,
              ),
              const SizedBox(height: 20),
            ],

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
            if (_isLoadingHistory)
              const Center(child: CircularProgressIndicator(color: AppTheme.colorPrimary))
            else if (_recentHistory.isEmpty)
              const SizedBox.shrink() 
            else ...[
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
                ],
              ),
              const SizedBox(height: 10),
              Text(_dayLabel, style: textTheme.bodySmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ..._recentHistory.map((log) {
                DateTime logDate = DateTime.parse(log['fecha_hora']);
                String formattedTime = TimeOfDay.fromDateTime(logDate).format(context);
                
                return _buildHistoryCard(
                  context, 
                  units: log['unidades'].toString(), 
                  type: "${log['categoria']} (${log['subtipo']})", 
                  time: formattedTime, 
                  icon: Icons.water_drop
                );
              }),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLargeSelectionButton({
    required String text, 
    required IconData icon, 
    required bool isPlaceholder, 
    VoidCallback? onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isPlaceholder ? AppTheme.colorBgSecondary : AppTheme.colorPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isPlaceholder ? Colors.grey.shade300 : AppTheme.colorPrimary,
            width: isPlaceholder ? 1 : 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isPlaceholder ? Colors.grey : AppTheme.colorPrimary, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.bold,
                  color: isPlaceholder ? Colors.grey.shade600 : AppTheme.colorPrimary,
                ),
              ),
            ),
            if (onTap != null) 
              Icon(Icons.keyboard_arrow_down, color: isPlaceholder ? Colors.grey : AppTheme.colorPrimary),
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
              color: AppTheme.colorSecondary.withOpacity(0.2),
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
        ],
      ),
    );
  }
}