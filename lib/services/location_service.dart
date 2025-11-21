import 'package:geolocator/geolocator.dart';
import 'dart:math';

class LocationService {
  static Position? _lastPosition;
  static DateTime? _lastTime;

  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  static double calculateSpeed(Position currentPosition) {
    if (_lastPosition == null || _lastTime == null) {
      _lastPosition = currentPosition;
      _lastTime = DateTime.now();
      return 0.0;
    }

    double distance = calculateDistance(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    double timeInSeconds = DateTime.now().difference(_lastTime!).inSeconds.toDouble();
    double speed = timeInSeconds > 0 ? (distance / timeInSeconds) * 3.6 : 0.0; // km/h

    _lastPosition = currentPosition;
    _lastTime = DateTime.now();

    return speed;
  }

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}