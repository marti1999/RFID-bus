import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusRtData {
  final String busId;
  final String busLine;
  final int busPeopleNumber;
  final double busLatitude;
  final double busLongitude;
  final String busStop;
  final String busNextStop;

  BusRtData({
    required this.busId,
    required this.busLine,
    required this.busPeopleNumber,
    required this.busLatitude,
    required this.busLongitude,
    required this.busStop,
    required this.busNextStop
  });

  BusRtData.fromJson(Map<dynamic, dynamic> json)
      : busId = json['busId'] as String,
        busLine = json['busLine'] as String,
        busPeopleNumber = json['busPeopleNumber'] as int,
        busLatitude = json['busLatitude'] as double,
        busLongitude = json['busLongitude'] as double,
        busStop = json['busStop'] as String,
        busNextStop = json['busNextStop'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'busId': busId,
    'busLine': busLine,
    'busPeopleNumber': busPeopleNumber,
    'busLatitude': busLatitude,
    'busLongitude': busLongitude,
    'busStop': busStop,
    'busNextStop': busNextStop
  };
}
