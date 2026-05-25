import 'package:flutter/material.dart';
import 'package:dcppwer/screens/panel_desplegable.dart';

class EtapasSistemaScreen extends StatelessWidget {
  const EtapasSistemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stages = [
      {
        'title': 'LM35 - Sensado',
        'desc': 'El LM35 transforma la temperatura en un voltaje analógico proporcional.',
        'formula': 'V_in = 0.01 × T(°C)\nEjemplo: 30 °C → 0.30 V',
      },
      {
        'title': 'LM324 - Ganancia',
        'desc': 'El operacional amplifica la señal del LM35 usando las resistencias del circuito.',
        'formula': 'V_out = (1 + R1 / R2) × V_in\nLa ganancia depende de R1 y R2',
      },
      {
        'title': 'LM324 - Saturación',
        'desc': 'La salida del operacional no puede superar la fuente de 12 V.',
        'formula': 'V_salida = min(V_amplificada, 12 V)\nEl LM324 satura al llegar a Vcc',
      },
      {
        'title': 'TIP41C + Motor',
        'desc': 'El transistor entrega la corriente al motor y permite aumentar la velocidad.',
        'formula': 'V_motor ∝ V_out\nVelocidad ≈ (V_motor / 12 V) × 100%',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xff0B1120),
      drawer: const PanelDesplegable(currentScreen: 'etapas'),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'ETAPAS DEL SISTEMA',
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
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Etapas del sistema',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Cada bloque transforma la señal del circuito: el LM35 genera el voltaje, el LM324 lo amplifica, el TIP41C entrega corriente y el motor responde.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, constraints) {
                final cross = constraints.maxWidth > 1100 ? 2 : 1;
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.1,
                  ),
                  itemCount: stages.length,
                  itemBuilder: (context, idx) {
                    final s = stages[idx];
                    return _stageCard(idx + 1, s['title']!, s['desc']!, s['formula'] ?? '');
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stageCard(int number, String title, String desc, String formula) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff0F172A), Color(0xff111827)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      desc,
                      style: const TextStyle(color: Colors.white70, height: 1.45, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    if (formula.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.greenAccent.withOpacity(0.15)),
                        ),
                        child: Text(
                          formula,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'Courier New',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          bottom: 8,
          child: Opacity(
            opacity: 0.08,
            child: Text(
              number.toString(),
              style: const TextStyle(
                fontSize: 92,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
