import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/bus_real_data.dart';


class BusRealtimeData {

  LatLng generateRandomLatLng(LatLng origin, LatLng destination) {
     // generate random latlng between origin and destination in a radius of 500m
    final random = Random();
    const radius = 500;
    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * radius;
    final lat = asin(sin(origin.latitude) * cos(distance) + cos(origin.latitude) * sin(distance) * cos(angle));
    final lng = origin.longitude + atan2(sin(angle) * sin(distance) * cos(origin.latitude), cos(distance) - sin(origin.latitude) * sin(lat));
    return LatLng(lat, lng);
  }

  String randomBusId() {
    // random  bus id using numbers and letters
    String randomBusId = '';
    Random random = Random();
    for (int i = 0; i < 6; i++) {
      int randomInt = random.nextInt(36);
      if (randomInt < 10) {
        randomBusId += randomInt.toString();
      } else {
        randomBusId += String.fromCharCode(randomInt + 87);
      }
    }

    return randomBusId;
  }

  List<BusRtData> generateBusRealtimeData(LatLng origin, LatLng destination) {
     // generate random  buses data
     List<BusRtData> busRtData = [];

     LatLng randomLatLng = generateRandomLatLng(origin, destination);

     for (int i = 0; i < 10; i++) {
       busRtData.add(BusRtData(
         busId: randomBusId(),
         busPeopleNumber: Random().nextInt(100),
         busTime: '${Random().nextInt(24)}:${Random().nextInt(60)}',
         busLatitude: randomLatLng.latitude,
         busLongitude: randomLatLng.longitude,
       ));
     }
     return busRtData;
  }



}