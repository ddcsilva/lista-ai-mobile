import 'package:flutter/material.dart';

class ListaAiApp extends StatelessWidget {
  const ListaAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Lista AI - Setup OK!'),
        ),
      ),
    );
  }
}
