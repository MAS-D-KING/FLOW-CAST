class TrafficPoint {
  final double lat;
  final double lng;
  final String status;
  final String roadId;

  TrafficPoint({
    required this.lat,
    required this.lng,
    required this.status,
    required this.roadId,
  });

  factory TrafficPoint.fromJson(Map<String, dynamic> json) {
    return TrafficPoint(
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'free',
      roadId: json['roadId'] ?? '',
    );
  }
}

class TrafficZoneResponse {
  final List<TrafficPoint> points;
  final String forecast;

  TrafficZoneResponse({
    required this.points,
    required this.forecast,
  });

  factory TrafficZoneResponse.fromJson(Map<String, dynamic> json) {
    return TrafficZoneResponse(
      points: (json['points'] as List?)
          ?.map((p) => TrafficPoint.fromJson(p))
          .toList() ?? [],
      forecast: json['forecast'] ?? 'No forecast available',
    );
  }
}