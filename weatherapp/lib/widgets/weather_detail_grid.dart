import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/weather_model.dart';

class WeatherDetailGrid extends StatelessWidget {
  final WeatherData weather;

  const WeatherDetailGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final items = [
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: 'HUMIDITY',
        value: '${weather.humidity}%',
        detail: _getHumidityDescription(weather.humidity),
      ),
      _DetailItem(
        icon: Icons.air,
        label: 'WIND',
        value: '${(weather.windSpeed * 3.6).round()} km/h',
        detail: _getWindDescription(weather.windSpeed),
      ),
      _DetailItem(
        icon: Icons.visibility_outlined,
        label: 'VISIBILITY',
        value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
        detail: weather.visibility >= 10000 ? 'Clear visibility' : 'Reduced visibility',
      ),
      _DetailItem(
        icon: Icons.thermostat_outlined,
        label: 'FEELS LIKE',
        value: '${weather.feelsLike.round()}°',
        detail: _getFeelsLikeDescription(weather.feelsLike, weather.temperature),
      ),
      _DetailItem(
        icon: Icons.cloud_outlined,
        label: 'CLOUD COVER',
        value: '${weather.clouds}%',
        detail: _getCloudDescription(weather.clouds),
      ),
      _DetailItem(
        icon: Icons.compress,
        label: 'PRESSURE',
        value: '${weather.humidity + 1000} hPa',
        detail: 'Atmospheric pressure',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items.map((item) => _buildDetailCard(item)).toList(),
    );
  }

  Widget _buildDetailCard(_DetailItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.icon, color: Colors.white.withOpacity(0.7), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.detail,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHumidityDescription(int humidity) {
    if (humidity < 30) return 'Dry conditions';
    if (humidity < 60) return 'Comfortable humidity';
    if (humidity < 80) return 'Muggy conditions';
    return 'Very humid';
  }

  String _getWindDescription(double windSpeed) {
    final kmh = windSpeed * 3.6;
    if (kmh < 5) return 'Calm';
    if (kmh < 20) return 'Light breeze';
    if (kmh < 40) return 'Moderate breeze';
    if (kmh < 60) return 'Fresh breeze';
    return 'Strong winds';
  }

  String _getFeelsLikeDescription(double feelsLike, double actual) {
    final diff = feelsLike - actual;
    if (diff.abs() < 2) return 'Similar to actual';
    if (diff > 0) return 'Feels warmer than actual';
    return 'Feels cooler than actual';
  }

  String _getCloudDescription(int clouds) {
    if (clouds < 10) return 'Clear sky';
    if (clouds < 30) return 'Few clouds';
    if (clouds < 70) return 'Partly cloudy';
    if (clouds < 90) return 'Mostly cloudy';
    return 'Overcast';
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final String detail;

  _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });
}
