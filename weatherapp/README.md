
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


