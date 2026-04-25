import 'package:expenseflow/screens/home_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeScreenChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailySummary;
  final double maxGraphY;
  const HomeScreenChart({
    super.key,
    required this.dailySummary,
    required this.maxGraphY,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Spending Overview', style: TextStyle(fontSize: 22)),
                    Spacer(),
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.green,
                      size: 25,
                    ),
                  ],
                ),
                SizedBox(
                  height: 200,
                  child: dailySummary.isEmpty
                      ? Center(child: Text('No data for this week'))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxGraphY,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) =>
                                    Colors.blueGrey.withOpacity(0.8),
                                tooltipBorderRadius: BorderRadius.circular(8),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final day = dailySummary[groupIndex]['day'];
                                  final income =
                                      dailySummary[groupIndex]['income'];
                                  final expense =
                                      dailySummary[groupIndex]['expense'];
                                  return BarTooltipItem(
                                    '$day\n',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            'Income: \$${income.toStringAsFixed(0)}\n',
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            'Expense: \$${expense.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < dailySummary.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          dailySummary[value.toInt()]['day'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            barGroups: dailySummary.asMap().entries.map((
                              entry,
                            ) {
                              return makeBar(
                                entry.key,
                                entry.value['income'],
                                entry.value['expense'],
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
