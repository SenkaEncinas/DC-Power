import 'package:dcppwer/screens/SimuladorModeloScreen.dart';
import 'package:flutter/material.dart';
import 'package:dcppwer/screens/controlscreen.dart';
import 'package:dcppwer/screens/folletoscreen.dart';
import 'package:dcppwer/screens/informescreen.dart';
import 'package:dcppwer/screens/modelomatematico.dart';
import 'package:dcppwer/screens/animacioncircuito.dart';
import 'package:dcppwer/screens/respuesta_temporalscreen.dart';
import 'package:dcppwer/screens/etapas_sistema.dart';

class PanelDesplegable extends StatelessWidget {
	const PanelDesplegable({super.key, this.currentScreen = 'control'});

	final String currentScreen;

	@override
	Widget build(BuildContext context) {
		return Drawer(
			backgroundColor: const Color(0xff0B1120),
			child: SafeArea(
				child: Container(
					decoration: const BoxDecoration(
						gradient: LinearGradient(
							colors: [Color(0xff0B1120), Color(0xff0F172A), Color(0xff111827)],
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
						),
					),
					child: ListView(
						padding: EdgeInsets.zero,
						children: [
							DrawerHeader(
								decoration: const BoxDecoration(
									gradient: LinearGradient(
										colors: [Color(0xff111827), Color(0xff0F172A)],
										begin: Alignment.topLeft,
										end: Alignment.bottomRight,
									),
								),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									mainAxisAlignment: MainAxisAlignment.end,
									children: [
										const Icon(
											Icons.dashboard_customize,
											color: Colors.greenAccent,
											size: 44,
										),
										const SizedBox(height: 10),
										const Text(
											'Panel del sistema',
											style: TextStyle(
												color: Colors.white,
												fontSize: 22,
												fontWeight: FontWeight.bold,
											),
										),
										const SizedBox(height: 4),
										Text(
											'Acceso rápido a las etapas y pantallas',
											style: TextStyle(
												color: Colors.white.withOpacity(0.7),
												fontSize: 12,
											),
										),
									],
								),
							),
							_sectionTitle('Pantallas'),
							_menuTile(
								context,
								title: 'Pantalla principal',
								icon: Icons.home_outlined,
								selected: currentScreen == 'control',
								onTap: () => _openScreen(
									context,
									const ControlScreen(),
								),
							),
							_menuTile(
								context,
								title: 'Folleto',
								icon: Icons.menu_book_outlined,
								selected: currentScreen == 'folleto',
								onTap: () => _openScreen(
									context,
									const FolletoScreen(),
								),
							),
							_menuTile(
								context,
								title: 'Informe',
								icon: Icons.description_outlined,
								selected: currentScreen == 'informe',
								onTap: () => _openScreen(
									context,
									const InformeScreen(),
								),
							),
							const Divider(color: Colors.white12, height: 24),
							_sectionTitle('Etapas del sistema'),
							_futureTile(
								title: 'Simulador de modelo equivalente',
								icon: Icons.account_tree_outlined,
                selected: currentScreen == 'simuladormodeloequivalente',
								onTap: () => _openScreen(
									context,
									const SimuladorModeloScreen(),
								),
							),
							_futureTile(
								title: 'Respuesta temporal del sistema',
								icon: Icons.show_chart_outlined,
								selected: currentScreen == 'respuestaTemporal',
								onTap: () => _openScreen(
									context,
									const RespuestaTemporalScreen(),
								),
							),
							_futureTile(
								title: 'Animación del circuito',
								icon: Icons.animation_outlined,
								selected: currentScreen == 'animacion',
								onTap: () => _openScreen(
									context,
									const AnimacionCircuitoScreen(),
								),
							),
							_futureTile(
								title: 'Modelo Usado',
								icon: Icons.schema_outlined,
								selected: currentScreen == 'modelo',
								onTap: () => _openScreen(
									context,
									const ModeloMatematicoScreen(),
								),
							),
							_futureTile(
								title: 'Etapas del sistema',
								icon: Icons.layers_outlined,
								selected: currentScreen == 'etapas',
								onTap: () => _openScreen(
									context,
									const EtapasSistemaScreen(),
								),
							),
							const SizedBox(height: 18),
						],
					),
				),
			),
		);
	}

	Widget _sectionTitle(String title) {
		return Padding(
			padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
			child: Text(
				title,
				style: const TextStyle(
					color: Colors.white70,
					fontSize: 12,
					fontWeight: FontWeight.bold,
					letterSpacing: 1.1,
				),
			),
		);
	}

	Widget _menuTile(
		BuildContext context, {
		required String title,
		required IconData icon,
		required bool selected,
		required VoidCallback onTap,
	}) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
			child: ListTile(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(14),
					side: BorderSide(
						color: selected ? Colors.greenAccent : Colors.white12,
					),
				),
				tileColor: selected ? Colors.greenAccent.withOpacity(0.12) : Colors.white.withOpacity(0.03),
				leading: Icon(icon, color: selected ? Colors.greenAccent : Colors.white70),
				title: Text(
					title,
					style: TextStyle(
						color: selected ? Colors.greenAccent : Colors.white,
						fontWeight: FontWeight.bold,
					),
				),
				trailing: const Icon(Icons.chevron_right, color: Colors.white38),
				onTap: onTap,
			),
		);
	}

	Widget _futureTile({
		required String title,
		required IconData icon,
		bool selected = false,
		VoidCallback? onTap,
	}) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
			child: ListTile(
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(14),
					side: BorderSide(color: selected ? Colors.greenAccent : Colors.white12),
				),
				tileColor: selected ? Colors.greenAccent.withOpacity(0.12) : Colors.white.withOpacity(0.02),
				leading: Icon(icon, color: selected ? Colors.greenAccent : Colors.white38),
				title: Text(
					title,
					style: const TextStyle(
						color: Colors.white70,
						fontWeight: FontWeight.w500,
					),
				),
				trailing: onTap != null
					? const Icon(Icons.chevron_right, color: Colors.white38)
					: const Icon(Icons.lock_outline, color: Colors.white24),
				subtitle: onTap == null
					? const Text(
						'Próximamente',
						style: TextStyle(color: Colors.white38, fontSize: 12),
					)
					: null,
				enabled: onTap != null,
				onTap: onTap,
			),
		);
	}

	void _openScreen(BuildContext context, Widget screen) {
		Navigator.pop(context);
		Navigator.push(
			context,
			MaterialPageRoute(builder: (_) => screen),
		);
	}
}
