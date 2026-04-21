import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

class DailyForecastCard extends StatelessWidget {
  final DailyForecast forecast;
  final WeatherService weatherService;
  final bool isToday;
  final double overallMin;
  final double overallMax;

  const DailyForecastCard({
    super.key,
    required this.forecast,
    required this.weatherService,
    this.isToday = false,
    required this.overallMin,
    required this.overallMax,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = isToday ? 'Today' : DateFormat('EEE').format(forecast.date);
    final range = overallMax - overallMin;
    final startFraction = range > 0 ? (forecast.tempMin - overallMin) / range : 0.0;
    final endFraction = range > 0 ? (forecast.tempMax - overallMin) / range : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Day label
          SizedBox(
            width: 56,
            child: Text(
              dayLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          // Weather icon + pop
          SizedBox(
            width: 64,
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: weatherService.getWeatherIconUrl(forecast.iconCode),
                  width: 32,
                  height: 32,
                  placeholder: (_, __) =>
                      const SizedBox(width: 32, height: 32),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.cloud,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
                if (forecast.pop > 0.2)
                  Text(
                    '${(forecast.pop * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xFF7EC8E3),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          // Low temp
          SizedBox(
            width: 36,
            child: Text(
              '${forecast.tempMin.round()}°',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Temperature range bar
          Expanded(
            flex: 3,
            child: _buildTempBar(startFraction.toDouble(), endFraction.toDouble()),
          ),
          const SizedBox(width: 10),
          // High temp
          SizedBox(
            width: 36,
            child: Text(
              '${forecast.tempMax.round()}°',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempBar(double startFraction, double endFraction) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            // Background track
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Temperature range fill
            Positioned(
              left: width * startFraction,
              width: width * (endFraction - startFraction),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
