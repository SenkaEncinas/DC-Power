import 'package:flutter/material.dart';

class FolletoScreen extends StatelessWidget {
  const FolletoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "FOLLETO DEL PROYECTO",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0B1120), Color(0xff0F172A), Color(0xff111827)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header Moderno
              _buildModernHeader(),
              const SizedBox(height: 28),

              // Imagen del Folleto
              _buildPosterSection(),
              const SizedBox(height: 32),

              // Secciones
              _sectionTitle("Explora el Proyecto"),
              const SizedBox(height: 16),
              ..._buildModernSections(),

              const SizedBox(height: 40),
              _buildBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1E3A8A), Color(0xff0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.speed_rounded, size: 72, color: Colors.greenAccent),
          const SizedBox(height: 16),
          const Text(
            "CONTROL DE VELOCIDAD",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "DE MOTOR DC",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "AUTOMATIZACIÓN ELECTRÓNICA • ET310",
            style: TextStyle(color: Colors.white60, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Folleto Oficial"),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: InteractiveViewer(
              minScale: 0.6,
              maxScale: 5.0,
              child: Image.asset(
                "assets/folleto.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 420,
                  color: const Color(0xff1F2937),
                  child: const Center(
                    child: Text(
                      "assets/folleto.png no encontrado",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  List<Widget> _buildModernSections() {
    final sections = [
      {"icon": Icons.info_outline, "title": "¿Qué es?", "color": Colors.cyan, "body": "Sistema analógico que regula automáticamente la velocidad de un ventilador DC según la temperatura detectada."},
      {"icon": Icons.flag_outlined, "title": "Objetivo", "color": Colors.orange, "body": "Diseñar e implementar un controlador analógico de velocidad utilizando LM35, LM324 y TIP41C."},
      {"icon": Icons.settings_outlined, "title": "Cómo funciona", "color": Colors.purple, "body": "El LM35 mide la temperatura, el LM324 procesa la señal y el TIP41C ajusta la potencia del ventilador."},
      {"icon": Icons.eco_outlined, "title": "Beneficios", "color": Colors.green, "body": "Eficiencia energética, protección térmica, control automático y mayor durabilidad de los componentes."},
      {"icon": Icons.widgets_outlined, "title": "Componentes Clave", "color": Colors.amber, "body": "• LM35 – Sensor de temperatura\n• LM324 – Amplificador operacional\n• TIP41C – Transistor de potencia\n• Ventilador DC 12V\n• Diodo 1N4007 y resistencias"},
    ];

    return sections.map((s) => _modernCard(s)).toList();
  }

  Widget _modernCard(Map<String, dynamic> s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {}, // Puedes agregar funcionalidad aquí si quieres
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xff111827),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: (s["color"] as Color).withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ExpansionTile(
              leading: Icon(s["icon"] as IconData, color: s["color"] as Color, size: 28),
              title: Text(
                s["title"] as String,
                style: TextStyle(
                  color: s["color"] as Color,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.5,
                ),
              ),
              iconColor: s["color"] as Color,
              collapsedIconColor: Colors.white70,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Text(
                    s["body"] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.65,
                      fontSize: 15.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text("VOLVER AL SIMULADOR"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          elevation: 8,
        ),
      ),
    );
  }
}