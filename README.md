# Air Cast – Live IPTV Streaming App

Air Cast is a modern IPTV streaming application built using Flutter.  
It allows users to securely access and stream live TV channels using IPTV playlists with a clean and fast user experience.

---

## Developer

Name: Haridharushan SV

---

## Features

- Firebase Email & Password Authentication
- Secure login with 3-day session validity
- Automatic logout after session expiry
- Live IPTV streaming support
- HLS (.m3u8) playback
- VLC-compatible streams
- Channel search functionality
- Language-based filtering (Tamil channels)
- Quality tags (SD / HD / FHD / 4K)
- Light mode user interface
- Card-based channel listing
- Cached channel logos
- Fast and smooth playback
- Optimized for Android devices

---

## Technology Stack

- Flutter
- Dart
- Riverpod (State Management)
- Firebase Authentication
- media_kit & media_kit_video
- Cached Network Image

---

## Project Structure

lib/
- core/
  - auth/
    - auth_service.dart
- domain/
  - entities/
    - channel_entity.dart
- presentation/
  - providers/
    - iptv_providers.dart
  - screens/
    - login_screen.dart
    - home_screen.dart
    - player_screen.dart
    - splash_auth_gate.dart
- firebase_options.dart
- main.dart

---

## Notes

- Some IPTV streams may not work on Flutter Web due to CORS restrictions
- Android provides the best playback experience
- IPTV streams depend on public availability

---

## Legal Notice

- Air Cast does not host or own any TV streams
- All content belongs to their respective owners
- The developer is not responsible for stream availability or legality
- Users are responsible for their own viewing decisions

## License

This project is intended for educational and personal use only.

---

Air Cast – Stream Smart. Stream Secure.
