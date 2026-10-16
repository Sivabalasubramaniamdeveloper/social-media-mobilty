import 'package:flutter/material.dart';

class MoodChartWidget extends StatelessWidget {
  final List<double> scores; // 7 points for week, or up to 30 for month
  final List<String> labels;

  const MoodChartWidget({
    super.key,
    required this.scores,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161426),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(painter: _MoodGraphPainter(scores: scores)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (lbl) => Text(
                    lbl,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MoodGraphPainter extends CustomPainter {
  final List<double> scores; // Scores scaled 1.0 to 5.0
  _MoodGraphPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    final step = size.width / (scores.length - 1 > 0 ? scores.length - 1 : 1);

    for (int i = 0; i < scores.length; i++) {
      final normY = ((scores[i] - 1) / 4.0).clamp(0.0, 1.0);
      final y =
          size.height - (normY * (size.height * 0.75) + size.height * 0.12);
      points.add(Offset(step * i, y));
    }

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Gradient fill under mood curve
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFA78BFA).withOpacity(0.35),
          const Color(0xFFA78BFA).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFA78BFA)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    // Glowing marker on the latest entry
    final lastPoint = points.last;
    canvas.drawCircle(
      lastPoint,
      7,
      Paint()..color = const Color(0xFF8B5CF6).withOpacity(0.4),
    );
    canvas.drawCircle(lastPoint, 4, Paint()..color = const Color(0xFFA78BFA));
  }

  @override
  bool shouldRepaint(covariant _MoodGraphPainter oldDelegate) => true;
}
