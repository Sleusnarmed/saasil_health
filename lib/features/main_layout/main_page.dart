import 'package:flutter/material.dart';
import 'package:saasil_health/features/glucose/glucose.dart';
import '../../core/theme/app_theme.dart';
import '../home/home.dart';
import '../insulin/insulin.dart';
import '../history/history.dart';
import '../chat/chat.dart';
import '../reminders/reminder.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.colorBgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  '¿Qué deseas registrar?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colorPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                _buildMenuOption(
                  context,
                  icon: Icons.vaccines,
                  title: 'Registro de Insulina',
                  subtitle: 'Añade tu dosis aplicada',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InsulinLogPage(),
                      ),
                    );
                  },
                ),

                _buildMenuOption(
                  context,
                  icon: Icons.bloodtype,
                  title: 'Niveles de Glucosa',
                  subtitle: 'Añade tu medición más reciente',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GlucoseLogPage(),
                      ),
                    );
                  },
                ),

                _buildMenuOption(
                  context,
                  icon: Icons.sick_outlined,
                  title: 'Síntomas',
                  subtitle: 'Registra cómo te sientes hoy',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const SymptomsLogPage(), // Tu pantalla
                    //   ),
                    // );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.colorPrimary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.colorPrimary, size: 28),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const ChatPage(),
    const RemindersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return _buildMainLayout(context);
  }

  Widget _buildMainLayout(BuildContext context) {
    final barColor = AppTheme.colorBgSecondary;

    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      body: IndexedStack(index: _currentIndex, children: _pages),

      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
          child: BottomAppBar(
            height: 80,
            color: barColor,
            elevation: 0,
            notchMargin: 10.0,
            shape: const CircularNotchedRectangle(),
            clipBehavior: Clip.antiAlias,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, "Inicio"),
                _buildNavItem(1, Icons.menu_book_rounded, "Historial"),
                const SizedBox(width: 40),
                _buildNavItem(2, Icons.smart_toy_outlined, "Chat IA"),
                _buildNavItem(3, Icons.notifications_none_rounded, "Avisos"),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: AppTheme.colorPrimary,
        elevation: 2,
        child: Icon(
          Icons.add_rounded,
          color: AppTheme.colorTextSecondary,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final textTheme = Theme.of(context).textTheme;
    final isSelected = _currentIndex == index;

    final Color color = isSelected
        ? AppTheme.colorPrimary
        : AppTheme.colorTextPrimary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
