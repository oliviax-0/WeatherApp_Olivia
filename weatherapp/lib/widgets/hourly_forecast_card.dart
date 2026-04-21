import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast forecast;
  final WeatherService weatherService;
  final bool isNow;

  const HourlyForecastCard({
    super.key,
    required this.forecast,
    required this.weatherService,
    this.isNow = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = isNow ? 'Now' : DateFormat('h a').format(forecast.time);

    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeLabel,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: isNow ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          if (forecast.pop > 0.2)
            Text(
              '${(forecast.pop * 100).round()}%',
              style: const TextStyle(
                color: Color(0xFF7EC8E3),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            const SizedBox(height: 14),
          const SizedBox(height: 2),
          CachedNetworkImage(
            imageUrl: weatherService.getWeatherIconUrl(forecast.iconCode),
            width: 36,
            height: 36,
            placeholder: (_, __) => const SizedBox(width: 36, height: 36),
            errorWidget: (_, __, ___) => const Icon(
              Icons.cloud,
              color: Colors.white70,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${forecast.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
