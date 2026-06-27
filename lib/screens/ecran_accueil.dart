import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../viewmodels/ville_viewmodels.dart';
import '../services/meteo_service.dart';
import '../services/localisation_service.dart';
import 'ecran_liste_ville.dart';

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Demarrer l'animation apres 300 ms
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) setState(() => _visible = true);
    });
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
      body: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeIn,
        child: ville == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bouton photo
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        context.read<VilleViewModel>().mettreAJourPhoto(
                          image.path,
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: vm.villeSelectionnee?.photoPath != null
                          ? Image.file(
                              File(vm.villeSelectionnee!.photoPath!),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  Text('Appuyez pour ajouter une photo'),
                                ],
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Icon(
                    _iconeMeteo(ville.condition),
                    size: 100,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Consumer<VilleViewModel>(
                    builder: (context, vm, _) {
                      if (vm.chargement) {
                        return CircularProgressIndicator();
                      }
                      if (vm.erreur != null) {
                        return Column(
                          children: [
                            Icon(Icons.wifi_off, size: 60, color: Colors.red),
                            Text(
                              vm.erreur!,
                              style: TextStyle(color: Colors.red),
                            ),
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
                  // Bouton GPS
                  ElevatedButton.icon(
                    icon: Icon(Icons.my_location),
                    label: Text('Trouver la ville la plus proche'),
                    onPressed: () async {
                      final service = LocalisationService();
                      final position = await service.getPosition();

                      if (position != null) {
                        final vm = context.read<VilleViewModel>();
                        final villeProche = service.trouverVilleProche(
                          position,
                          vm.villes,
                          MeteoService.coords,
                        );

                        if (villeProche != null) {
                          vm.selectionnerVille(villeProche);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ville proche : ${villeProche.nom}',
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('GPS indisponible')),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  // Bouton changer de ville
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
      ),
    );
  }

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
}
