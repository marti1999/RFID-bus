import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rfid_hackaton/services/auth.dart';
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
  late RealDatabaseService _dbref;
  String databasejson = "";
  int countvalue =0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dbref
        .getBusesData()
        .onValue
        .listen((event) {
      setState(() {
        databasejson = event.snapshot.value.toString();
        print(databasejson);
        countvalue = countvalue + 1;
      });
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Counter Value: $countvalue"),
      ),
    );
  }

}
