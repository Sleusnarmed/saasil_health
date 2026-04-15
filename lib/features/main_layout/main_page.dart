import 'package:flutter/material.dart';
import 'package:saasil_health/core/theme/app_theme.dart';
import 'package:saasil_health/features/home/home.dart';
import 'package:saasil_health/features/insulin/insulin.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<String> _appBarTitles = [
    'Sáasil Health',
    'Historial',
    'Chat IA',
    'Recordatorios',
  ];

  final List<Widget> _pages = [
    HomePage(), 
    InsulinLogPage(),
    const Center(child: Text('Pantalla de Chat IA', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Pantalla de Recordatorios', style: TextStyle(fontSize: 24))),
  ];

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué deseas registrar?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              _buildMenuOption(
                context,
                icon: Icons.water_drop,
                color: Colors.redAccent,
                title: 'Nivel de Glucosa',
                onTap: () {
                  Navigator.pop(context); 
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const GlucosePage()));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navegando a Glucosa...')));
                },
              ),
              const SizedBox(height: 15),
              _buildMenuOption(
                context,
                icon: Icons.vaccines,
                color: Colors.blueAccent,
                title: 'Dosis de Insulina',
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const InsulinPage()));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navegando a Insulina...')));
                },
              ),
              const SizedBox(height: 15),
              _buildMenuOption(
                context,
                icon: Icons.sentiment_dissatisfied,
                color: Colors.orange,
                title: 'Síntoma o Malestar',
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const SymptomsPage()));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navegando a Síntomas...')));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(BuildContext context, {required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        radius: 25,
        child: Icon(icon, color: color, size: 30),
      ),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_currentIndex], 
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true, 
        backgroundColor: AppTheme.colorBgSecondary,
        surfaceTintColor: Colors.transparent, 
        elevation: 1,
        shadowColor: AppTheme.colorTextPrimary.withOpacity(0.2), 
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 35, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home_rounded, label: 'Inicio', index: 0),
            _buildNavItem(icon: Icons.menu_book_rounded, label: 'Historial', index: 1),
            const SizedBox(width: 48), 
            _buildNavItem(icon: Icons.smart_toy_rounded, label: 'Chat IA', index: 2),
            _buildNavItem(icon: Icons.notifications_rounded, label: 'Avisos', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade500;
    
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}