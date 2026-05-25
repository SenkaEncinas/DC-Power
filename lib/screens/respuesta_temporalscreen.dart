import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dcppwer/screens/panel_desplegable.dart';

class RespuestaTemporalScreen extends StatefulWidget {
	const RespuestaTemporalScreen({super.key});

	@override
	State<RespuestaTemporalScreen> createState() => _RespuestaTemporalScreenState();
}

class _RespuestaTemporalScreenState extends State<RespuestaTemporalScreen>
		with SingleTickerProviderStateMixin {
	double r1 = 100000;
	double r2 = 20000;
	double temperatura = 30;
	double tau = 2.5;
	double amplitud = 1.0;
	String tipoEntrada = 'Escalón';

	late final AnimationController controller;

	@override
	void initState() {
		super.initState();
		controller = AnimationController(
			vsync: this,
			duration: const Duration(seconds: 2),
		)..repeat();
	}

	@override
	void dispose() {
		controller.dispose();
		super.dispose();
	}

	double get vin => temperatura * 0.01;
	double get ganancia => 1 + (r1 / r2);
	double get vout => min(vin * ganancia, 12);
	double get velocidad => (vout / 12) * 100;
	double get kSistema => (ganancia * amplitud).clamp(0.1, 20.0);

	List<FlSpot> get responsePoints {
		return List.generate(80, (index) {
			final t = (index / 79) * 20;
			double y;

			if (tipoEntrada == 'Escalón') {
				y = kSistema * (1 - exp(-t / tau));
			} else if (tipoEntrada == 'Pulso') {
				y = t <= 2 ? kSistema * (1 - exp(-t / tau)) : kSistema * exp(-(t - 2) / tau);
			} else {
				y = kSistema * sin((t / tau).clamp(0, 999));
			}

			return FlSpot(t, y.clamp(0.0, kSistema * 1.1));
		});
	}

	@override
	Widget build(BuildContext context) {
		final puntos = responsePoints;
		final maxY = max(1.0, kSistema * 1.1);

		return Scaffold(
			backgroundColor: Colors.black,
			drawer: const PanelDesplegable(currentScreen: 'respuestaTemporal'),
			appBar: AppBar(
				backgroundColor: Colors.black,
				elevation: 0,
				centerTitle: true,
				title: const Text(
					'RESPUESTA TEMPORAL DEL SISTEMA',
					style: TextStyle(
						color: Colors.greenAccent,
						fontSize: 18,
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
					padding: const EdgeInsets.all(16),
					child: LayoutBuilder(
						builder: (context, constraints) {
							final isWide = constraints.maxWidth > 900;
							return isWide
									? Row(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Expanded(child: _buildControlsCard()),
												const SizedBox(width: 18),
												Expanded(child: _buildChartCard(puntos, maxY)),
											],
										)
									: Column(
											children: [
												_buildControlsCard(),
												const SizedBox(height: 18),
												_buildChartCard(puntos, maxY),
											],
										);
						},
					),
				),
			),
		);
	}

	Widget _buildControlsCard() {
		return Container(
			padding: const EdgeInsets.all(24),
			decoration: cardDecoration(),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Respuesta temporal del sistema',
						style: TextStyle(
							fontSize: 30,
							fontWeight: FontWeight.w900,
							color: Colors.white,
						),
					),
					const SizedBox(height: 14),
					Text(
						'Cambia los parámetros de tu circuito para ver cómo evoluciona la salida del motor según la temperatura y la ganancia del LM324.',
						style: TextStyle(
							fontSize: 16,
							height: 1.5,
							color: Colors.white70,
						),
					),
					const SizedBox(height: 22),
					_inputCard(
						title: 'Tipo de entrada',
						child: DropdownButtonFormField<String>(
							value: tipoEntrada,
							decoration: _fieldDecoration(),
							dropdownColor: const Color(0xff111827),
							style: const TextStyle(color: Colors.white),
							items: [
								DropdownMenuItem(value: 'Escalón', child: const Text('Escalón', style: TextStyle(color: Colors.white))),
								DropdownMenuItem(value: 'Pulso', child: const Text('Pulso', style: TextStyle(color: Colors.white))),
								DropdownMenuItem(value: 'Senoidal', child: const Text('Senoidal', style: TextStyle(color: Colors.white))),
							],
							iconEnabledColor: Colors.white,
							onChanged: (value) {
								if (value == null) return;
								setState(() => tipoEntrada = value);
							},
						),
					),
					_inputCard(
						title: 'Ganancia R1/R2',
						trailing: '${ganancia.toStringAsFixed(2)}',
						child: Slider(
							min: 1000,
							max: 100000,
							value: r1,
							activeColor: Colors.greenAccent,
							onChanged: (value) => setState(() => r1 = value),
						),
					),
					_inputCard(
						title: 'Constante de tiempo τ (s)',
						trailing: tau.toStringAsFixed(1),
						child: Slider(
							min: 0.5,
							max: 8,
							value: tau,
							activeColor: Colors.cyan,
							onChanged: (value) => setState(() => tau = value),
						),
					),
					_inputCard(
						title: 'Amplitud de entrada A',
						trailing: amplitud.toStringAsFixed(1),
						child: Slider(
							min: 0.2,
							max: 3,
							value: amplitud,
							activeColor: Colors.orange,
							onChanged: (value) => setState(() => amplitud = value),
						),
					),
					_inputCard(
						title: 'Temperatura LM35',
						trailing: '${temperatura.toStringAsFixed(1)} °C',
						child: Slider(
							min: 0,
							max: 100,
							value: temperatura,
							activeColor: Colors.orange,
							onChanged: (value) => setState(() => temperatura = value),
						),
					),
					const SizedBox(height: 10),
					Wrap(
						spacing: 10,
						runSpacing: 10,
						children: [
							_chip('Vin ${vin.toStringAsFixed(2)} V'),
							_chip('Vout ${vout.toStringAsFixed(2)} V'),
							_chip('Velocidad ${velocidad.toStringAsFixed(0)} %'),
							_chip('K ${kSistema.toStringAsFixed(2)}'),
						],
					),
					const SizedBox(height: 18),
					Container(
						padding: const EdgeInsets.all(18),
						decoration: BoxDecoration(
							gradient: const LinearGradient(
								colors: [Color(0xff0F172A), Color(0xff111827)],
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
							),
							borderRadius: BorderRadius.circular(24),
							border: Border.all(color: Colors.white12),
						),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								const Text(
									'Circuito equivalente',
									style: TextStyle(
										fontSize: 18,
										fontWeight: FontWeight.bold,
										color: Colors.greenAccent,
									),
								),
								const SizedBox(height: 12),
								_circuitBlock('LM35', '${vin.toStringAsFixed(2)} V', Colors.orange),
								const SizedBox(height: 10),
								_circuitArrow(),
								const SizedBox(height: 10),
								_circuitBlock('LM324', 'G=${ganancia.toStringAsFixed(2)}', Colors.deepOrange),
								const SizedBox(height: 10),
								_circuitArrow(),
								const SizedBox(height: 10),
								_circuitBlock('TIP41C', '${vout.toStringAsFixed(2)} V', Colors.green),
								const SizedBox(height: 10),
								_circuitArrow(),
								const SizedBox(height: 10),
								_circuitBlock('Motor', '${velocidad.toStringAsFixed(0)} %', Colors.brown),
							],
						),
					),
				],
			),
		);
	}

	Widget _buildChartCard(List<FlSpot> points, double maxY) {
		return Container(
			padding: const EdgeInsets.all(22),
			decoration: cardDecoration(),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Gráfica de respuesta',
						style: TextStyle(
							fontSize: 24,
							fontWeight: FontWeight.w900,
							color: Colors.white,
						),
					),
					const SizedBox(height: 14),
					SizedBox(
						height: 420,
						child: CustomPaint(
							painter: _ResponsePainter(points, maxY),
							child: Container(),
						),
					),
					const SizedBox(height: 14),
					Text(
						'Salida del sistema para ${tipoEntrada.toLowerCase()} con parámetros del circuito.',
						style: TextStyle(
							color: Colors.white70,
							fontSize: 14,
						),
					),
				],
			),
		);
	}

	Widget _inputCard({
		required String title,
		required Widget child,
		String? trailing,
	}) {
		return Container(
			margin: const EdgeInsets.only(bottom: 14),
			padding: const EdgeInsets.all(18),
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xff0F172A), Color(0xff111827)],
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
				),
				borderRadius: BorderRadius.circular(22),
				border: Border.all(color: Colors.white12),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text(
								title,
								style: const TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
									color: Colors.white,
								),
							),
							if (trailing != null)
								Text(
									trailing,
									style: const TextStyle(
										fontSize: 16,
										fontWeight: FontWeight.bold,
										color: Colors.greenAccent,
									),
								),
						],
					),
					const SizedBox(height: 8),
					child,
				],
			),
		);
	}

	InputDecoration _fieldDecoration() {
		return InputDecoration(
			filled: true,
			fillColor: Colors.white.withOpacity(0.06),
			border: OutlineInputBorder(
				borderRadius: BorderRadius.circular(14),
				borderSide: const BorderSide(color: Colors.white12),
			),
			enabledBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(14),
				borderSide: const BorderSide(color: Colors.white12),
			),
			focusedBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(14),
				borderSide: const BorderSide(color: Colors.greenAccent),
			),
			labelStyle: const TextStyle(color: Colors.white70),
			contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
		);
	}

	Widget _chip(String label) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			decoration: BoxDecoration(
				color: Colors.white.withOpacity(0.05),
				borderRadius: BorderRadius.circular(999),
				border: Border.all(color: Colors.white12),
			),
			child: Text(
				label,
				style: const TextStyle(
					color: Colors.white,
					fontWeight: FontWeight.bold,
				),
			),
		);
	}

	Widget _circuitBlock(String name, String value, Color color) {
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
			decoration: BoxDecoration(
				color: Colors.white.withOpacity(0.03),
				borderRadius: BorderRadius.circular(18),
				border: Border.all(color: Colors.white12),
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Text(
						name,
						style: TextStyle(
							color: color,
							fontWeight: FontWeight.w900,
							fontSize: 16,
						),
					),
					Text(
						value,
						style: const TextStyle(
							color: Colors.white,
							fontWeight: FontWeight.bold,
							fontSize: 15,
						),
					),
				],
			),
		);
	}

	Widget _circuitArrow() {
		return const Center(
			child: Icon(Icons.arrow_downward_rounded, color: Colors.greenAccent, size: 26),
		);
	}

	BoxDecoration cardDecoration() {
		return BoxDecoration(
			gradient: const LinearGradient(
				colors: [Color(0xff0F172A), Color(0xff111827)],
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

class FlSpot {
	const FlSpot(this.x, this.y);

	final double x;
	final double y;
}

class _ResponsePainter extends CustomPainter {
	_ResponsePainter(this.points, this.maxY);

	final List<FlSpot> points;
	final double maxY;

	@override
	void paint(Canvas canvas, Size size) {
		final axisPaint = Paint()
			..color = Colors.white24
			..strokeWidth = 1;

		final gridPaint = Paint()
			..color = Colors.white12
			..strokeWidth = 1;

		final linePaint = Paint()
			..color = Colors.greenAccent
			..strokeWidth = 3
			..style = PaintingStyle.stroke
			..strokeCap = StrokeCap.round;

		final fillPaint = Paint()
			..color = Colors.greenAccent.withOpacity(0.12)
			..style = PaintingStyle.fill;

		const leftPad = 44.0;
		const rightPad = 12.0;
		const topPad = 18.0;
		const bottomPad = 46.0;

		final chartWidth = size.width - leftPad - rightPad;
		final chartHeight = size.height - topPad - bottomPad;
		final origin = Offset(leftPad, topPad + chartHeight);

		for (int i = 0; i <= 5; i++) {
			final y = topPad + (chartHeight / 5) * i;
			canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
		}

		for (int i = 0; i <= 10; i++) {
			final x = leftPad + (chartWidth / 10) * i;
			canvas.drawLine(Offset(x, topPad), Offset(x, topPad + chartHeight), gridPaint);
		}

		canvas.drawLine(Offset(leftPad, topPad), Offset(leftPad, topPad + chartHeight), axisPaint);
		canvas.drawLine(origin, Offset(size.width - rightPad, origin.dy), axisPaint);

		final path = Path();
		final fillPath = Path();

		for (int i = 0; i < points.length; i++) {
			final px = leftPad + (points[i].x / points.last.x) * chartWidth;
			final py = topPad + chartHeight - (points[i].y / maxY) * chartHeight;
			if (i == 0) {
				path.moveTo(px, py);
				fillPath.moveTo(px, origin.dy);
				fillPath.lineTo(px, py);
			} else {
				path.lineTo(px, py);
				fillPath.lineTo(px, py);
			}
		}

		fillPath.lineTo(leftPad + chartWidth, origin.dy);
		fillPath.close();

		canvas.drawPath(fillPath, fillPaint);
		canvas.drawPath(path, linePaint);

		final labelStyle = TextStyle(
			color: Colors.white70,
			fontSize: 11,
			fontWeight: FontWeight.w600,
		);

		final tpX = TextPainter(
			text: const TextSpan(text: 'Tiempo (s)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
			textDirection: TextDirection.ltr,
		)..layout();
		tpX.paint(canvas, Offset(size.width / 2 - tpX.width / 2, size.height - 24));

		final tpY = TextPainter(
			text: const TextSpan(text: 'Salida del sistema', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
			textDirection: TextDirection.ltr,
		)..layout();
		canvas.save();
		canvas.translate(14, size.height / 2 + tpY.width / 2);
		canvas.rotate(-pi / 2);
		tpY.paint(canvas, Offset.zero);
		canvas.restore();

		for (int i = 0; i <= 5; i++) {
			final value = maxY - (maxY / 5) * i;
			final y = topPad + (chartHeight / 5) * i;
			final tp = TextPainter(
				text: TextSpan(text: value.toStringAsFixed(1), style: labelStyle),
				textDirection: TextDirection.ltr,
			)..layout();
			tp.paint(canvas, Offset(4, y - tp.height / 2));
		}
	}

	@override
	bool shouldRepaint(covariant _ResponsePainter oldDelegate) {
		return oldDelegate.points != points || oldDelegate.maxY != maxY;
	}
}
