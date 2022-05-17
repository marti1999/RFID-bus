import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rfid_hackaton/models/bus_real_data.dart';
import 'package:rfid_hackaton/models/bus_stop.dart';
import 'package:rfid_hackaton/services/auth.dart';
import 'package:rfid_hackaton/services/database_bus_service.dart';
import 'package:rfid_hackaton/services/gps_service.dart';
import 'package:rfid_hackaton/views/bus_view.dart';
import 'package:rfid_hackaton/views/map_view.dart';
import 'package:rfid_hackaton/views/profile_view.dart';
import 'package:rfid_hackaton/services/database.dart';

import '../../services/realtime_database.dart';


class RealtimeDashboard extends StatefulWidget {
  const RealtimeDashboard({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<RealtimeDashboard> createState() => _RealtimeDashboardState();
}

class _RealtimeDashboardState extends State<RealtimeDashboard> {
  final DatabaseBusService dbService = DatabaseBusService();
  final Map<String, BusStop> busStops = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    dbService.getBusStopsStream().get().then((value) =>
        value.docs.forEach((doc) =>
            setState(() {
              var map = Map<String, dynamic>.from(doc.data() as Map<dynamic, dynamic>);
              BusStop busStop = BusStop.fromJson(map);

              busStops[busStop.stopId] = busStop;
            })
        )
    );

  }

  @override
  Widget build(BuildContext context) {
    return BusView(title: widget.title, isClient: false, busStops: busStops);
  }



}
