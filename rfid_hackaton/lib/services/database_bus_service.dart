import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
class DatabaseBusService {

  DatabaseBusService();
  // collection reference
  final CollectionReference busLines = FirebaseFirestore.instance.collection('uab_bus_lines');
  final CollectionReference busStops = FirebaseFirestore.instance.collection('uab_bus_stops');

  // 2
  CollectionReference getBusLinesStream() {
    return busLines;
  }

  CollectionReference getBusStopsStream() {
    return busStops;
  }

}