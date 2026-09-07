import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/date_format.dart';
import '../core/theme/app_theme.dart';
import '../core/unit_prefs.dart';
import '../models/vital_reading.dart';
import '../services/vitals_service.dart';
import 'vitals_screen.dart' show iconFor;

/// Readings within the last [days], or all of them when [days] is null.
///
/// Top-level and public so the filtering can be tested without building a
/// widget - it is the only real logic on this screen.
List<VitalReading> readingsWithinDays(
  List<VitalReading> readings,
  int? days, {
  DateTime? now,
}) {
  if (days == null) return List.of(readings);
  final cutoff = (now ?? DateTime.now()).subtract(Duration(days: days));
  return readings.where((r) => !r.timestamp.isBefore(cutoff)).toList();
}

class TrendsScreen extends StatefulWidget {
  /// Which vital to show first. Lets the caller open trends already
  /// focused on whatever the user was looking at.
  final VitalType? initialType;

  const TrendsScreen({super.key, this.initialType});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final _service = VitalsService();

  late VitalType _type;
  int? _rangeDays = 30;
  List<VitalReading> _all = [];
  bool _loading = true;

  static const _ranges = <String, int?>{
    '7 days': 7,
    '30 days': 30,
    'All': null,
  };

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? VitalType.bloodPressure;
    _load();
  }

  Future<void> _load() async {
    final all = await _service.loadAll();
    if (!mounted) return;
    setState(() {
      _all = all;
      _loading = false;
    });
  }

  /// Oldest first - the painter draws left to right.
  List<VitalReading> get _plotted {
    final byType = _all.where((r) => r.type == _type).toList();
    final inRange = readingsWithinDays(byType, _rangeDays);
    return inRange.reversed.toList();
  }

  int get _totalForType => _all.where((r) => r.type == _type).length;

  @override
  Widget build(BuildContext context) {
    final readings = _loading ? <VitalReading>[] : _plotted;

    return Scaffold(
      appBar: AppBar(title: const Text("Health trends")),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _buildTypeSelector(),
                  const SizedBox(height: 12),
                  _buildRangeSelector(),
                  const SizedBox(height: 18),
                  if (readings.length < 2)
                    _buildNotEnough(context)
                  else ...[
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12, 18, 16, 10),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: TrendChartPainter(
                                  readings: readings,
                                  type: _type,
                                  labelColor: AppTheme.textSecondary,
                                  gridColor: AppTheme.border,
                                  lineColor: AppTheme.primary,
                                  secondaryLineColor: AppTheme.accent,
                                ),
                              ),
                            ),
                            if (_type.hasSecondary) ...[
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: const [
                                  _LegendDot(
                                      color: AppTheme.primary,
                                      label: "Systolic"),
                                  SizedBox(width: 18),
                                  _LegendDot(
                                      color: AppTheme.accent,
                                      label: "Diastolic"),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummary(context, readings),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<VitalType>(
          value: _type,
          isExpanded: true,
          borderRadius: BorderRadius.circular(14),
          items: VitalType.values
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(iconFor(type),
                            size: 18, color: AppTheme.primaryDark),
                        const SizedBox(width: 10),
                        Text(type.label),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (type) {
            if (type != null) setState(() => _type = type);
          },
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    return Wrap(
      spacing: 8,
      children: _ranges.entries
          .map((entry) => ChoiceChip(
                label: Text(entry.key),
                selected: _rangeDays == entry.value,
                onSelected: (_) =>
                    setState(() => _rangeDays = entry.value),
              ))
          .toList(),
    );
  }

  Widget _buildNotEnough(BuildContext context) {
    final total = _totalForType;
    final rangeLimited = total >= 2 && _rangeDays != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.show_chart_rounded,
                size: 26, color: AppTheme.primary),
            const SizedBox(height: 10),
            Text(
              rangeLimited
                  ? "Nothing in this period"
                  : "Not enough readings yet",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              rangeLimited
                  ? "There are $total ${_type.label.toLowerCase()} readings "
                      "recorded, but fewer than two fall in this range. Try "
                      "a longer period."
                  : "Record at least two ${_type.label.toLowerCase()} "
                      "readings on different days to see a trend.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, List<VitalReading> readings) {
    final latest = readings.last; // oldest-first, so the last is newest
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Latest reading",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(formatReading(latest),
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(width: 5),
                Text(displayUnitFor(_type),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                Text("\u00B7  ${relativeDay(latest.timestamp)}",
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${readings.length} reading${readings.length == 1 ? '' : 's'} "
              "shown",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Draws the trend line(s).
///
/// Deliberately plain: axes, gridlines and the series, with no reference
/// bands or shading for "normal" ranges. The app records measurements
/// without interpreting them, and a chart that shaded a healthy zone would
/// quietly break that.
class TrendChartPainter extends CustomPainter {
  final List<VitalReading> readings; // oldest first
  final VitalType type;
  final Color labelColor;
  final Color gridColor;
  final Color lineColor;
  final Color secondaryLineColor;

  TrendChartPainter({
    required this.readings,
    required this.type,
    required this.labelColor,
    required this.gridColor,
    required this.lineColor,
    required this.secondaryLineColor,
  });

  static const _leftGutter = 44.0;
  static const _bottomGutter = 24.0;
  static const _topPad = 12.0;
  static const _rightPad = 10.0;
  static const _yTicks = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.length < 2) return;

    final left = _leftGutter;
    final top = _topPad;
    final right = size.width - _rightPad;
    final bottom = size.height - _bottomGutter;
    final width = right - left;
    final height = bottom - top;
    if (width <= 0 || height <= 0) return;

    // --- value range ---------------------------------------------------
    // Plot in the user's unit - a Celsius reader shouldn't see a
    // Fahrenheit axis.
    final values = <double>[];
    for (final r in readings) {
      values.add(toDisplayValue(type, r.value));
      if (type.hasSecondary && r.secondaryValue != null) {
        values.add(r.secondaryValue!);
      }
    }
    var minY = values.reduce(math.min);
    var maxY = values.reduce(math.max);
    if ((maxY - minY).abs() < 0.001) {
      // A flat series would divide by zero and draw off-canvas.
      minY -= 1;
      maxY += 1;
    } else {
      final pad = (maxY - minY) * 0.15;
      minY -= pad;
      maxY += pad;
    }

    // --- time range ------------------------------------------------------
    final startMs = readings.first.timestamp.millisecondsSinceEpoch;
    final endMs = readings.last.timestamp.millisecondsSinceEpoch;
    final spanMs = endMs - startMs;

    double xFor(DateTime when) {
      if (spanMs <= 0) return left + width / 2;
      final fraction =
          (when.millisecondsSinceEpoch - startMs) / spanMs;
      return left + fraction * width;
    }

    double yFor(double value) =>
        bottom - ((value - minY) / (maxY - minY)) * height;

    // --- gridlines and value labels --------------------------------------
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= _yTicks; i++) {
      final fraction = i / _yTicks;
      final y = bottom - fraction * height;
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);

      final value = minY + fraction * (maxY - minY);
      _text(
        canvas,
        value.toStringAsFixed(type.decimals),
        Offset(left - 6, y),
        align: _Align.right,
      );
    }

    // --- date labels ------------------------------------------------------
    final firstDate = readings.first.timestamp;
    final lastDate = readings.last.timestamp;
    _text(canvas, dayMonth(firstDate), Offset(left, bottom + 6),
        align: _Align.left, vertical: false);
    if (spanMs > 0) {
      _text(canvas, dayMonth(lastDate), Offset(right, bottom + 6),
          align: _Align.right, vertical: false);
    }

    // --- series -----------------------------------------------------------
    _drawSeries(
      canvas,
      readings
          .map((r) => (r.timestamp, toDisplayValue(type, r.value)))
          .toList(),
      lineColor,
      xFor,
      yFor,
    );

    if (type.hasSecondary) {
      final withSecondary = readings
          .where((r) => r.secondaryValue != null)
          .map((r) => (r.timestamp, r.secondaryValue!))
          .toList();
      if (withSecondary.length >= 2) {
        _drawSeries(
            canvas, withSecondary, secondaryLineColor, xFor, yFor);
      }
    }
  }

  void _drawSeries(
    Canvas canvas,
    List<(DateTime, double)> points,
    Color color,
    double Function(DateTime) xFor,
    double Function(double) yFor,
  ) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = xFor(points[i].$1);
      final y = yFor(points[i].$2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    final dotFill = Paint()..color = color;
    final dotRing = Paint()..color = Colors.white;
    for (final point in points) {
      final offset = Offset(xFor(point.$1), yFor(point.$2));
      canvas.drawCircle(offset, 4.5, dotRing);
      canvas.drawCircle(offset, 3, dotFill);
    }
  }

  void _text(Canvas canvas, String text, Offset at,
      {required _Align align, bool vertical = true}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: labelColor, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    var dx = at.dx;
    if (align == _Align.right) dx -= painter.width;
    final dy = vertical ? at.dy - painter.height / 2 : at.dy;
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant TrendChartPainter old) =>
      old.readings != readings || old.type != type;
}

enum _Align { left, right }
