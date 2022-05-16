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
  //final int currentStopIndex;

  BusRtData({
    required this.busLineId,
    required this.busLineName,
    required this.busLineNextStop,
    required this.busLineCurrentStop,
    required this.busLinePeopleNumber,
    required this.busLineLatitude,
    required this.busLineLongitude,
    required this.busLineRoute,
  });

  BusRtData.fromJson(Map<dynamic, dynamic> json)
      : busLineId = json['busLineId'] as String,
        busLineName = json['busLineName'] as String,
        busLineNextStop = BusStop.fromJson(json['busLineNextStop']),
        busLineCurrentStop = BusStop.fromJson(json['busLineCurrentStop']),
        busLinePeopleNumber = json['busLinePeopleNumber'] as int,
        busLineLatitude = json['busLineLatitude'] as double,
        busLineLongitude = json['busLineLongitude'] as double,
        busLineRoute = (json['busLineRoute'] as List<dynamic>).cast<String>();
        //currentStopIndex = json['currentStopIndex'] as int;


  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'busLineId': busLineId,
        'busLineName': busLineName,
        'busLineNextStop': busLineNextStop,
        'busLineCurrentStop': busLineCurrentStop,
        'busLinePeopleNumber': busLinePeopleNumber,
        'busLineLatitude': busLineLatitude,
        'busLineLongitude': busLineLongitude,
        'busLineRoute': busLineRoute,
  };
}
