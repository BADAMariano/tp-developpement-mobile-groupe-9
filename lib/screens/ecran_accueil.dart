import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ville_viewmodels.dart';
import 'ecran_liste_ville.dart';

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

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
                Icon(
                  _iconeMeteo(ville.condition),
                  size: 100,
                  color: Colors.orange,
                ),
                SizedBox(height: 16),
                Text(
                  '${ville.temperature.toStringAsFixed(0)} C',
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                ),
                Text(
                  ville.nom,
                  style: TextStyle(fontSize: 28, color: Colors.grey[700]),
                ),
                Text(
                  '${ville.condition} - Humidite : ${ville.humidite}%',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EcranListeVilles()),
                    );
                  },
                  icon: Icon(Icons.list),
                  label: Text('Changer de ville'),
                ),
              ],
            ),
    );
  }
}
