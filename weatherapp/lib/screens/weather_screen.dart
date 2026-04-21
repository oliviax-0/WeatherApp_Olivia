import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/weather_detail_grid.dart';
import '../widgets/city_search_bar.dart';
import 'dart:ui';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _searchCity(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final weather = await _weatherService.getWeatherByCity(cityName);
      setState(() {
        _weatherData = weather;
        _isLoading = false;
      });
      _animController.forward(from: 0);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  List<Color> get _bgColors {
    if (_weatherData == null) {
      return [const Color(0xFF57636F), const Color(0xFF7B8B96)];
    }
    return _weatherService.getBackgroundColors(
      _weatherData!.iconCode,
      _weatherData!.clouds,
    );
  }

  String? get _bgImage {
    if (_weatherData == null) return null;
    return _weatherService.getBackgroundImage(_weatherData!.iconCode);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _bgImage != null;
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          if (hasImage)
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Image.asset(
                  _bgImage!,
                  key: ValueKey(_bgImage),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          // Gradient overlay
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: hasImage
                      ? [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.50),
                        ]
                      : _bgColors,
                ),
              ),
            ),
          ),
          // Content
          _isLoading
              ? _buildLoadingView()
              : _errorMessage != null
                  ? _buildErrorView()
                  : _weatherData == null
                      ? _buildEmptyView()
                      : _buildWeatherView(),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CitySearchBar(onSearch: _searchCity),
            const Spacer(),
            const Icon(Icons.wb_sunny_outlined, color: Colors.white38, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Search for a city\nto see the weather',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Fetching weather...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CitySearchBar(onSearch: _searchCity),
            const Spacer(),
            const Icon(Icons.cloud_off, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherView() {
    final weather = _weatherData!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopSection(weather),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildHourlyForecastCard(weather),
                    const SizedBox(height: 16),
                    _buildDailyForecastCard(weather),
                    const SizedBox(height: 16),
                    WeatherDetailGrid(weather: weather),
                    SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(WeatherData weather) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: CloudPainter()),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                CitySearchBar(onSearch: _searchCity),
                const SizedBox(height: 24),
                Text(
                  weather.cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${weather.temperature.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.w100,
                    height: 1.0,
                  ),
                ),
                Text(
                  weather.capitalizedDescription,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'H:${weather.tempMax.round()}°  L:${weather.tempMin.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecastCard(WeatherData weather) {
    String forecastText = 'Partly cloudy conditions expected. ';
    if (weather.windSpeed > 5) {
      forecastText += 'Wind gusts up to ${(weather.windSpeed * 3.6).round()} km/h.';
    }
    if (weather.humidity > 70) {
      forecastText += ' High humidity at ${weather.humidity}%.';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text(
                  forecastText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  itemCount: weather.hourlyForecasts.length,
                  itemBuilder: (context, index) {
                    return HourlyForecastCard(
                      forecast: weather.hourlyForecasts[index],
                      weatherService: _weatherService,
                      isNow: index == 0,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyForecastCard(WeatherData weather) {
    if (weather.dailyForecasts.isEmpty) return const SizedBox.shrink();

    double overallMin = weather.dailyForecasts
        .map((d) => d.tempMin)
        .reduce((a, b) => a < b ? a : b);
    double overallMax = weather.dailyForecasts
        .map((d) => d.tempMax)
        .reduce((a, b) => a > b ? a : b);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '10-DAY FORECAST',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weather.dailyForecasts.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.white.withValues(alpha: 0.1),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  return DailyForecastCard(
                    forecast: weather.dailyForecasts[index],
                    weatherService: _weatherService,
                    isToday: index == 0,
                    overallMin: overallMin,
                    overallMax: overallMax,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    _drawCloud(canvas, paint, size.width * 0.3, size.height * 0.2, 80);
    _drawCloud(canvas, paint, size.width * 0.7, size.height * 0.15, 60);
    _drawCloud(canvas, paint, size.width * 0.5, size.height * 0.35, 50);
  }

  void _drawCloud(Canvas canvas, Paint paint, double x, double y, double r) {
    canvas.drawCircle(Offset(x, y), r, paint);
    canvas.drawCircle(Offset(x + r * 0.6, y + 10), r * 0.7, paint);
    canvas.drawCircle(Offset(x - r * 0.6, y + 10), r * 0.6, paint);
    canvas.drawCircle(Offset(x + r * 0.3, y + 20), r * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
