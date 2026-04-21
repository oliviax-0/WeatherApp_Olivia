import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../config/secrets.dart';  //change to config/secrets.example.dart and add your API key there
import 'dart:ui';

class WeatherService {
  // Replace with your OpenWeatherMap API key
  static const String _apiKey = Secrets.openWeatherApiKey;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied. Please enable in settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<WeatherData> getWeatherByLocation(double lat, double lon) async {
    try {
      // Current weather
      final currentUrl = Uri.parse(
          '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      final currentResponse = await http.get(currentUrl);

      if (currentResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch weather: ${currentResponse.statusCode}');
      }

      final currentJson = json.decode(currentResponse.body);

      // 5-day forecast (3-hour intervals)
      final forecastUrl = Uri.parse(
          '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&cnt=40');
      final forecastResponse = await http.get(forecastUrl);

      List<HourlyForecast> hourlyForecasts = [];
      List<DailyForecast> dailyForecasts = [];

      if (forecastResponse.statusCode == 200) {
        final forecastJson = json.decode(forecastResponse.body);
        final List<dynamic> forecastList = forecastJson['list'];

        // Get next 8 hourly (24 hours)
        hourlyForecasts = forecastList
            .take(8)
            .map((item) => HourlyForecast.fromJson(item))
            .toList();

        // Group by day for daily forecast
        dailyForecasts = _buildDailyForecasts(forecastList);
      }

      return WeatherData.fromJson(currentJson, hourlyForecasts, dailyForecasts);
    } catch (e) {
      throw Exception('Weather fetch error: $e');
    }
  }

  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      final currentUrl = Uri.parse(
          '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric');
      final currentResponse = await http.get(currentUrl);

      if (currentResponse.statusCode == 404) {
        throw Exception('City not found: $cityName');
      }
      if (currentResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch weather: ${currentResponse.statusCode}');
      }

      final currentJson = json.decode(currentResponse.body);
      final lat = currentJson['coord']['lat'];
      final lon = currentJson['coord']['lon'];

      final forecastUrl = Uri.parse(
          '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&cnt=40');
      final forecastResponse = await http.get(forecastUrl);

      List<HourlyForecast> hourlyForecasts = [];
      List<DailyForecast> dailyForecasts = [];

      if (forecastResponse.statusCode == 200) {
        final forecastJson = json.decode(forecastResponse.body);
        final List<dynamic> forecastList = forecastJson['list'];
        hourlyForecasts = forecastList
            .take(8)
            .map((item) => HourlyForecast.fromJson(item))
            .toList();
        dailyForecasts = _buildDailyForecasts(forecastList);
      }

      return WeatherData.fromJson(currentJson, hourlyForecasts, dailyForecasts);
    } catch (e) {
      rethrow;
    }
  }

  List<DailyForecast> _buildDailyForecasts(List<dynamic> forecastList) {
    final Map<String, List<dynamic>> dayGroups = {};

    for (final item in forecastList) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayKey = '${date.year}-${date.month}-${date.day}';
      dayGroups.putIfAbsent(dayKey, () => []).add(item);
    }

    final List<DailyForecast> dailyForecasts = [];

    for (final entry in dayGroups.entries.take(10)) {
      final items = entry.value;
      double minTemp = double.infinity;
      double maxTemp = double.negativeInfinity;
      double maxPop = 0;
      String iconCode = '01d';
      String description = '';

      for (final item in items) {
        final temp = (item['main']['temp'] as num).toDouble();
        final pop = (item['pop'] as num?)?.toDouble() ?? 0.0;
        if (temp < minTemp) minTemp = temp;
        if (temp > maxTemp) maxTemp = temp;
        if (pop > maxPop) {
          maxPop = pop;
          iconCode = item['weather'][0]['icon'] ?? '01d';
          description = item['weather'][0]['description'] ?? '';
        }
      }

      // Pick midday icon if available
      final middayItem = items.firstWhere(
        (item) {
          final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          return dt.hour >= 11 && dt.hour <= 14;
        },
        orElse: () => items[items.length ~/ 2],
      );
      iconCode = middayItem['weather'][0]['icon'] ?? iconCode;
      description = middayItem['weather'][0]['description'] ?? description;

      final date = DateTime.fromMillisecondsSinceEpoch(items[0]['dt'] * 1000);

      dailyForecasts.add(DailyForecast(
        date: date,
        tempMin: minTemp == double.infinity ? 0 : minTemp,
        tempMax: maxTemp == double.negativeInfinity ? 0 : maxTemp,
        iconCode: iconCode,
        pop: maxPop,
        description: description,
      ));
    }

    return dailyForecasts;
  }

  String getWeatherIconUrl(String iconCode, {bool large = false}) {
    final size = large ? '@2x' : '';
    return 'https://openweathermap.org/img/wn/$iconCode$size.png';
  }

  // Returns asset path for background image, null = fall back to gradient
  String? getBackgroundImage(String iconCode) {
    if (iconCode.startsWith('01') && iconCode.endsWith('d')) {
      return 'assets/bg_sunny.png';
    } else if (iconCode.startsWith('02') ||
        iconCode.startsWith('03') ||
        iconCode.startsWith('04')) {
      return 'assets/bg_cloudy.png';
    } else if (iconCode.startsWith('09') ||
        iconCode.startsWith('10') ||
        iconCode.startsWith('11')) {
      return 'assets/bg_rainy.png';
    }
    return null;
  }

  // Get weather condition background colors
  List<Color> getBackgroundColors(String iconCode, int clouds) {
    if (iconCode.startsWith('01')) {
      // Clear sky
      return iconCode.endsWith('d')
          ? [const Color(0xFF4A90D9), const Color(0xFF74B9FF)]
          : [const Color(0xFF1a1a2e), const Color(0xFF16213e)];
    } else if (iconCode.startsWith('02') || iconCode.startsWith('03')) {
      // Few/scattered clouds
      return [const Color(0xFF5B7FA8), const Color(0xFF7EA8C9)];
    } else if (iconCode.startsWith('04')) {
      // Broken/overcast clouds
      return [const Color(0xFF57636F), const Color(0xFF7B8B96)];
    } else if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      // Rain
      return [const Color(0xFF3D4E5C), const Color(0xFF546879)];
    } else if (iconCode.startsWith('11')) {
      // Thunderstorm
      return [const Color(0xFF2C3E50), const Color(0xFF34495e)];
    } else if (iconCode.startsWith('13')) {
      // Snow
      return [const Color(0xFF8fa8c8), const Color(0xFFaec6e8)];
    } else {
      // Mist/fog/haze
      return [const Color(0xFF6B7B8D), const Color(0xFF8B9BA8)];
    }
  }
}
