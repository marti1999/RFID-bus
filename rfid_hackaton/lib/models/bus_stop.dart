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
      : stopId = json['stopId'] as String,
        stopName = json['stopName'] as String,
        stopLatitude = json['stopLatitude'] as double,
        stopLongitude = json['stopLongitude'] as double;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'stopId': stopId,
    'stopName': stopName,
    'stopLatitude': stopLatitude,
    'stopLongitude': stopLongitude,
  };
}
