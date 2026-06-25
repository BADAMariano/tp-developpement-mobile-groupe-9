import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ville_viewmodels.dart';

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  // Retourne une icone selon la condition meteo
  IconData _iconeMeteo(String condition) {
    switch (condition) {
      case 'Ensoleille':
        return Icons.wb_sunny;
      case 'Nuageux':
        return Icons.cloud;
      case 'Pluvieux':
        return Icons.umbrella;
      default:
        return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    // On lit les donnees depuis le ViewModel
    final vm = context.watch<VilleViewModel>();
    final ville = vm.villeSelectionnee;

    return Scaffold(
      appBar: AppBar(
        title: Text('AppMeteo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ville == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icone meteo
                Icon(
                  _iconeMeteo(ville.condition),
                  size: 100,
                  color: Colors.orange,
                ),
                SizedBox(height: 16),
                // Temperature
                Text(
                  '${ville.temperature.toStringAsFixed(0)} C',
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
                // Nom de la ville
                Text(
                  ville.nom,
                  style: TextStyle(fontSize: 28, color: Colors.grey[700]),
                ),
                // Condition et humidite
                Text(
                  '${ville.condition} - Humidite : ${ville.humidite}%',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 32),
              ],
            ),
    );
  }
}
