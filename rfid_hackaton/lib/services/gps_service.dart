import 'dart:math';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rfid_hackaton/models/bus_real_data.dart';
import 'package:rfid_hackaton/models/bus_stop.dart';
import 'package:rfid_hackaton/services/map_service.dart';

class GpsService {
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<String> getLocationAsAddress() async {
    String address = 'no_address';

    Position position = await determinePosition();

    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        address = '${placemark.name}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}';
      }

      return address;
    }
    catch(e){
      print(e);
      return address;
    }
  }

  double deg2rad(double deg) {
    return deg * (pi / 180);
  }

  double rad2deg(double rad) {
    return rad * (180 / pi);
  }

  double getDistance(double lat1, double lon1, double lat2, double lon2) {
    double theta = lon1 - lon2;
    double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
    dist = acos(dist);
    dist = rad2deg(dist);
    dist = dist * 60 * 1.1515;
    return dist;
  }

  String getNearestBusStop(double latitude, double longitude,  List<BusStop> _busStops) {

    String _location = _busStops.first.stopName;
    double minDistance = double.maxFinite;

    // get nearest bus stop
    for (var i = 0; i < _busStops.length; i++) {
      var busStop = _busStops[i];

      var distance = getDistance(latitude, longitude, busStop.stopLatitude, busStop.stopLongitude);

      if (distance < minDistance) {
        _location = busStop.stopName;
        minDistance = distance;
      }
    }

    return _location;
  }


  String getFurtherBusStop(double latitude, double longitude,  List<BusStop> _busStops) {

    String _location = _busStops.first.stopName;
    double maxDistance = 0;

    // get nearest bus stop
    for (var i = 0; i < _busStops.length; i++) {
      var busStop = _busStops[i];

      var distance = getDistance(latitude, longitude, busStop.stopLatitude, busStop.stopLongitude);

      if (distance > maxDistance) {
        _location = busStop.stopName;
        maxDistance = distance;
      }
    }

    return _location;
  }

  BusRtData getBusLineByStopId(String stopId, List<BusRtData> _busRealData) {
    for (var i = 0; i < _busRealData.length; i++) {
      var busLine = _busRealData[i];

      bool stopFound = busLine.busLineRoute.contains(stopId);

      if (stopFound) {
        print(busLine);
        return busLine;
      }
    }

    return _busRealData.first;
  }

  List<BusRtData> getBusLinesByStopId(String stopId, List<BusRtData> _busRealData) {
    List<BusRtData> _busLines = [];

    for (var i = 0; i < _busRealData.length; i++) {
      var busLine = _busRealData[i];

      bool stopFound = busLine.busLineRoute.contains(stopId);

      if (stopFound) {
        _busLines.add(busLine);
      }
    }

    return _busLines;
  }

  void _calculateBusTransfer(Map<String, List<BusStop>> routes, BusStop origin, BusStop destination, List<BusStop> busStops, List<BusRtData> _busLines) {
    // get a bus line where origin is in it and there is a bus stop that
    // allows you to go to anotgher bus line that has the destination

    List<BusRtData> _originPossibleLines = getBusLinesByStopId(origin.stopId, _busLines);

    List<BusRtData> _destinationPossibleLines = getBusLinesByStopId(destination.stopId, _busLines);


    //  find cicles that have the origin and destination
    List<BusRtData> _originDestinationLines = [];


    // find all the lines that have the origin and destination
    for (var i = 0; i < _originPossibleLines.length; i++) {
      var originLine = _originPossibleLines[i];

      for (var j = 0; j < _destinationPossibleLines.length; j++) {
        var destinationLine = _destinationPossibleLines[j];

        // check if originLine.busLineRoute contains any of the destinationLine.busLineRoute
        bool contains = false;

        for (var k = 0; k < destinationLine.busLineRoute.length; k++) {
          var destinationStop = destinationLine.busLineRoute[k];

          if (originLine.busLineRoute.contains(destinationStop)) {
            contains = true;
            break;
          }
        }

        if (contains) {
          _originDestinationLines.add(originLine);
        }
      }
    }

    for (var j = 0; j < _originDestinationLines.length; j++) {
      var busLine = _originDestinationLines[j];

      for (var i = 0; i < busStops.length; i++) {
        BusStop busStop = busStops[i];
        bool busLineFound = busLine.busLineRoute.contains(busStop.stopId);


        if (busLineFound) {
          routes[busLine.busLineId]?.add(
              busStop);
        }
      }
    }

  }

  Map<String, List<BusStop>> getRouteBetweenCoordinates(BusStop origin, BusStop destination, List<BusStop> busStops, List<BusRtData> _busLines) {
    /* With the origin and destination coordinates, and the list of bus stops, we can now find the shortest path between the two points. */

    Map<String, List<BusStop>> routes = <String, List<BusStop>>{};

    List<BusRtData> busLinesCopy  = [..._busLines];

    for (var i = 0; i < _busLines.length; i++) {
      var busLine = _busLines[i];


      bool originFound = busLine.busLineRoute.contains(origin.stopId);
      bool destinationFound = busLine.busLineRoute.contains(destination.stopId);

      if (originFound && destinationFound) {
        routes[busLine.busLineId] = <BusStop>[];
        routes[busLine.busLineId]!.add(origin);
        routes[busLine.busLineId]!.add(destination);
      }else{
        busLinesCopy.remove(busLine);
      }
    }

    if (busLinesCopy.isEmpty) {
      _calculateBusTransfer(routes, origin, destination, busStops, _busLines);
      return routes;
    }else {
      for (var j = 0; j < busLinesCopy.length; j++) {
        var busLine = busLinesCopy[j];

        for (var i = 0; i < busStops.length; i++) {
          BusStop busStop = busStops[i];
          bool busLineFound = busLine.busLineRoute.contains(busStop.stopId);


          if (busLineFound) {
            routes[busLine.busLineId]?.add(
                busStop);
          }
        }
      }
    }
    return  routes;
  }
}
