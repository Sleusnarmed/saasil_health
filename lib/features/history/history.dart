import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'Todos';

  final List<Map<String, dynamic>> _filters = [
    {'label': 'Todos', 'icon': null},
    {'label': 'Insulina', 'icon': Icons.vaccines},
    {'label': 'Glucosa', 'icon': Icons.water_drop},
    {'label': 'Síntomas', 'icon': Icons.sentiment_dissatisfied},
  ];

  final List<Map<String, dynamic>> _mockData = [
    {
      'type': 'Glucosa',
      'title': '220 mg/dL — Hiperglucemia',
      'subtitle': '14 abr · 1:00 pm · Después de comer',
      'statusText': 'Alto',
      'statusIcon': Icons.arrow_upward,
      'color': Colors.orange,
      'icon': Icons.water_drop,
    },
    {
      'type': 'Glucosa',
      'title': '115 mg/dL — Normal',
      'subtitle': '14 abr · 8:05 am · Antes de comer',
      'statusText': 'Normal',
      'statusIcon': Icons.check,
      'color': Colors.green,
      'icon': Icons.water_drop,
    },
    {
      'type': 'Glucosa',
      'title': '62 mg/dL — Hipoglucemia',
      'subtitle': '12 abr · 6:10 am · En ayunas',
      'statusText': 'Bajo',
      'statusIcon': Icons.warning_amber_rounded,
      'color': Colors.red,
      'icon': Icons.water_drop,
    },
    {
      'type': 'Insulina',
      'title': '12 Unidades — Rápida',
      'subtitle': '12 abr · 2:00 pm · Aspart',
      'statusText': 'Registrado',
      'statusIcon': Icons.check_circle_outline,
      'color': AppTheme.colorPrimary,
      'icon': Icons.vaccines,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final filteredData = _selectedFilter == 'Todos'
        ? _mockData
        : _mockData.where((item) => item['type'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.colorBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Historial',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.colorBackground,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter['label'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (filter['icon'] != null) ...[
                            Icon(
                              filter['icon'],
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            filter['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter['label'];
                        });
                      },
                      selectedColor:
                          AppTheme.colorPrimary, 
                      backgroundColor:
                          Colors.white, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.colorPrimary
                              : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: filteredData.isEmpty
                ? Center(
                    child: Text(
                      'No hay registros de $_selectedFilter',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final item = filteredData[index];
                      return _buildRecordCard(
                        context: context,
                        title: item['title'],
                        subtitle: item['subtitle'],
                        statusText: item['statusText'],
                        statusIcon: item['statusIcon'],
                        color: item['color'],
                        icon: item['icon'],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String statusText,
    required IconData statusIcon,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior:
          Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withOpacity(
          0.03,
        ), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: color),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.colorTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
