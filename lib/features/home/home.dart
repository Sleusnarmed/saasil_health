import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/config_reminder.dart'; 
import '../glucose/glucose.dart'; 
import '../symptoms/symptoms.dart'; 
import '../insulin/insulin.dart';
import '../reminders/reminder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _glucoseValue = "NA";
  String _insulinValue = "NA";
  bool _isLoading = true;

  List<ConfigRecordatorios> _upcomingReminders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;

    try {
      final glucoseResult = await db.query(
        DatabaseHelper.tableRegGlucosa,
        orderBy: 'fecha_hora DESC',
        limit: 1,
      );

      if (glucoseResult.isNotEmpty) {
        _glucoseValue = glucoseResult.first['valor'].toString();
      } else {
        _glucoseValue = "NA";
      }

      final now = DateTime.now();
      final todayStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final insulinResult = await db.query(
        DatabaseHelper.tableRegInsulina,
        where: "fecha_hora LIKE ?",
        whereArgs: ['$todayStr%'],
      );

      if (insulinResult.isNotEmpty) {
        int totalInsulin = 0;
        for (var row in insulinResult) {
          totalInsulin += (row['unidades'] as int);
        }
        _insulinValue = totalInsulin.toString();
      } else {
        _insulinValue = "NA";
      }

      final remindersResult = await db.query(
        DatabaseHelper.tableConfigRecordatorios,
        where: 'activo = ?',
        whereArgs: [1], 
        limit: 3,
      );
      
      _upcomingReminders = remindersResult
          .map((map) => ConfigRecordatorios.fromMap(map))
          .toList();

    } catch (e) {
      debugPrint("Error cargando datos del home: $e");
      _glucoseValue = "NA";
      _insulinValue = "NA";
      _upcomingReminders = [];
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.colorPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Buenos días, Usuario",
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.colorTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      context,
                      "Glucosa Actual",
                      _isLoading ? "..." : _glucoseValue,
                      "mg/dL",
                      Icons.water_drop,
                      AppTheme.colorPrimary,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatusCard(
                      context,
                      "Insulina de hoy",
                      _isLoading ? "..." : _insulinValue,
                      "Unidades",
                      Icons.vaccines,
                      AppTheme.colorPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Text(
                "ACCIONES RÁPIDAS",
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.colorPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      title: "Insulina",
                      icon: Icons.add_circle_outline,
                      color: AppTheme.colorPrimary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InsulinLogPage(),
                          ),
                        ).then((_) => _loadData()); 
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      title: "Glucosa",
                      icon: Icons.bloodtype_outlined,
                      color: AppTheme.colorError,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GlucoseLogPage(),
                          ),
                        ).then((_) => _loadData()); 
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: _buildActionButton(
                    context,
                    title: "Registrar Síntoma",
                    icon: Icons.sentiment_dissatisfied_outlined,
                    color: AppTheme.colorTertiary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SymptomsLogPage(),
                        ),
                      ).then((_) => _loadData());
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "PRÓXIMOS RECORDATORIOS",
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.colorPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RemindersPage(),
                        ),
                      ).then((_) => _loadData()); 
                    },
                    child: const Text(
                      "Ver Todo",
                      style: TextStyle(color: AppTheme.colorPrimary),
                    ),
                  ),
                ],
              ),

              if (_upcomingReminders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      "¡No hay recordatorios pendientes! Disfruta tu día.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._upcomingReminders.map((reminder) {
                  return _buildReminderCard(
                    context,
                    icon: Icons.notifications_active_rounded, 
                    iconColor: AppTheme.colorPrimary,
                    iconBgColor: AppTheme.colorSecondary,
                    title: reminder.titulo,
                    description: reminder.frecuencia, 
                    time: reminder.hora,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colorBgSecondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.colorTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const SizedBox(width: 10),
              Text(
                value,
                style: textTheme.displayLarge?.copyWith(
                  fontSize: value.length > 3 ? 24 : 34,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colorTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: AppTheme.colorTextPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppTheme.colorTextSecondary, size: 20),
      label: Text(
        title,
        style: const TextStyle(
          fontFamily: 'NunitoSans',
          color: AppTheme.colorTextSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required String time,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colorBgSecondary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            time,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}