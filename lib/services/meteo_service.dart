import 'package:dio/dio.dart';
import '../models/meteo_data.dart';

class MeteoService {
  // Coordonnees GPS des villes
  static const Map<String, List<double>> coords = {
    'Cotonou': [6.3703, 2.3912],
    'Parakou': [9.3370, 2.6283],
    'Lagos': [6.4541, 3.3947],
    'Abidjan': [5.3600, -4.0083],
  };

  // Instance de dio configuree
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.open-meteo.com/v1',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  MeteoService() {
    // Ajouter un intercepteur de log
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (msg) => print('[DIO] $msg'),
      ),
    );
  }

  // Recuperer la meteo d'une ville
  Future<MeteoData?> getMeteo(String nomVille) async {
    final coords = _coords[nomVille];
    if (coords == null) {
      print('Ville inconnue : $nomVille');
      return null;
    }

    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'latitude': coords[0],
          'longitude': coords[1],
          'current': 'temperature_2m,relative_humidity_2m,weathercode',
          'timezone': 'Africa/Lagos',
        },
      );

      // Extraire la section "current" de la reponse
      final current = response.data['current'] as Map<String, dynamic>;
      return MeteoData.fromJson(current);
    } on DioException catch (e) {
      print('Erreur reseau : ${e.message}');
      return null;
    }
  }
}
