import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dcppwer/screens/panel_desplegable.dart';

class SimuladorModeloScreen extends StatefulWidget {
  const SimuladorModeloScreen({super.key});

  @override
  State<SimuladorModeloScreen> createState() => _SimuladorModeloScreenState();
}

class _SimuladorModeloScreenState extends State<SimuladorModeloScreen> {
  // =========================
  // ALIMENTACIÓN DEL CIRCUITO
  // =========================
  static const double supplyVoltage = 12.0;

  // =========================
  // DATOS DEL CIRCUITO REAL
  // =========================
  double temperatureC = 27.0;

  double r1K = 100.0; // R1 = 100k
  double r2K = 20.0; // R2 = 20k
  double r3K = 1.0; // R3 = 1k

  // Modelo equivalente del motor
  double tauSeconds = 2.4;

  // Parámetros aproximados para el modelo del TIP41 + motor
  static const double ledDrop = 2.0;
  static const double vbe = 0.7;
  static const double transistorBeta = 25.0;
  static const double motorResistance = 48.0;

  double fanResponsePercent = 0.0;
  double modelTime = 0.0;

  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      const dt = 0.04;

      final alpha = (dt / tauSeconds).clamp(0.01, 0.20).toDouble();

      fanResponsePercent += (targetFanPercent - fanResponsePercent) * alpha;

      modelTime += dt;

      if (modelTime > 20) {
        modelTime = 0;
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // =========================
  // MODELO ELÉCTRICO
  // =========================

  double get lm35Voltage {
    // LM35 = 10 mV por °C
    return temperatureC * 0.01;
  }

  double get opAmpGain {
    // Amplificador no inversor: Av = 1 + R1/R2
    return 1 + (r1K / r2K);
  }

  double get opAmpOutputVoltage {
    final output = lm35Voltage * opAmpGain;
    return output.clamp(0.0, supplyVoltage).toDouble();
  }

  double get rawOpAmpOutputVoltage {
    return lm35Voltage * opAmpGain;
  }

  bool get isSaturated {
    return rawOpAmpOutputVoltage > supplyVoltage;
  }

  double get baseCurrentMA {
    final availableVoltage = opAmpOutputVoltage - ledDrop - vbe;

    if (availableVoltage <= 0) {
      return 0;
    }

    final currentA = availableVoltage / (r3K * 1000);
    return currentA * 1000;
  }

  double get collectorCurrentA {
    return (baseCurrentMA / 1000) * transistorBeta;
  }

  double get motorDemandCurrentA {
    return supplyVoltage / motorResistance;
  }

  double get targetFanPercent {
    final drive = collectorCurrentA / motorDemandCurrentA;
    return drive.clamp(0.0, 1.0).toDouble() * 100;
  }

  double get motorVoltageEquivalent {
    return supplyVoltage * (fanResponsePercent / 100);
  }

  double get thresholdTemperature {
    final requiredVoltage = ledDrop + vbe;

    if (opAmpGain <= 0) {
      return 0;
    }

    return requiredVoltage / (opAmpGain * 0.01);
  }

  double get kcEquivalent {
    // Ganancia equivalente simplificada del sistema eléctrico.
    return opAmpGain * 4.33;
  }

  void _resetModel() {
    setState(() {
      fanResponsePercent = 0;
      modelTime = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const PanelDesplegable(
        currentScreen: 'modelo',
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'SIMULADOR DE MODELO',
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            color: Colors.white,
            onPressed: _resetModel,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff0B1120),
              Color(0xff0F172A),
              Color(0xff111827),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 950;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 42,
                      child: _controlPanel(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 58,
                      child: _responsePanel(),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _controlPanel(),
                  const SizedBox(height: 16),
                  _responsePanel(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================
  // PANEL IZQUIERDO
  // =========================

  Widget _controlPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _mainCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulador de modelo equivalente Kc - τ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Este modo representa el comportamiento del circuito con LM35, amplificador operacional LM324, LED, transistor TIP41 y motor DC. Todo el sistema se considera energizado con 12 V.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),

          _powerBox(),

          const SizedBox(height: 18),

          _sliderTile(
            title: 'Temperatura aplicada al LM35',
            valueText: '${temperatureC.toStringAsFixed(1)} °C',
            value: temperatureC,
            min: 0,
            max: 120,
            divisions: 120,
            color: Colors.orange,
            onChanged: (value) {
              setState(() {
                temperatureC = value;
              });
            },
          ),

          const SizedBox(height: 14),

          _sliderTile(
            title: 'R1 realimentación',
            valueText: '${r1K.toStringAsFixed(0)} kΩ',
            value: r1K,
            min: 10,
            max: 220,
            divisions: 210,
            color: Colors.greenAccent,
            onChanged: (value) {
              setState(() {
                r1K = value;
              });
            },
          ),

          const SizedBox(height: 14),

          _sliderTile(
            title: 'R2 divisor a tierra',
            valueText: '${r2K.toStringAsFixed(0)} kΩ',
            value: r2K,
            min: 5,
            max: 80,
            divisions: 75,
            color: Colors.cyan,
            onChanged: (value) {
              setState(() {
                r2K = value;
              });
            },
          ),

          const SizedBox(height: 14),

          _sliderTile(
            title: 'τ modelo del motor',
            valueText: '${tauSeconds.toStringAsFixed(1)} s',
            value: tauSeconds,
            min: 0.5,
            max: 8.0,
            divisions: 75,
            color: Colors.orangeAccent,
            onChanged: (value) {
              setState(() {
                tauSeconds = value;
              });
            },
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetModel,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text(
                'Reiniciar respuesta del modelo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _powerBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.orange.withOpacity(0.5),
              ),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alimentación general del circuito',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'LM35, LM324 y motor trabajan sobre una referencia de 12 V.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '12 V',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderTile({
    required String title,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                valueText,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white12,
              thumbColor: color,
              overlayColor: color.withOpacity(0.18),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 5,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 8,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // PANEL DERECHO
  // =========================

  Widget _responsePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _mainCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Respuesta del modelo del circuito',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 360,
            child: CustomPaint(
              painter: _ModelChartPainter(
                targetPercent: targetFanPercent,
                responsePercent: fanResponsePercent,
                tau: tauSeconds,
                time: modelTime,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            _modelExplanation(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _dataGrid(),

          const SizedBox(height: 20),

          _circuitEquationBox(),
        ],
      ),
    );
  }

  String _modelExplanation() {
    return 'A mayor Kc, mayor acción efectiva sobre el motor. '
        'A mayor τ, la respuesta del ventilador es más lenta. '
        'El motor empieza a activarse cuando la salida del LM324 supera aproximadamente '
        '${(ledDrop + vbe).toStringAsFixed(1)} V en la etapa LED + base del TIP41.';
  }

  Widget _dataGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;

        final children = [
          _dataCard(
            title: 'V LM35',
            value: '${lm35Voltage.toStringAsFixed(3)} V',
            icon: Icons.thermostat_rounded,
            color: Colors.orange,
          ),
          _dataCard(
            title: 'Ganancia LM324',
            value: opAmpGain.toStringAsFixed(2),
            icon: Icons.call_made_rounded,
            color: Colors.cyan,
          ),
          _dataCard(
            title: 'Salida LM324',
            value: '${opAmpOutputVoltage.toStringAsFixed(2)} V',
            icon: Icons.offline_bolt_rounded,
            color: Colors.greenAccent,
          ),
          _dataCard(
            title: 'I base TIP41',
            value: '${baseCurrentMA.toStringAsFixed(2)} mA',
            icon: Icons.electrical_services_rounded,
            color: Colors.orangeAccent,
          ),
          _dataCard(
            title: 'Motor equivalente',
            value: '${motorVoltageEquivalent.toStringAsFixed(2)} V',
            icon: Icons.toys_rounded,
            color: Colors.greenAccent,
          ),
          _dataCard(
            title: 'Umbral aprox.',
            value: '${thresholdTemperature.toStringAsFixed(1)} °C',
            icon: Icons.device_thermostat_rounded,
            color: Colors.orange,
          ),
          _dataCard(
            title: 'Kc equivalente',
            value: kcEquivalent.toStringAsFixed(2),
            icon: Icons.functions_rounded,
            color: Colors.cyanAccent,
          ),
          _dataCard(
            title: 'Velocidad',
            value: '${fanResponsePercent.toStringAsFixed(0)} %',
            icon: Icons.speed_rounded,
            color: Colors.white,
          ),
        ];

        if (isWide) {
          return GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: children,
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.55,
          children: children,
        );
      },
    );
  }

  Widget _dataCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circuitEquationBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Modelo usado en la pantalla',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _equationLine(
            'LM35:',
            'Vsensor = Temperatura × 0.01 V',
          ),
          _equationLine(
            'LM324:',
            'Vout = Vsensor × (1 + R1/R2), limitado a 12 V',
          ),
          _equationLine(
            'TIP41:',
            'Ib ≈ (Vout - VLED - VBE) / R3',
          ),
          _equationLine(
            'Motor:',
            'Respuesta(t) = Final × (1 - e^(-t/τ))',
          ),
          const SizedBox(height: 8),
          Text(
            isSaturated
                ? 'Advertencia: el LM324 está saturado, por eso la salida se limita a 12 V.'
                : 'El LM324 está trabajando dentro del rango de alimentación.',
            style: TextStyle(
              color: isSaturated ? Colors.orangeAccent : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _equationLine(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(
              text: text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _mainCardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xff0F172A),
          Color(0xff111827),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

// =========================
// GRÁFICA DEL MODELO
// =========================

class _ModelChartPainter extends CustomPainter {
  final double targetPercent;
  final double responsePercent;
  final double tau;
  final double time;

  _ModelChartPainter({
    required this.targetPercent,
    required this.responsePercent,
    required this.tau,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 52;
    const double right = 20;
    const double top = 18;
    const double bottom = 42;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.4;

    final areaPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.10)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final targetPaint = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.75)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final chartRect = Rect.fromLTWH(
      left,
      top,
      chartWidth,
      chartHeight,
    );

    final bgPaint = Paint()
      ..color = const Color(0xff0F172A)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        chartRect,
        const Radius.circular(14),
      ),
      bgPaint,
    );

    // Grilla horizontal y labels de porcentaje
    for (int i = 0; i <= 5; i++) {
      final percent = i * 20;
      final y = top + chartHeight - (chartHeight * percent / 100);

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );

      _drawText(
        canvas,
        '${percent.toString()}%',
        Offset(8, y - 8),
        fontSize: 11,
        color: Colors.white70,
        weight: FontWeight.w700,
      );
    }

    // Grilla vertical y labels de tiempo
    const maxTime = 20.0;

    for (int i = 0; i <= 10; i++) {
      final t = i * 2;
      final x = left + chartWidth * (t / maxTime);

      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + chartHeight),
        gridPaint,
      );

      _drawText(
        canvas,
        '${t.toString()}s',
        Offset(x - 10, top + chartHeight + 12),
        fontSize: 11,
        color: Colors.white70,
        weight: FontWeight.w700,
      );
    }

    // Ejes
    canvas.drawLine(
      Offset(left, top + chartHeight),
      Offset(size.width - right, top + chartHeight),
      axisPaint,
    );

    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + chartHeight),
      axisPaint,
    );

    // Línea objetivo
    final targetY = top + chartHeight - (chartHeight * targetPercent / 100);

    canvas.drawLine(
      Offset(left, targetY),
      Offset(size.width - right, targetY),
      targetPaint,
    );

    _drawText(
      canvas,
      'Objetivo ${targetPercent.toStringAsFixed(0)}%',
      Offset(size.width - right - 125, targetY - 22),
      fontSize: 12,
      color: Colors.orangeAccent,
      weight: FontWeight.w900,
    );

    // Curva de respuesta
    final responsePath = Path();
    final areaPath = Path();

    final points = <Offset>[];

    for (int i = 0; i <= 140; i++) {
      final t = maxTime * i / 140;
      final yValue = targetPercent * (1 - exp(-t / tau));

      final x = left + chartWidth * (t / maxTime);
      final y = top + chartHeight - (chartHeight * yValue / 100);

      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      responsePath.moveTo(points.first.dx, points.first.dy);

      areaPath.moveTo(left, top + chartHeight);
      areaPath.lineTo(points.first.dx, points.first.dy);

      for (final point in points) {
        responsePath.lineTo(point.dx, point.dy);
        areaPath.lineTo(point.dx, point.dy);
      }

      areaPath.lineTo(size.width - right, top + chartHeight);
      areaPath.close();

      canvas.drawPath(areaPath, areaPaint);
      canvas.drawPath(responsePath, linePaint);
    }

    // Marcador de tiempo actual
    final currentTime = time.clamp(0.0, maxTime).toDouble();
    final currentModelValue = targetPercent * (1 - exp(-currentTime / tau));

    final markerX = left + chartWidth * (currentTime / maxTime);
    final markerY =
        top + chartHeight - (chartHeight * currentModelValue / 100);

    canvas.drawCircle(
      Offset(markerX, markerY),
      5,
      markerPaint,
    );

    _drawText(
      canvas,
      'Respuesta actual ${responsePercent.toStringAsFixed(0)}%',
      Offset(left + 8, top + 10),
      fontSize: 13,
      color: Colors.white,
      weight: FontWeight.w900,
    );

    _drawText(
      canvas,
      'Tiempo (s)',
      Offset(left + chartWidth / 2 - 35, size.height - 18),
      fontSize: 12,
      color: Colors.white,
      weight: FontWeight.w900,
    );

    canvas.save();
    canvas.translate(14, top + chartHeight / 2 + 42);
    canvas.rotate(-pi / 2);

    _drawText(
      canvas,
      'Activación del motor',
      Offset.zero,
      fontSize: 12,
      color: Colors.white,
      weight: FontWeight.w900,
    );

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double fontSize,
    required Color color,
    required FontWeight weight,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ModelChartPainter oldDelegate) {
    return oldDelegate.targetPercent != targetPercent ||
        oldDelegate.responsePercent != responsePercent ||
        oldDelegate.tau != tau ||
        oldDelegate.time != time;
  }
}