import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dcppwer/screens/folletoscreen.dart';
import 'package:dcppwer/screens/informescreen.dart';
import 'package:dcppwer/screens/panel_desplegable.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with SingleTickerProviderStateMixin {
  double r1 = 100000;
  double r2 = 20000;
  double temperatura = 30;

  late AnimationController controller;
  late final TextEditingController r1Controller;
  late final TextEditingController r2Controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    r1Controller = TextEditingController(text: r1.toStringAsFixed(0));
    r2Controller = TextEditingController(text: r2.toStringAsFixed(0));
  }

  void _setR1FromText(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    final clamped = parsed.clamp(1000, 100000);
    setState(() {
      r1 = clamped.toDouble();
      r1Controller.text = r1.toStringAsFixed(0);
      r1Controller.selection = TextSelection.collapsed(offset: r1Controller.text.length);
    });
  }

  void _setR2FromText(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    final clamped = parsed.clamp(1000, 100000);
    setState(() {
      r2 = clamped.toDouble();
      r2Controller.text = r2.toStringAsFixed(0);
      r2Controller.selection = TextSelection.collapsed(offset: r2Controller.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// =========================
    /// MODELO MATEMATICO
    /// =========================

    final double vin = temperatura * 0.01;
    double ganancia = 1 + (r1 / r2);

    final double rawVout = vin * ganancia;
    final bool saturated = rawVout > 12;

    final double vout = rawVout > 12 ? 12 : rawVout;

    double velocidad = (vout / 12) * 100;

    final List<double> chartData = List.generate(24, (i) {
      final t = i / 23;
      final wave = sin((t * pi * 2) + (temperatura / 20));
      final base = (velocidad / 100) * 0.6;
      final fluct = ((wave + 1) / 2) * 0.4;
      return (base + fluct).clamp(0.0, 1.0);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const PanelDesplegable(currentScreen: 'control'),
      appBar: AppBar(

        backgroundColor: Colors.black,

        title: Text(
          "SIMULADOR DE CONTROL",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(
            icon: Icon(Icons.menu_book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FolletoScreen()),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.description),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InformeScreen()),
              );
            },
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
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

          padding: EdgeInsets.all(12), // antes 20

          child: Column(

            children: [

              /// =========================================
              /// PANEL RESUMEN + GRAFICO
              /// =========================================

              sectionTitle("Panel de Control"),

              Container(

                width: double.infinity,

                padding: EdgeInsets.all(12), // antes 20

                decoration: cardDecoration(),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Resumen en tiempo real",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16, // antes 20
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 12),

                    Wrap(

                      spacing: 12,
                      runSpacing: 12,

                      children: [

                        buildStatCard(
                          "Vin",
                          "${vin.toStringAsFixed(2)} V",
                          Icons.input,
                          Colors.cyan,
                        ),

                        buildStatCard(
                          "Vout",
                          "${vout.toStringAsFixed(2)} V",
                          Icons.output,
                          Colors.greenAccent,
                        ),

                        buildStatCard(
                          "Ganancia",
                          "${ganancia.toStringAsFixed(2)}",
                          Icons.equalizer,
                          Colors.orange,
                        ),

                        buildStatCard(
                          "Velocidad",
                          "${velocidad.toStringAsFixed(0)} %",
                          Icons.speed,
                          Colors.white,
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    //motor
                    
                  ],
                ),
              ),

              /// =========================================
              /// CIRCUITO + MODELO MATEMATICO
              /// =========================================

              Row(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  /// =====================================
                  /// CIRCUITO INTERACTIVO
                  /// =====================================

                  Expanded(

                    flex: 1,

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        sectionTitle("Circuito Interactivo"),

                        buildCircuit(
                          vin,
                          vout,
                          velocidad,
                          ganancia,
                        ),

                        SizedBox(height: 16),

                        sectionTitle("Velocidad del Motor"),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: cardDecoration(),
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: controller,
                                builder: (_, child) {
                                  return Transform.rotate(
                                    angle: controller.value * velocidad / 8,
                                    child: Icon(
                                      saturated
                                          ? Icons.warning_amber_rounded
                                          : Icons.toys,
                                      size: 96,
                                      color: saturated
                                          ? Colors.orangeAccent
                                          : Colors.greenAccent,
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 12),

                              if (saturated)
                                Text(
                                  "LM324 saturado: salida limitada a 12V",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              SizedBox(height: 12),

                              Text(
                                "${velocidad.toStringAsFixed(0)} %",
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 12),

                              LinearProgressIndicator(
                                value: velocidad / 100,
                                color: Colors.greenAccent,
                                backgroundColor: Colors.white10,
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12), // antes 20

                  /// =====================================
                  /// MODELO MATEMATICO
                  /// =====================================

                  Expanded(

                    flex: 1,

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        sectionTitle("Modelo Matemático"),

                        Container(

                          width: double.infinity,

                          padding: EdgeInsets.all(12), // antes 25

                          decoration: cardDecoration(),

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(
                                "Amplificador No Inversor",
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 18, // antes 22
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 12), // antes 25

                              Center(

                                child: Text(

                                  "Vout = (1 + R1/R2) × Vin",

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 18, // antes 24
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),

                              infoText(
                                "Vin = ${vin.toStringAsFixed(2)} V",
                              ),

                              infoText(
                                "Ganancia = ${ganancia.toStringAsFixed(2)}",
                              ),

                              infoText(
                                "Vout = ${vout.toStringAsFixed(2)} V",
                              ),

                              SizedBox(height: 12),

                              Divider(color: Colors.white24),

                              SizedBox(height: 12),

                              Text(
                                "Función Transferencia",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16, // antes 20
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 10),

                              Center(

                                child: Text(

                                  "G(s)=K/(τs+1)",

                                  style: TextStyle(
                                    fontSize: 20, // antes 28
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),

                              infoText(
                                "K = ${ganancia.toStringAsFixed(2)}",
                              ),

                              infoText(
                                "τ = 0.5",
                              ),

                              SizedBox(height: 10),

                              LinearProgressIndicator(
                                value: velocidad / 100,
                                color: Colors.greenAccent,
                                backgroundColor: Colors.white10,
                                minHeight: 6, // antes 10
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16), // antes 30

              /// =========================================
              /// CONTROL GANANCIA
              /// =========================================

              sectionTitle("Control de Ganancia"),

              Container(

                width: double.infinity,

                padding: EdgeInsets.all(12), // antes 25

                decoration: cardDecoration(),

                child: Column(

                  children: [

                    Text(
                      "Ajuste de resistencias y temperatura",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "R1",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
                                ),
                                child: Slider(
                                  min: 1000,
                                  max: 100000,
                                  value: r1,
                                  activeColor: Colors.greenAccent,
                                  onChanged: (value) {
                                    setState(() {
                                      r1 = value;
                                      r1Controller.text = r1.toStringAsFixed(0);
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 4),
                              SizedBox(
                                height: 36,
                                child: TextField(
                                  controller: r1Controller,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    hintText: "R1",
                                    hintStyle: TextStyle(color: Colors.white38),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.white12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.greenAccent),
                                    ),
                                  ),
                                  onSubmitted: _setR1FromText,
                                ),
                              ),
                              Text(
                                "${r1.toStringAsFixed(0)} Ω",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "R2",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
                                ),
                                child: Slider(
                                  min: 1000,
                                  max: 100000,
                                  value: r2,
                                  activeColor: Colors.cyan,
                                  onChanged: (value) {
                                    setState(() {
                                      r2 = value;
                                      r2Controller.text = r2.toStringAsFixed(0);
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 4),
                              SizedBox(
                                height: 36,
                                child: TextField(
                                  controller: r2Controller,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    hintText: "R2",
                                    hintStyle: TextStyle(color: Colors.white38),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.white12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.cyan),
                                    ),
                                  ),
                                  onSubmitted: _setR2FromText,
                                ),
                              ),
                              Text(
                                "${r2.toStringAsFixed(0)} Ω",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "Temp",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: 100,
                                  value: temperatura,
                                  activeColor: Colors.orange,
                                  onChanged: (value) {
                                    setState(() {
                                      temperatura = value;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                "${temperatura.toStringAsFixed(1)} °C",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              /// =========================================
              /// MOTOR
              /// =========================================

              

              SizedBox(height: 36), // antes 50
            ],
          ),
        ),
      ),
    );
  }

  /// ====================================
  /// CIRCUITO INTERACTIVO
  /// ====================================

  Widget buildCircuit(
    double vin,
    double vout,
    double velocidad,
    double ganancia,
  ) {

    return Container(
      width: double.infinity,
      height: 220,
      padding: EdgeInsets.all(12),
      decoration: cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          componentBox(
            "LM35",
            "${vin.toStringAsFixed(2)}V",
            Icons.thermostat,
            Colors.orange,
          ),
          
          animatedSignalLine(Colors.cyan, 1.0), // Flujo normal de V_in

          componentBox(
            "LM324",
            "G=${ganancia.toStringAsFixed(1)}",
            Icons.memory,
            Colors.cyan,
          ),

          animatedSignalLine(Colors.greenAccent, ganancia / 3), // Flujo amplificado

          componentBox(
            "TIP41C",
            "${vout.toStringAsFixed(2)}V",
            Icons.bolt,
            Colors.greenAccent,
          ),

          animatedSignalLine(Colors.white, velocidad / 50), // Flujo final al motor

          componentBox(
            "MOTOR",
            "${velocidad.toStringAsFixed(0)}%",
            Icons.toys,
            velocidad == 0 ? Colors.redAccent : Colors.white,
          ),
        ],
      ),
    );
  }
  

  /// ====================================
  /// COMPONENT BOX
  /// ====================================

  Widget componentBox(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.18),
                color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 34,
            color: color,
          ),
        ),

        SizedBox(height: 10),

        Text(

          title,

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),

        SizedBox(height: 4),

        Text(

          value,

          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// ====================================
  /// SIGNAL LINE (ANIMADA)
  /// ====================================

  Widget animatedSignalLine(Color color, double speedMultiplier) {
    return Expanded(
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _FlowPainter(controller.value, color, speedMultiplier),
            child: Container(height: 16),
          );
        },
      ),
    );
  }

  /// ====================================
  /// SECTION TITLE
  /// ====================================

  Widget sectionTitle(String title) {

    return Padding(

      padding: EdgeInsets.only(bottom: 8), // antes 15

      child: Align(

        alignment: Alignment.centerLeft,

        child: Text(

          title,

          style: TextStyle(
            fontSize: 20, // antes 30
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// ====================================
  /// INFO TEXT
  /// ====================================

  Widget infoText(String text) {

    return Padding(

      padding: EdgeInsets.only(bottom: 6), // antes 10

      child: Text(

        text,

        style: TextStyle(
          fontSize: 14, // antes 20
          color: Colors.white,
        ),
      ),
    );
  }

  /// ====================================
  /// CARD DECORATION
  /// ====================================

  BoxDecoration cardDecoration() {

    return BoxDecoration(

      gradient: LinearGradient(
        colors: [
          Color(0xff0F172A),
          Color(0xff111827),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),

      borderRadius: BorderRadius.circular(18), // antes 25

      border: Border.all(color: Colors.white12), // un poco más definido

      boxShadow: [

        BoxShadow(
          color: Colors.black.withOpacity(0.4), // más suave
          blurRadius: 14, // antes 18
          offset: Offset(0, 8), // antes 10
        ),
      ],
    );
  }

  /// ====================================
  /// STAT CARD
  /// ====================================

  Widget buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {

    return Container(

      width: 170, // antes 220

      padding: EdgeInsets.all(10), // antes 16

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white10,
            Colors.white12,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),

      child: Row(

        children: [

          Container(
            width: 32, // antes 42
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8), // antes 12
            ),
            child: Icon(icon, color: color, size: 18),
          ),

          SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10, // antes 12
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14, // antes 18
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

  @override
  void dispose() {
    r1Controller.dispose();
    r2Controller.dispose();
    controller.dispose();
    super.dispose();
  }
}

/// ====================================
/// ANIMATED FLOW PAINTER
/// ====================================

class _FlowPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double speed;

  _FlowPainter(this.progress, this.color, this.speed);

  @override
  void paint(Canvas canvas, Size size) {
    // Línea base oscura
    final paintBase = Paint()
      ..color = Colors.white10
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paintBase);

    if (speed <= 0) return;

    // Pintor de electrones/flujo
    final dashPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    double dashWidth = 8;
    double dashSpace = 8;
    double totalDash = dashWidth + dashSpace;

    // Calcula el movimiento (velocidad base adaptada por el speedMultiplier)
    double shift = (progress * totalDash * 8 * speed) % totalDash;

    double startX = -totalDash + shift;
    while (startX < size.width) {
      double endX = startX + dashWidth;
      if (endX > 0 && startX < size.width) {
        canvas.drawLine(
          Offset(max(0, startX), y),
          Offset(min(size.width, endX), y),
          dashPaint,
        );
      }
      startX += totalDash;
    }
  }

  @override
  bool shouldRepaint(covariant _FlowPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.speed != speed;
  }
}

/// ====================================
/// LINE CHART PAINTER
/// ====================================

  class _LineChartPainter extends CustomPainter {

  _LineChartPainter(this.data);

  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {

    final paintLine = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintGrid = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}