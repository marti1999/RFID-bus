import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusRtData {
  final String busId;
  final int busPeopleNumber;
  final String busTime;
  final double busLatitude;
  final double busLongitude;

  BusRtData({
    required this.busId,
    required this.busPeopleNumber,
    required this.busTime,
    required this.busLatitude,
    required this.busLongitude,
  });

  BusRtData.fromJson(Map<dynamic, dynamic> json)
      : busId = json['busId'] as String,
        busPeopleNumber = json['busPeopleNumber'] as int,
        busTime = json['busTime'] as String,
        busLatitude = json['busLatitude'] as double,
        busLongitude = json['busLongitude'] as double;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'busId': busId,
    'busPeopleNumber': busPeopleNumber,
    'busTime': busTime,
    'busLatitude': busLatitude,
    'busLongitude': busLongitude,
  };
}
