import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/database/database_helper.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isLoading = true;
  List<FlSpot> _glucoseSpots = [];
  int _avgGlucose = 0;
  int _avgInsulin = 0;
  int _alerts = 0;
  int _normalRecords = 0;
  int _totalGlucoseRecords = 0;

  @override
  void initState() {
    super.initState();
    _loadStatisticsData();
  }

  Future<void> _loadStatisticsData() async {
    final db = await DatabaseHelper.instance.database;

    final glucosaRecords = await db.query(
      DatabaseHelper.tableRegGlucosa,
      orderBy: 'fecha_hora ASC',
      limit: 7,
    );

    List<FlSpot> spots = [];
    double totalGlucose = 0;
    int alertCount = 0;
    int normalCount = 0;

    for (int i = 0; i < glucosaRecords.length; i++) {
      final row = glucosaRecords[i];
      final valor = row['valor'] as int;

      totalGlucose += valor;

      if (valor < 70 || valor > 140) {
        alertCount++;
      } else {
        normalCount++;
      }

      spots.add(FlSpot(i.toDouble(), valor.toDouble()));
    }

    final insulinaRecords = await db.query(DatabaseHelper.tableRegInsulina);
    double totalInsulin = 0;
    for (var row in insulinaRecords) {
      totalInsulin += (row['unidades'] as int);
    }

    setState(() {
      _glucoseSpots = spots;
      _totalGlucoseRecords = glucosaRecords.length;
      _avgGlucose = _totalGlucoseRecords > 0
          ? (totalGlucose / _totalGlucoseRecords).round()
          : 0;
      _alerts = alertCount;
      _normalRecords = normalCount;
      _avgInsulin = insulinaRecords.isNotEmpty
          ? (totalInsulin / insulinaRecords.length).round()
          : 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        title: const Text(
          'Estadísticas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.colorBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                      'PROM. MG/DL',
                      '$_avgGlucose',
                      Colors.teal,
                    ),
                    _buildSummaryCard(
                      'PROM. INSULINA',
                      '$_avgInsulin UI',
                      Colors.blue,
                    ),
                    _buildSummaryCard('ALERTAS', '$_alerts', Colors.red),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Glucosa (mg/dL) y Insulina (UI) — Últimos 7 días',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 200,
                        child: _glucoseSpots.isEmpty
                            ? const Center(
                                child: Text("No hay datos suficientes"),
                              )
                            : LineChart(
                                LineChartData(
                                  gridData: const FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                  ),
                                  titlesData: FlTitlesData(
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 1,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                              const style = TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              );
                                              Widget text;
                                              switch (value.toInt()) {
                                                case 0:
                                                  text = const Text(
                                                    'L',
                                                    style: style,
                                                  );
                                                  break;
                                                case 1:
                                                  text = const Text(
                                                    'M',
                                                    style: style,
                                                  );
                                                  break;
                                                case 2:
                                                  text = const Text(
                                                    'M',
                                                    style: style,
                                                  );
                                                  break;
                                                case 3:
                                                  text = const Text(
                                                    'J',
                                                    style: style,
                                                  );
                                                  break;
                                                case 4:
                                                  text = const Text(
                                                    'V',
                                                    style: style,
                                                  );
                                                  break;
                                                case 5:
                                                  text = const Text(
                                                    'S',
                                                    style: style,
                                                  );
                                                  break;
                                                case 6:
                                                  text = const Text(
                                                    'D',
                                                    style: style,
                                                  );
                                                  break;
                                                default:
                                                  text = const Text(
                                                    '',
                                                    style: style,
                                                  );
                                                  break;
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: text,
                                              );
                                            },
                                      ),
                                    ),

                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        interval: 20,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: Text(
                                                  value.toInt().toString(),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _glucoseSpots,
                                      isCurved: false,
                                      color: Colors.teal,
                                      barWidth: 3,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.teal.withOpacity(0.1),
                                      ),
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) {
                                              bool isAlert =
                                                  spot.y > 140 || spot.y < 70;
                                              return FlDotCirclePainter(
                                                radius: isAlert ? 5 : 4,
                                                color: isAlert
                                                    ? Colors.red
                                                    : Colors.white,
                                                strokeWidth: 2,
                                                strokeColor: isAlert
                                                    ? Colors.red
                                                    : Colors.teal,
                                              );
                                            },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(Colors.teal, 'Glucosa'),
                          const SizedBox(width: 16),
                          _buildLegendItem(Colors.blue.shade300, 'Insulina'),
                          const SizedBox(width: 16),
                          _buildLegendItem(
                            Colors.red,
                            'Alerta',
                            isCircle: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Promedio de glucosa',
                        '$_avgGlucose mg/dL',
                        Colors.teal,
                        true,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildDetailRow(
                        'Registros normales',
                        '$_normalRecords de $_totalGlucoseRecords',
                        Colors.black87,
                        true,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildDetailRow(
                        'Episodios de alerta',
                        '$_alerts episodio${_alerts == 1 ? '' : 's'}',
                        Colors.red,
                        true,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildDetailRow(
                        'Insulina promedio',
                        '$_avgInsulin UI / día',
                        Colors.black87,
                        true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), 
              ],
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color valueColor) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isCircle = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: isCircle
                ? BorderRadius.circular(6)
                : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor,
    bool isBoldValue,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
