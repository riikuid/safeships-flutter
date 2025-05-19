import 'package:flutter/material.dart';
import 'dart:math';
import 'package:safeships_flutter/theme.dart';

class GaugeProgressChart extends StatelessWidget {
  final List<Map<String, dynamic>> progressData;

  const GaugeProgressChart({super.key, required this.progressData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progres Penilaian K3',
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: progressData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return Column(
                children: [
                  SizedBox(
                    width: 80,
                    height: 60,
                    child: CustomPaint(
                      painter: GaugePainter(
                        progress: data['progress'].toDouble(),
                        color: _getGaugeColor(index),
                      ),
                      child: Center(
                        child: Text(
                          '${data['progress'].toStringAsFixed(1)}%',
                          style: primaryTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      data['assessment'],
                      style: primaryTextStyle.copyWith(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getGaugeColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xffD5ABA8); // Warna ikon Dokumentasi K3
      case 1:
        return const Color(0xffD6BB7F); // Warna ikon Formulir Safety Patrol
      case 2:
        return const Color(0xffA4C0B6); // Warna ikon Formulir Safety Induction
    }
    return Colors.grey;
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Background gauge
    paint.color = Colors.grey.withOpacity(0.2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi,
      pi,
      false,
      paint,
    );

    // Progress gauge
    paint.color = color;
    final sweepAngle = (progress / 100) * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
