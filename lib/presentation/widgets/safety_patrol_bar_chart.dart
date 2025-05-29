// Widget untuk Bar Chart Laporan Safety Patrol
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:safeships_flutter/theme.dart';

class SafetyPatrolBarChart extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const SafetyPatrolBarChart({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final labels = reportData['labels'] as List<dynamic>;
    final datasets = reportData['datasets'] as List<dynamic>;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _calculateMaxY(datasets),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < labels.length) {
                    return Text(
                      labels[value.toInt()],
                      style: primaryTextStyle.copyWith(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: primaryTextStyle.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(labels.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (datasets[0]['data'][index] as num).toDouble(),
                  color:
                      const Color(0xffFF6384), // Warna untuk Unsafe Condition
                  width: labels.length > 5 ? 10 : 20,
                  borderRadius: const BorderRadius.all(Radius.zero),
                ),
                BarChartRodData(
                  toY: (datasets[1]['data'][index] as num).toDouble(),

                  color: const Color(0xff36A2EB), // Warna untuk Unsafe Action
                  width: labels.length > 5 ? 10 : 20,
                  borderRadius: const BorderRadius.all(Radius.zero),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Menghitung nilai maksimum untuk sumbu Y
  double _calculateMaxY(List<dynamic> datasets) {
    double maxY = 0;
    for (var dataset in datasets) {
      // Konversi List<dynamic> ke List<num>
      List<num> data = (dataset['data'] as List<dynamic>)
          .map((item) => num.parse(item.toString()))
          .toList();
      if (data.isNotEmpty) {
        maxY = max(maxY, data.reduce((a, b) => a > b ? a : b).toDouble());
      }
    }
    return maxY + (maxY * 0.2); // Tambahkan 20% untuk ruang atas
  }

  // Widget untuk legenda
}
