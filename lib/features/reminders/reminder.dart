import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/config_reminder.dart';
import '../../core/database/database_helper.dart';
import './create_reminders.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<ConfigRecordatorios> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(DatabaseHelper.tableConfigRecordatorios);

    setState(() {
      _reminders = maps.map((map) => ConfigRecordatorios.fromMap(map)).toList();
      _isLoading = false;
    });
  }

  Future<void> _toggleReminder(
    ConfigRecordatorios reminder,
    bool newValue,
  ) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      DatabaseHelper.tableConfigRecordatorios,
      {'activo': newValue ? 1 : 0},
      where: 'id_recordatorio = ?',
      whereArgs: [reminder.idRecordatorio],
    );
    _loadReminders();
  }

  Future<void> _navigateToAddReminder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateReminderPage()),
    );

    if (result == true) {
      _loadReminders();
    }
  }

  Widget _getIconForTitle(String title) {
    String lowerTitle = title.toLowerCase();
    IconData iconData = Icons.alarm;
    Color bgColor = Colors.grey.shade100;
    Color iconColor = Colors.grey.shade700;

    if (lowerTitle.contains('insulina')) {
      iconData = Icons.vaccines;
      bgColor = const Color(0xFFE3F2FD);
      iconColor = const Color(0xFF64B5F6);
    } else if (lowerTitle.contains('glucosa')) {
      iconData = Icons.water_drop;
      bgColor = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFE53935);
    } else if (lowerTitle.contains('cita') || lowerTitle.contains('médico')) {
      iconData = Icons.assignment;
      bgColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF81C784);
    } else if (lowerTitle.contains('medicamento') ||
        lowerTitle.contains('pastilla')) {
      iconData = Icons.medication;
      bgColor = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFFFB300);
    } else if (lowerTitle.contains('comer') || lowerTitle.contains('comida')) {
      iconData = Icons.restaurant;
      bgColor = const Color(0xFFF3E5F5);
      iconColor = const Color(0xFFBA68C8);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBgSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Recordatorios',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_reminders.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      'ACTIVOS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                Expanded(
                  child: _reminders.isEmpty
                      ? Center(
                          child: Text(
                            'No tienes recordatorios aún.',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = _reminders[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: _getIconForTitle(reminder.titulo),
                                title: Text(
                                  reminder.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  '${reminder.hora} · ${reminder.frecuencia}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Switch(
                                  value: reminder.activo,
                                  onChanged: (val) =>
                                      _toggleReminder(reminder, val),
                                  activeTrackColor: AppTheme.colorPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: _navigateToAddReminder,
                      icon: const Icon(
                        Icons.add_task,
                        color: Colors.white,
                        size: 24,
                      ),
                      label: const Text(
                        'Agregar recordatorio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colorPrimary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
