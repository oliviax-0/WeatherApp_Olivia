# WeatherApp_Olivia

Setup
1. Get OpenWeatherMap API Key

Register at openweathermap.org
Go to My API Keys in your account
Copy your API key (free tier gives 60 calls/min - more than enough)

2. Add Your API Key
Open lib/services/weather_service.dart and replace:
dartstatic const String _apiKey = 'YOUR_OPENWEATHER_API_KEY';
With your actual API key:
dartstatic const String _apiKey = 'abc123yourrealkeyhere';
3. Install Dependencies
bashflutter pub get
4. Run the App
bash# Android
flutter run

# iOS (requires macOS + Xcode)
flutter run --device-id <your-ios-device-id>

Features:
📍 Auto-detect location via GPS
🔍 Search any city worldwide
🌡️ Current temperature, high/low, feels like
⏱️ Hourly forecast (next 24 hours)
📅 10-day daily forecast with temp range bars
💧 Precipitation probability
🌬️ Wind speed, humidity, visibility
🎨 Dynamic backgrounds (blue sunny → gray rainy → dark stormy)
✨ Smooth fade + slide animations on load
🔲 Glassmorphism blur cards (iOS-style)


