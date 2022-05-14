import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rfid_hackaton/models/bus_stop.dart';

class BusRtData {
  final String busLineId;
  final String busLineName;
  final BusStop busLineNextStop;
  final BusStop busLineCurrentStop;
  final int busLinePeopleNumber;
  final double busLineLatitude;
  final double busLineLongitude;
  final List<String> busLineRoute;
  final int currentStopIndex;

  BusRtData({
    required this.busLineId,
    required this.busLineName,
    required this.busLineNextStop,
    required this.busLineCurrentStop,
    required this.busLinePeopleNumber,
    required this.busLineLatitude,
    required this.busLineLongitude,
    required this.busLineRoute,
    required this.currentStopIndex,
  });

  BusRtData.fromJson(Map<dynamic, dynamic> json)
      : busLineId = json['line_id'] as String,
        busLineName = json['line_name'] as String,
        busLineNextStop = BusStop.fromJson(json['next_stop']),
        busLineCurrentStop = BusStop.fromJson(json['stop']),
        busLinePeopleNumber = json['people_number'] as int,
        busLineLatitude = json['lat'] as double,
        busLineLongitude = json['lng'] as double,
        busLineRoute = (json['stops'] as List<dynamic>).cast<String>(),
        currentStopIndex = json['current_stop_index'] as int;


  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'line_id': busLineId,
    'line_name': busLineName,
    'next_stop': busLineNextStop.toJson(),
    'stop': busLineCurrentStop.toJson(),
    'people_number': busLinePeopleNumber,
    'lat': busLineLatitude,
    'lng': busLineLongitude,
    'stops': busLineRoute,
    'current_stop_index': currentStopIndex,
  };
}
