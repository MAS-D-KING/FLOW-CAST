import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/traffic_point.dart';

class ApiService {
  static const String API_BASE = "https://your-api-here";

  static Future<bool> postShareLocation({
    required String userId,
    required double lat,
    required double lng,
    required double speed,
    required DateTime timestamp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/share-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'lat': lat,
          'lng': lng,
          'speed': speed,
          'timestamp': timestamp.toIso8601String(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<TrafficZoneResponse?> fetchTrafficZone(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE/traffic-zone?lat=$lat&lng=$lng'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return TrafficZoneResponse.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}