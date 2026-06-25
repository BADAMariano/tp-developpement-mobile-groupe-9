import 'package:flutter/material.dart';

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Météo')),
      body: const Center(child: Text('Bienvenue')),
    );
  }
}
