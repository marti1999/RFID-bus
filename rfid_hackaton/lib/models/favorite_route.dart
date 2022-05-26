import 'dart:convert';

import 'package:rfid_hackaton/models/bus_stop.dart';

class FavoriteRoute {
  final String? name;
  final BusStop? originBusStop;
  final BusStop? destinationBusStop;


  FavoriteRoute({this.name, this.originBusStop, this.destinationBusStop});

  List<FavoriteRoute> fromJson(List<dynamic> json) {
    List<FavoriteRoute> routes = <FavoriteRoute>[];

    json.forEach((element) {
      routes.add(FavoriteRoute.fromString(element));
    });

    return routes;
  }

  factory FavoriteRoute.fromString(String jsonString) {
    return FavoriteRoute.fromSnapshot(json.decode(jsonString));
  }

  FavoriteRoute.fromSnapshot(Map<String, dynamic> snapshot)
      : name = snapshot['name'],
        originBusStop = BusStop.fromJson(snapshot['originBusStop']),
        destinationBusStop = BusStop.fromJson(snapshot['destinationBusStop']);

  Map<String, dynamic> toJson() => {
    'name': name,
    'originBusStop': originBusStop?.toJson(),
    'destinationBusStop': destinationBusStop?.toJson(),
  };
}
