import 'package:flutter/material.dart';

class InformeScreen extends StatelessWidget {
  const InformeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "INFORME TÉCNICO",
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

              // Contenido del Informe
              _sectionTitle("Portada"),
              _modernCard(
                child: Column(
                  children: [
                    _imageBox("assets/informe_portada.png"),
                    const SizedBox(height: 16),
                    const Text(
                      "CONTROL DE VELOCIDAD DE MOTOR DC",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Facultad de Ingeniería - TECNOUPSA\nSanta Cruz de la Sierra, 25 de mayo de 2026",
                      style: TextStyle(color: Colors.white70, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _sectionTitle("Resumen Ejecutivo"),
              _modernTextCard(
                "El presente proyecto consiste en el desarrollo de un sistema analógico de control automático de velocidad para un ventilador DC mediante sensores de temperatura utilizando LM35, LM324 y TIP41C.",
              ),

              _sectionTitle("Planteamiento del Problema"),
              _modernTextCard(
                "Muchos sistemas electrónicos presentan problemas de sobrecalentamiento y desperdicio energético debido a que los ventiladores trabajan constantemente a máxima velocidad. Se desarrolló un sistema capaz de regular automáticamente la velocidad según la temperatura.",
              ),

              _sectionTitle("Objetivo General"),
              _modernTextCard(
                "Diseñar e implementar un controlador analógico de velocidad para un ventilador DC utilizando sensores de temperatura y componentes electrónicos analógicos.",
              ),

              _sectionTitle("Metodología"),
              _modernCard(
                child: _bullets([
                  "Diseño y simulación del circuito",
                  "Implementación física en protoboard",
                  "Integración del sensor LM35",
                  "Configuración del amplificador LM324",
                  "Conexión del transistor TIP41C",
                  "Pruebas de respuesta térmica",
                ]),
              ),

              _sectionTitle("Desarrollo del Proyecto"),
              _modernTextCard(
                "El LM35 detecta la temperatura y genera una señal proporcional. El LM324 amplifica dicha señal y controla al transistor TIP41C, regulando la corriente al ventilador. A mayor temperatura, mayor velocidad del motor.",
              ),

              _sectionTitle("Componentes Utilizados"),
              _modernCard(
                child: _bullets([
                  "LM35 – Sensor de temperatura",
                  "LM324 – Amplificador operacional",
                  "TIP41C – Transistor NPN de potencia",
                  "1N4007 – Diodo rectificador",
                  "Resistencias: 100kΩ, 20kΩ, 1kΩ",
                  "Ventilador DC 12V",
                  "Fuente de alimentación 12V",
                ]),
              ),

              _sectionTitle("Funcionamiento del Circuito"),
              _modernTextCard(
                "El sistema convierte la temperatura en una señal eléctrica. Esta es amplificada y utilizada para controlar la potencia entregada al ventilador, logrando un control proporcional automático.",
              ),

              _sectionTitle("Conclusiones"),
              _modernTextCard(
                "Se logró desarrollar un sistema funcional de control automático. El proyecto permitió aplicar conocimientos de electrónica analógica y demostrar mejoras en eficiencia energética.",
              ),

              _sectionTitle("Recomendaciones"),
              _modernTextCard(
                "Implementar disipadores térmicos, considerar control PWM digital y diseñar una PCB para una versión final más compacta y profesional.",
              ),

              _sectionTitle("Diagrama del Circuito"),
              _modernCard(
                child: _imageBox("assets/informe_diagrama.png"),
              ),

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1E3A8A), Color(0xff0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(color: Colors.greenAccent.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.assignment_rounded, size: 70, color: Colors.greenAccent),
          const SizedBox(height: 16),
          const Text(
            "INFORME TÉCNICO",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            "Control de Velocidad de Motor DC",
            style: TextStyle(fontSize: 18, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _modernCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _modernTextCard(String text) {
    return _modernCard(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _bullets(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(color: Colors.greenAccent, fontSize: 18)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _imageBox(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 4.0,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => Container(
            height: 300,
            color: Colors.grey[900],
            child: const Center(
              child: Text(
                "Imagen no encontrada",
                style: TextStyle(color: Colors.white54),
              ),
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