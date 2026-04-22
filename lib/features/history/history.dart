import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/database/database_helper.dart';
import './record_detail.dart'; 

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'Todos';
  bool _isLoading = true;
  List<Map<String, dynamic>> _historyData = [];

  final List<Map<String, dynamic>> _filters = [
    {'label': 'Todos', 'icon': null},
    {'label': 'Insulina', 'icon': Icons.vaccines},
    {'label': 'Glucosa', 'icon': Icons.water_drop},
    {'label': 'Síntomas', 'icon': Icons.sentiment_dissatisfied},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  String _formatDate(DateTime date) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    int h = date.hour;
    String m = date.minute.toString().padLeft(2, '0');
    String period = h >= 12 ? 'pm' : 'am';
    h = h % 12;
    if (h == 0) h = 12;
    return '$h:$m $period';
  }

  Future<void> _loadHistoryData() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> combinedData = [];

    final glucosaRecords = await db.query(DatabaseHelper.tableRegGlucosa);
    for (var row in glucosaRecords) {
      final fecha = DateTime.parse(row['fecha_hora'] as String);
      final valor = row['valor'] as int;
      final momento = row['momento_dia'] as String;
      
      String statusText = 'Normal';
      IconData statusIcon = Icons.check;
      Color color = Colors.green;
      String titleSufix = 'Normal';

      if (valor < 70) {
        statusText = 'Bajo';
        statusIcon = Icons.warning_amber_rounded;
        color = Colors.red;
        titleSufix = 'Hipoglucemia';
      } else if (valor > 140) { 
        statusText = 'Alto';
        statusIcon = Icons.arrow_upward;
        color = Colors.orange;
        titleSufix = 'Hiperglucemia';
      }

      combinedData.add({
        'type': 'Glucosa',
        'title': '$valor mg/dL — $titleSufix',
        'subtitle': '${_formatDate(fecha)} · ${_formatTime(fecha)} · $momento',
        'statusText': statusText,
        'statusIcon': statusIcon,
        'color': color,
        'icon': Icons.water_drop,
        'timestamp': fecha, 
        'rawRecord': row,
        'recordType': RecordType.glucosa, 
      });
    }

    final insulinaRecords = await db.rawQuery('''
      SELECT r.*, c.subtipo 
      FROM ${DatabaseHelper.tableRegInsulina} r
      JOIN ${DatabaseHelper.tableCatTipoInsulina} c 
      ON r.id_tipo_insu = c.id_tipo_insu
    ''');
    
    for (var row in insulinaRecords) {
      final fecha = DateTime.parse(row['fecha_hora'] as String);
      final unidades = row['unidades'] as int;
      final subtipo = row['subtipo'] as String;

      combinedData.add({
        'type': 'Insulina',
        'title': '$unidades Unidades — $subtipo',
        'subtitle': '${_formatDate(fecha)} · ${_formatTime(fecha)}',
        'statusText': 'Registrado',
        'statusIcon': Icons.check_circle_outline,
        'color': AppTheme.colorPrimary,
        'icon': Icons.vaccines,
        'timestamp': fecha,
        'rawRecord': row,
        'recordType': RecordType.insulina,
      });
    }

    final sintomasRecords = await db.query(DatabaseHelper.tableRegSintomas);
    for (var row in sintomasRecords) {
      final fecha = DateTime.parse(row['fecha_hora'] as String);
      final severidad = row['severidad'] as String;
      final notas = row['notas'] as String? ?? 'Sin notas';
      Color colorSintoma = Colors.purple.shade400;
      if (severidad.toLowerCase() == 'alta') colorSintoma = AppTheme.colorError;

      combinedData.add({
        'type': 'Síntomas',
        'title': 'Severidad: $severidad',
        'subtitle': '${_formatDate(fecha)} · ${_formatTime(fecha)} · $notas',
        'statusText': 'Registrado',
        'statusIcon': Icons.sentiment_dissatisfied,
        'color': colorSintoma,
        'icon': Icons.sentiment_dissatisfied,
        'timestamp': fecha,
        'rawRecord': row,
        'recordType': RecordType.sintoma,
      });
    }

    combinedData.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    setState(() {
      _historyData = combinedData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filteredData = _selectedFilter == 'Todos'
        ? _historyData
        : _historyData.where((item) => item['type'] == _selectedFilter).toList();

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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.colorPrimary))
        : Column(
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
                      selectedColor: AppTheme.colorPrimary, 
                      backgroundColor: Colors.white, 
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No hay registros de $_selectedFilter',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecordDetailPage(
                                record: item['rawRecord'], 
                                recordType: item['recordType'],
                              ),
                            ),
                          ).then((_) {
                            _loadHistoryData();
                          });
                        },
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
    required VoidCallback onTap, 
  }) {
    return GestureDetector( 
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color.withOpacity(0.03), 
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
      ),
    );
  }
}