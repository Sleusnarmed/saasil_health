import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      
      appBar: AppBar(
        backgroundColor: AppTheme.colorBackground,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Saasil Health', 
          style: textTheme.titleLarge, 
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.colorPrimary),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 80), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Buenos días, Alex", 
              style: textTheme.bodyLarge?.copyWith(color: AppTheme.colorTextPrimary), 
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _buildStatusCard(context, "Glucosa Actual", "110", "mg/dL", Icons.water_drop, AppTheme.colorPrimary)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatusCard(context, "Insulina de hoy", "12", "Unidades", Icons.vaccines, AppTheme.colorPrimary)),
              ],
            ),

            const SizedBox(height: 30),
            Text(
              "ACCIONES RÁPIDAS", 
              style: textTheme.bodySmall?.copyWith(
                color: AppTheme.colorPrimary, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.2
              )
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
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionButton(
                    context, 
                    title: "Glucosa", 
                    icon: Icons.bloodtype_outlined, 
                    color: AppTheme.colorError, 
                    onTap: () {},
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
                  onTap: () {},
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
                    letterSpacing: 1.2
                  )
                ),
                TextButton(
                  onPressed: () {}, 
                  child: Text("Ver Todo", style: TextStyle(color: AppTheme.colorPrimary))
                ),
              ],
            ),
            

            _buildReminderCard(
              context,
              icon: Icons.access_time_filled_rounded,
              iconColor: AppTheme.colorPrimary, 
              iconBgColor: AppTheme.colorSecondary,
              title: "Control Pre-almuerzo",
              description: "Hora de registrar tu glucosa",
              time: "12:30 PM",
            ),
            _buildReminderCard(
              context,
              icon: Icons.restaurant_menu_rounded,
              iconColor: AppTheme.colorPrimary, 
              iconBgColor: AppTheme.colorSecondary,
              title: "Bolo Almuerzo",
              description: "Basado en estimación de 45g carbohidratos",
              time: "1:00 PM",
            ),
            
            /*  -- TO DO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "¡No hay recordatorios pendientes! Disfruta tu día.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }

  // Build status 
Widget _buildStatusCard(BuildContext context, String title, String value, String unit, IconData icon, Color color) {
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
        )
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
            Text(
              title,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.colorTextPrimary,
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
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppTheme.colorTextPrimary,
              ),
            ),
            const SizedBox(width: 10),
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

  // Quick actions
  Widget _buildActionButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppTheme.colorTextSecondary, size: 20),
      label: Text(
        title, 
        style: TextStyle(
          fontFamily: 'NunitoSans', 
          color: AppTheme.colorTextSecondary, 
          fontWeight: FontWeight.bold, 
          fontSize: 15
        )
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
    
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  // Reminder Card
  Widget _buildReminderCard(BuildContext context, {
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
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodySmall,
                ),
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