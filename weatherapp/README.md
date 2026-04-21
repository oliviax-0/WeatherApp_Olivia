# Weather App 🌤️

A beautiful iOS-style Flutter weather app powered by OpenWeatherMap API.

## Screenshots
Matches the iOS Weather app UI with:
- Glassmorphism cards with backdrop blur
- Dynamic gradient backgrounds based on weather condition
- Hourly forecast with precipitation probability
- 10-day daily forecast with temperature range bars
- Weather detail grid (humidity, wind, visibility, feels like)
- City search + GPS location support

## Setup

### 1. Get OpenWeatherMap API Key
1. Register at [openweathermap.org](https://openweathermap.org/api)
2. Go to **My API Keys** in your account
3. Copy your API key (free tier gives 60 calls/min - more than enough)

### 2. Add Your API Key
Open `lib/services/weather_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY';
```
With your actual API key:
```dart
static const String _apiKey = 'abc123yourrealkeyhere';
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App
```bash
# Android
flutter run

# iOS (requires macOS + Xcode)
flutter run --device-id <your-ios-device-id>
```

## Project Structure
```
lib/
├── main.dart                    # App entry point
├── models/
│   └── weather_model.dart       # Data models
├── services/
│   └── weather_service.dart     # API calls + location
├── screens/
│   └── weather_screen.dart      # Main weather screen
└── widgets/
    ├── hourly_forecast_card.dart # Hourly forecast strip
    ├── daily_forecast_card.dart  # Daily forecast rows
    ├── weather_detail_grid.dart  # 2x3 detail grid
    └── city_search_bar.dart      # Animated search bar
```

## Features
- 📍 Auto-detect location via GPS
- 🔍 Search any city worldwide
- 🌡️ Current temperature, high/low, feels like
- ⏱️ Hourly forecast (next 24 hours)
- 📅 10-day daily forecast with temp range bars
- 💧 Precipitation probability
- 🌬️ Wind speed, humidity, visibility
- 🎨 Dynamic backgrounds (blue sunny → gray rainy → dark stormy)
- ✨ Smooth fade + slide animations on load
- 🔲 Glassmorphism blur cards (iOS-style)

## Dependencies
| Package | Purpose |
|---|---|
| `http` | API requests |
| `geolocator` | GPS location |
| `permission_handler` | Runtime permissions |
| `intl` | Date/time formatting |
| `cached_network_image` | Weather icons |
| `shimmer` | Loading skeletons |

## API Endpoints Used
- `GET /weather` — Current conditions
- `GET /forecast` — 5-day / 3-hour forecast (used for hourly + daily)

## Notes
- The free OpenWeatherMap tier does **not** include One Call API (used for hourly/daily in some apps)
- This app uses the `/forecast` endpoint which is available on the free tier
- Weather icons come from `openweathermap.org/img/wn/{icon}@2x.png`
