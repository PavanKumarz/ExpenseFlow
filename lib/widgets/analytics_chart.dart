import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;
  final double maxY;

  const AnalyticsChart({
    super.key,
    required this.dailyData,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: Container(
        height: 220,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY == 0 ? 100 : maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.white.withOpacity(0.9),
                tooltipBorderRadius: BorderRadius.circular(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final day = dailyData[groupIndex]['day'];
                  final income = dailyData[groupIndex]['income'];
                  final expense = dailyData[groupIndex]['expense'];
                  return BarTooltipItem(
                    '$day\n',
                    const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Income: \$${income.toStringAsFixed(0)}\n',
                        style: const TextStyle(
                          color: Color(0xFF00C853),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'Expense: \$${expense.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFFFF3D00),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < dailyData.length) {
                      // Only show few labels if there are many data points (eg month)
                      if (dailyData.length > 7) {
                        if (value.toInt() % 5 != 0) return const SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          dailyData[value.toInt()]['day'],
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: dailyData.asMap().entries.map((entry) {
              return _makeGroupData(
                entry.key,
                entry.value['income'],
                entry.value['expense'],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income + expense,
          width: dailyData.length > 7 ? 8 : 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          rodStackItems: [
            BarChartRodStackItem(0, expense, const Color(0xFFFF3D00)),
            BarChartRodStackItem(
              expense,
              expense + income,
              const Color(0xFF0F9D6E),
            ),
          ],
        ),
      ],
    );
  }
}
