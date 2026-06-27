import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../viewmodels/ville_viewmodels.dart';
import '../services/meteo_service.dart';
import '../services/localisation_service.dart';
import 'ecran_liste_ville.dart';
import 'ecran_detail_ville.dart';

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
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) setState(() => _visible = true);
    });
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
                  // Hero + infos meteo avec navigation vers detail
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EcranDetailVille(
                            ville: vm.villeSelectionnee!,
                            meteo: vm.meteoActuelle,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Hero(
                          tag: 'icone-${vm.villeSelectionnee?.nom ?? "meteo"}',
                          child: Icon(
                            _iconeMeteo(vm.villeSelectionnee?.condition ?? ''),
                            size: 100,
                            color: Colors.orange,
                          ),
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
                                  Icon(
                                    Icons.wifi_off,
                                    size: 60,
                                    color: Colors.red,
                                  ),
                                  Text(
                                    vm.erreur!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => vm.selectionnerVille(
                                      vm.villeSelectionnee!,
                                    ),
                                    child: Text('Reessayer'),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                // AnimatedSwitcher sur la temperature
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 400),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: Text(
                                    '${vm.meteoActuelle?.temperature.toStringAsFixed(1) ?? '--'} C',
                                    key: ValueKey(vm.villeSelectionnee?.nom),
                                    style: TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${vm.meteoActuelle?.conditionTexte ?? ''} - ${vm.meteoActuelle?.humidite ?? '--'}% humidite',
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          ville.nom,
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
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
}
