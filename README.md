# 🕌 Al-Qibla

A beautifully designed Flutter app for Muslims — featuring a live Qibla compass, accurate prayer times, nearby mosque finder, and customizable notifications.

---

## Screenshots

> _Coming soon — run the app and drop your screenshots here._

---

## Features

### 🧭 Qibla Compass
- Real-time compass needle pointing toward the Kaaba (Makkah)
- Gold needle animates and glows on perfect alignment
- Displays bearing in degrees + cardinal direction (e.g. `67° NE`)
- Shows distance to the Kaaba in kilometers
- Works fully offline once location is obtained

### 🕐 Prayer Times
- Accurate prayer times calculated using the **Adhan** library
- Supports 10 calculation methods (Umm al-Qura, Muslim World League, ISNA, etc.)
- Live countdown timer to the next prayer
- Per-prayer notification toggles with system-level scheduling
- Passes/active/upcoming state for each prayer tile
- Pull-to-refresh support

### 🗺️ Mosque Finder
- Fetches real nearby mosques using the **OpenStreetMap Overpass API** — no API key required
- Search mosques by name
- Shows distance and estimated walking time for each mosque
- "Navigate" button opens **Google Maps** with walking directions
- Fallback "Search on Google Maps" for areas with no results

### ⚙️ Settings
- Switch between **10 prayer calculation methods**
- Toggle **Asr jurisprudence** (Standard vs Hanafi)
- Master toggle for all prayer notifications
- Individual per-prayer notification control
- Vibrate on Qibla alignment toggle
- All settings persist across sessions via **SharedPreferences**

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Prayer Calculations | [adhan](https://pub.dev/packages/adhan) |
| Compass Sensor | [flutter_compass](https://pub.dev/packages/flutter_compass) |
| Location | [geolocator](https://pub.dev/packages/geolocator) |
| Mosque Data | [OpenStreetMap Overpass API](https://overpass-api.de) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| Persistence | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| Maps Navigation | [url_launcher](https://pub.dev/packages/url_launcher) → Google Maps |
| HTTP | [http](https://pub.dev/packages/http) |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, navigation shell
└── app/
    ├── core/
    │   ├── app_theme.dart             # Colors, typography, ThemeData
    │   └── colors.dart                # Raw color constants
    └── features/
        ├── screens/
        │   ├── compass_screen.dart    # Qibla compass UI + logic
        │   ├── prayers_screen.dart    # Prayer times UI + logic
        │   ├── mosques_screen.dart    # Mosque finder UI + logic
        │   └── settings_screen.dart  # Settings UI + logic
        ├── service/
        │   ├── qibla_service.dart     # Bearing & distance to Kaaba
        │   ├── location_service.dart  # GPS permission + position
        │   ├── prayer_time_service.dart # Adhan wrapper + formatters
        │   ├── mosque_service.dart    # Overpass API + Mosque model
        │   ├── notification_service.dart # Scheduled prayer notifications
        │   └── settings_service.dart # SharedPreferences wrapper
        └── widgets/
            └── app_bar_widget.dart    # Shared app bar
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.11.5`
- Dart SDK `>=3.11.5`
- Android SDK (API 21+) or iOS 13+
- A physical device recommended for compass accuracy

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/qibla_compass_app.git
cd qibla_compass_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Android Setup

Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Inside <manifest> -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-feature android:name="android.hardware.sensor.compass" android:required="true"/>

<!-- Inside <application> — required for url_launcher -->
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="https"/>
  </intent>
</queries>
```

### iOS Setup

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Al-Qibla needs your location to calculate the Qibla direction and prayer times.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Al-Qibla needs your location to calculate the Qibla direction and prayer times.</string>
```

---

## Permissions

| Permission | Platform | Reason |
|---|---|---|
| `ACCESS_FINE_LOCATION` | Android | GPS for Qibla & prayer times |
| `ACCESS_COARSE_LOCATION` | Android | Fallback location |
| `INTERNET` | Android | Fetch mosque data from Overpass API |
| `SCHEDULE_EXACT_ALARM` | Android 12+ | Exact prayer time notifications |
| `NSLocationWhenInUseUsageDescription` | iOS | GPS for Qibla & prayer times |

---

## Prayer Calculation Methods

The app supports the following authorities via the Adhan library:

| Method | Region |
|---|---|
| Umm al-Qura University | Saudi Arabia (default) |
| Muslim World League | Global |
| Egyptian General Authority | Egypt |
| University of Islamic Sciences, Karachi | Pakistan |
| Islamic Society of North America | North America |
| Kuwait | Kuwait |
| Qatar | Qatar |
| Majlis Ugama Islam Singapura | Singapore |
| Institute of Geophysics, Tehran | Iran |
| Diyanet İşleri Başkanlığı | Turkey |

---

## How Qibla Is Calculated

The bearing to the Kaaba is calculated using **spherical trigonometry** (great-circle navigation):

```
y = sin(ΔLng) × cos(lat_kaaba)
x = cos(lat_user) × sin(lat_kaaba) − sin(lat_user) × cos(lat_kaaba) × cos(ΔLng)
bearing = atan2(y, x) normalized to 0–360°
```

Kaaba coordinates used: **21.4225° N, 39.8262° E**

---

## Mosque Data

Mosque locations are sourced from **OpenStreetMap** via the free [Overpass API](https://overpass-api.de). No API key is required. The app queries for `amenity=place_of_worship` + `religion=muslim` within a 5 km radius of the user's location and sorts results by distance using the Haversine formula.

---

## Known Limitations

- **Compass accuracy** depends on device hardware and magnetic interference. Calibrate by moving the phone in a figure-8 pattern.
- **Hijri date** is approximated. For production accuracy, integrate the [`hijri`](https://pub.dev/packages/hijri) package.
- **Mosque data** relies on OpenStreetMap volunteers — coverage may vary in some areas.
- **Exact alarms** on Android 12+ require the `SCHEDULE_EXACT_ALARM` permission. Some OEM ROMs may restrict background scheduling.

---

## Roadmap

- [ ] Hijri calendar integration
- [ ] Adhan audio playback at prayer time
- [ ] Dark mode support
- [ ] Widget (home screen prayer times)
- [ ] Multiple location profiles
- [ ] Offline mosque caching

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

```bash
# Run analyzer before submitting
flutter analyze

# Run tests
flutter test
```

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Acknowledgements

- [Adhan by Batoul Apps](https://github.com/batoulapps/adhan-dart) — prayer time calculations
- [OpenStreetMap contributors](https://www.openstreetmap.org/copyright) — mosque location data
- [flutter_compass](https://pub.dev/packages/flutter_compass) — magnetometer sensor access

---

<p align="center">Made with ❤️ for the Ummah</p>
