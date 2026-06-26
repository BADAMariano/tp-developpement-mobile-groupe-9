class MeteoData {
  final double temperature;
  final int humidite;
  final int weatherCode;

  MeteoData({
    required this.temperature,
    required this.humidite,
    required this.weatherCode,
  });

  factory MeteoData.fromJson(Map<String, dynamic> json) {
    return MeteoData(
      temperature: (json['temperature_2m'] as num).toDouble(),
      humidite: (json['relative_humidity_2m'] as num).toInt(),
      weatherCode: (json['weathercode'] as num).toInt(),
    );
  }

  String get conditionTexte {
    if (weatherCode == 0) return 'Ensoleille';
    if (weatherCode <= 3) return 'Nuageux';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Pluvieux';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Averses';
    if (weatherCode >= 95) return 'Orageux';
    return 'Variable';
  }
}
