import 'package:flutter/material.dart';
import 'package:dcppwer/screens/panel_desplegable.dart';

class ModeloMatematicoScreen extends StatelessWidget {
  const ModeloMatematicoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1120),
      drawer: const PanelDesplegable(currentScreen: 'modelo'),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'MODELO MATEMÁTICO',
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
            colors: [Color(0xff0B1120), Color(0xff0F172A), Color(0xff111827)],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Ecuaciones del sistema',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'El circuito convierte temperatura en voltaje, amplifica la señal y limita la salida según la alimentación de 12 V.',
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
                  final isWide = constraints.maxWidth > 900;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _leftColumn()),
                            const SizedBox(width: 18),
                            Expanded(child: _imagePanel()),
                          ],
                        )
                      : Column(
                          children: [
                            _leftColumn(),
                            const SizedBox(height: 18),
                            _imagePanel(),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftColumn() {
    return Column(
      children: [
        _formulaCard(
          title: '1. Sensor LM35',
          subtitle: 'El sensor entrega un voltaje proporcional a la temperatura.',
          formulaLines: const [
            'V_in = 0.01 × T(°C)',
            'Ejemplo: 30 °C → 0.30 V',
          ],
        ),
        const SizedBox(height: 16),
        _formulaCard(
          title: '2. Amplificación LM324',
          subtitle: 'La ganancia depende de las resistencias del circuito.',
          formulaLines: const [
            'V_out = (1 + R1 / R2) × V_in',
            'Ganancia = 1 + R1 / R2',
          ],
        ),
        const SizedBox(height: 16),
        _formulaCard(
          title: '3. Saturación a 12 V',
          subtitle: 'La salida no puede superar la alimentación del operacional.',
          formulaLines: const [
            'V_salida = min(V_amplificada, 12 V)',
            'El LM324 satura al llegar a Vcc',
          ],
        ),
        const SizedBox(height: 16),
        _formulaCard(
          title: '4. Respuesta del motor',
          subtitle: 'El TIP41C entrega corriente para que el motor aumente su velocidad.',
          formulaLines: const [
            'V_motor ∝ V_salida',
            'Velocidad ≈ (V_motor / 12 V) × 100%',
          ],
        ),
      ],
    );
  }

  Widget _imagePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fórmula matemática del circuito',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.asset(
                  'assets/formulamatematica.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 320,
                    color: const Color(0xff111827),
                    alignment: Alignment.center,
                    child: const Text(
                      'No se encontró assets/formulamatematica.png',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formulaCard({
    required String title,
    required String subtitle,
    required List<String> formulaLines,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff0F172A), Color(0xff111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: formulaLines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'Courier New',
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff0F172A), Color(0xff111827)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
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
