import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../models/traffic_point.dart';
import '../widgets/forecast_card.dart';
import '../widgets/share_button.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key});

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  // Using free OpenStreetMap tiles - no token required
  
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(37.7749, -122.4194); // Default SF
  List<TrafficPoint> _trafficPoints = [];
  String _forecast = "Loading forecast...";
  bool _isSharing = false;
  Timer? _shareTimer;
  final String _userId = "user123"; // In real app, get from auth

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _shareTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentCenter, 13.0);
      _fetchTrafficZone();
    }
  }

  Future<void> _fetchTrafficZone() async {
    final response = await ApiService.fetchTrafficZone(
      _currentCenter.latitude,
      _currentCenter.longitude,
    );
    
    if (response != null) {
      setState(() {
        _trafficPoints = response.points;
        _forecast = response.forecast;
      });
    } else {
      _showError("Failed to fetch traffic data");
    }
  }

  void _toggleSharing() {
    if (_isSharing) {
      _stopSharing();
    } else {
      _startSharing();
    }
  }

  void _startSharing() {
    setState(() => _isSharing = true);
    _shareTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final speed = LocationService.calculateSpeed(position);
        final success = await ApiService.postShareLocation(
          userId: _userId,
          lat: position.latitude,
          lng: position.longitude,
          speed: speed,
          timestamp: DateTime.now(),
        );
        if (!success) _showError("Failed to share location");
      }
    });
  }

  void _stopSharing() {
    _shareTimer?.cancel();
    setState(() => _isSharing = false);
  }

  void _recenterMap() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      final newCenter = LatLng(position.latitude, position.longitude);
      _mapController.move(newCenter, 13.0);
      setState(() => _currentCenter = newCenter);
      _fetchTrafficZone();
    }
  }

  Color _getTrafficColor(String status) {
    switch (status.toLowerCase()) {
      case 'free': return Colors.green;
      case 'medium': return Colors.orange;
      case 'heavy': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 13.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  _currentCenter = position.center!;
                  _fetchTrafficZone();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flowcast',
              ),
              CircleLayer(
                circles: _trafficPoints.map((point) => CircleMarker(
                  point: LatLng(point.lat, point.lng),
                  color: _getTrafficColor(point.status).withOpacity(0.7),
                  borderColor: _getTrafficColor(point.status),
                  borderStrokeWidth: 2,
                  radius: 8,
                )).toList(),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: ForecastCard(forecast: _forecast),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "recenter",
            onPressed: _recenterMap,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          ShareButton(
            isSharing: _isSharing,
            onPressed: _toggleSharing,
          ),
        ],
      ),
    );
  }
}