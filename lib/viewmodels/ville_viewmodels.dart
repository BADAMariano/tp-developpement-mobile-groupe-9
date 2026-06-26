import 'package:flutter/foundation.dart';
import '../models/ville.dart';
import '../services/meteo_service.dart';
import '../models/meteo_data.dart';

class VilleViewModel extends ChangeNotifier {
  final List<Ville> _villes = [
    Ville(
      nom: 'Cotonou',
      pays: 'Benin',
      temperature: 30,
      condition: 'Ensoleille',
      humidite: 80,
    ),
    Ville(
      nom: 'Parakou',
      pays: 'Benin',
      temperature: 28,
      condition: 'Nuageux',
      humidite: 70,
    ),
    Ville(
      nom: 'Lagos',
      pays: 'Nigeria',
      temperature: 32,
      condition: 'Pluvieux',
      humidite: 85,
    ),
    Ville(
      nom: 'Abidjan',
      pays: 'Cote dIvoire',
      temperature: 29,
      condition: 'Ensoleille',
      humidite: 75,
    ),
  ];

  Ville? _villeSelectionnee;
  final MeteoService _meteoService = MeteoService();
  MeteoData? _meteoActuelle;
  bool _chargement = false;
  String? _erreur;

  List<Ville> get villes => _villes;
  Ville? get villeSelectionnee => _villeSelectionnee;
  MeteoData? get meteoActuelle => _meteoActuelle;
  bool get chargement => _chargement;
  String? get erreur => _erreur;

  VilleViewModel() {
    _villeSelectionnee = _villes.first;
  }

  Future<void> selectionnerVille(Ville ville) async {
    _villeSelectionnee = ville;
    _chargement = true;
    _erreur = null;
    notifyListeners();

    final meteo = await _meteoService.getMeteo(ville.nom);

    if (meteo != null) {
      _meteoActuelle = meteo;
    } else {
      _erreur = 'Impossible de charger la meteo';
    }
    _chargement = false;
    notifyListeners();
  }
}
