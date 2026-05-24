import 'package:dcppwer/screens/controlscreen.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC-Power',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 140, 9, 221),
        ), //https://ibb.co/cSctKMXV
        useMaterial3: true,
      ),
      home: const ControlScreen(),
    );
  }
}
