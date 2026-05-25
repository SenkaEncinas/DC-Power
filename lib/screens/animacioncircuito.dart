import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:dcppwer/screens/panel_desplegable.dart';

class AnimacionCircuitoScreen extends StatefulWidget {
  const AnimacionCircuitoScreen({super.key});

  @override
  State<AnimacionCircuitoScreen> createState() =>
      _AnimacionCircuitoScreenState();
}

class _AnimacionCircuitoScreenState
    extends State<AnimacionCircuitoScreen> {
  static const Offset sensorPos = Offset(0.28, 0.30);

  static const double minTemp = 24;
  static const double maxTemp = 84;

  double lighterX = 0.72;
  double lighterY = 0.80;

  double temperature = 24;

  double fanAngle = 0;
  double fanVelocity = 0;

  double flameAnimation = 0;

  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final target = _targetTemperature();

      // =========================
      // INERCIA TÉRMICA
      // =========================

      final thermalResponse =
          target > temperature ? 0.018 : 0.008;

      temperature +=
          (target - temperature) * thermalResponse;

      // =========================
      // VELOCIDAD VENTILADOR
      // =========================

      final targetSpeed = fanSpeed * 0.55;

      fanVelocity +=
          (targetSpeed - fanVelocity) * 0.05;

      // fricción
      fanVelocity *= 0.992;

      fanAngle += fanVelocity;

      // =========================
      // ANIMACIÓN LLAMA
      // =========================

      flameAnimation += 0.12;

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

  double get fanSpeed {
    final normalized =
        ((temperature - minTemp) / (maxTemp - minTemp))
            .clamp(0.0, 1.0);

    return pow(normalized, 1.7).toDouble();
  }

  double _targetTemperature() {
    final flamePos = Offset(lighterX, lighterY);

    final dist = (sensorPos - flamePos).distance;

    final heat =
        (1.0 - (dist / 0.55)).clamp(0.0, 1.0);

    return minTemp + heat * (maxTemp - minTemp);
  }

  void _moveFlame(Offset localPos, Size size) {
    setState(() {
      lighterX =
          (localPos.dx / size.width).clamp(0.08, 0.92);

      lighterY =
          (localPos.dy / size.height).clamp(0.54, 0.92);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1120),
      drawer: const PanelDesplegable(
        currentScreen: 'animacion',
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'ANIMACIÓN DEL CIRCUITO',
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
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
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: cardDecoration(),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Control visual del sensor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Acerca el encendedor al sensor para aumentar la temperatura. El ventilador acelera progresivamente y se detiene lentamente gracias a la simulación de inercia.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final height =
                      constraints.maxWidth > 900
                          ? 560.0
                          : 620.0;

                  final size =
                      Size(constraints.maxWidth, height);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (details) =>
                        _moveFlame(
                          details.localPosition,
                          size,
                        ),
                    onPanUpdate: (details) =>
                        _moveFlame(
                          details.localPosition,
                          size,
                        ),
                    child: SizedBox(
                      width: double.infinity,
                      height: height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: cardDecoration(),
                            ),
                          ),
                          Positioned(
                            left: size.width * 0.08,
                            top: size.height * 0.10,
                            child: _infoCard(
                              'Sensor',
                              'LM35',
                              Icons.thermostat_rounded,
                              Colors.orangeAccent,
                            ),
                          ),
                          Positioned(
                            right: size.width * 0.08,
                            top: size.height * 0.10,
                            child: _infoCard(
                              'Ventilador',
                              '${(fanSpeed * 100).toStringAsFixed(0)}%',
                              Icons.toys_rounded,
                              Colors.greenAccent,
                            ),
                          ),
                          Positioned(
                            left:
                                size.width * sensorPos.dx -
                                58,
                            top:
                                size.height * sensorPos.dy -
                                58,
                            child: _sensorWidget(),
                          ),
                          Positioned(
                            left: size.width * 0.70,
                            top: size.height * 0.30,
                            child: RepaintBoundary(
                              child: _fanWidget(),
                            ),
                          ),
                          Positioned(
                            left:
                                size.width * lighterX - 26,
                            top:
                                size.height * lighterY - 26,
                            child: _flameWidget(),
                          ),
                          Positioned(
                            left: size.width * 0.20,
                            top: size.height * 0.18,
                            child: _pipeLine(
                              size.width * 0.48,
                              temperature,
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            child: _bottomPanel(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sensorWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orangeAccent.withOpacity(0.08),
            border: Border.all(
              color: Colors.orangeAccent.withOpacity(0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.25),
                blurRadius: 22,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xff111827),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thermostat_rounded,
                color: Colors.orangeAccent,
                size: 34,
              ),
              SizedBox(height: 4),
              Text(
                'LM35',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fanWidget() {
    final speed = fanSpeed;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.12),
                  width: 2,
                ),
              ),
            ),
            Transform.rotate(
              angle: fanAngle,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _blade(angle: 0),
                  _blade(angle: (2 * pi) / 3),
                  _blade(angle: (4 * pi) / 3),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent
                              .withOpacity(0.5),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (speed > 0.08)
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.greenAccent
                        .withOpacity(speed * 0.25),
                    width: 8,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            'Velocidad ${(speed * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _blade({required double angle}) {
    return Transform.rotate(
      angle: angle,
      child: Transform.translate(
        offset: const Offset(0, -18),
        child: Container(
          width: 24,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.greenAccent.withOpacity(0.95),
                Colors.greenAccent.withOpacity(0.35),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flameWidget() {
    final heat =
        ((temperature - minTemp) / (maxTemp - minTemp))
            .clamp(0.0, 1.0);

    final pulse = sin(flameAnimation * 3) * 4;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 70 + pulse,
              height: 70 + pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orangeAccent.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent
                        .withOpacity(0.45),
                    blurRadius: 30 + pulse,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 1 + (pulse * 0.01),
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 58 + (heat * 18),
                color: Color.lerp(
                  Colors.orangeAccent,
                  Colors.redAccent,
                  heat,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Encendedor',
          style: TextStyle(
            color: Colors.orangeAccent.withOpacity(0.95),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _pipeLine(double width, double temp) {
    final heat =
        ((temp - minTemp) / (maxTemp - minTemp))
            .clamp(0.0, 1.0);

    return Stack(
      children: [
        Container(
          width: width,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white12),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width * heat,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Colors.greenAccent.withOpacity(0.4),
                Colors.orangeAccent.withOpacity(0.7),
                Colors.redAccent.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.4),
                blurRadius: 18,
              ),
            ],
          ),
        ),
        SizedBox(
          width: width,
          height: 54,
          child: Center(
            child: Text(
              'Temperatura: ${temp.toStringAsFixed(1)} °C',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomPanel() {
    final heat =
        ((temperature - minTemp) / (maxTemp - minTemp))
            .clamp(0.0, 1.0);

    final blower =
        (fanSpeed * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statTile(
              'Temperatura',
              '${temperature.toStringAsFixed(1)} °C',
              Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statTile(
              'Ventilador',
              '$blower %',
              Colors.greenAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statTile(
              'Calor',
              '${(heat * 100).toStringAsFixed(0)} %',
              Colors.cyanAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xff0F172A),
          Color(0xff111827),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.40),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
