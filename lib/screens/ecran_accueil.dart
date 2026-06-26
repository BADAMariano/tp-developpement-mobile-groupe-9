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
                // Affichage des vraies donnees meteo
                Consumer<VilleViewModel>(
                  builder: (context, vm, _) {
                    if (vm.chargement) {
                      return CircularProgressIndicator();
                    }
                    if (vm.erreur != null) {
                      return Column(
                        children: [
                          Icon(Icons.wifi_off, size: 60, color: Colors.red),
                          Text(vm.erreur!, style: TextStyle(color: Colors.red)),
                          ElevatedButton(
                            onPressed: () =>
                                vm.selectionnerVille(vm.villeSelectionnee!),
                            child: Text('Reessayer'),
                          ),
                        ],
                      );
                    }
                    final meteo = vm.meteoActuelle;
                    if (meteo == null) return Text('Chargement...');

                    return Column(
                      children: [
                        Text(
                          '${meteo.temperature.toStringAsFixed(1)} C',
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${meteo.conditionTexte} - ${meteo.humidite}% humidite',
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  ville.nom,
                  style: TextStyle(fontSize: 28, color: Colors.grey[700]),
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
