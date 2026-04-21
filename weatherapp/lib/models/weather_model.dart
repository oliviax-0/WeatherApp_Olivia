class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int visibility;
  final int clouds;
  final String iconCode;
  final List<HourlyForecast> hourlyForecasts;
  final List<DailyForecast> dailyForecasts;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.clouds,
    required this.iconCode,
    required this.hourlyForecasts,
    required this.dailyForecasts,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, List<HourlyForecast> hourly, List<DailyForecast> daily) {
    return WeatherData(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      visibility: json['visibility'] ?? 10000,
      clouds: json['clouds']['all'] ?? 0,
      iconCode: json['weather'][0]['icon'] ?? '01d',
      hourlyForecasts: hourly,
      dailyForecasts: daily,
    );
  }

  String get capitalizedDescription {
    if (description.isEmpty) return '';
    return description.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String iconCode;
  final double pop; // probability of precipitation

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.iconCode,
    required this.pop,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'] ?? '01d',
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String iconCode;
  final double pop;
  final String description;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.iconCode,
    required this.pop,
    required this.description,
  });
}
