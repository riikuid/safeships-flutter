import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:safeships_flutter/theme.dart';

class SafetyInductionBarChart extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const SafetyInductionBarChart({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final labels = reportData['labels'] as List<dynamic>;
    final datasets = reportData['datasets'] as List<dynamic>;
    final dataset = datasets[0]; // Ambil dataset pertama (hanya satu bar)

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
                  toY: (dataset['data'][index] as num).toDouble(),
                  color: const Color(0xff4BC0C0), // Warna untuk Total Pengajuan
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

  double _calculateMaxY(List<dynamic> datasets) {
    double maxY = 0;
    for (var dataset in datasets) {
      List<num> data = (dataset['data'] as List<dynamic>)
          .map((item) => num.parse(item.toString()))
          .toList();
      if (data.isNotEmpty) {
        maxY = max(maxY, data.reduce((a, b) => a > b ? a : b).toDouble());
      }
    }
    return maxY + (maxY * 0.2); // Tambahkan 20% untuk ruang atas
  }
}
