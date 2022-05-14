class BusStop {
  final String stopId;
  final String stopName;
  final double stopLatitude;
  final double stopLongitude;

  BusStop({
    required this.stopId,
    required this.stopName,
    required this.stopLatitude,
    required this.stopLongitude,
  });

  BusStop.fromJson(Map<dynamic, dynamic> json)
      : stopId = json['id'] as String,
        stopName = json['name'] as String,
        stopLatitude = json['lat'] as double,
        stopLongitude = json['lng'] as double;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'id': stopId,
    'name': stopName,
    'lat': stopLatitude,
    'lng': stopLongitude,
  };
}
