class BusStop {
  final String stopId;
  final String stopName;
  final double stopLatitude;
  final double stopLongitude;
  final String stopBusAvailableTime;

  BusStop({
    required this.stopId,
    required this.stopName,
    required this.stopLatitude,
    required this.stopLongitude,
    required this.stopBusAvailableTime,
  });

  BusStop.fromJson(Map<dynamic, dynamic> json)
      : stopId = json['stopId'] as String,
        stopName = json['stopName'] as String,
        stopLatitude = json['stopLatitude'] as double,
        stopLongitude = json['stopLongitude'] as double,
        stopBusAvailableTime = json['stopBusAvailableTime'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'stopId': stopId,
    'stopName': stopName,
    'stopLatitude': stopLatitude,
    'stopLongitude': stopLongitude,
    'stopBusAvailableTime': stopBusAvailableTime,
  };

  static BusStop getBusStop(String query, List<BusStop> busStops)  {
    for (BusStop busStop in busStops) {
      if (busStop.stopName == query) {
        return busStop;
      }
    }
    return busStops.first;
  }
}
