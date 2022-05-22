import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rfid_hackaton/services/auth.dart';
import 'package:rfid_hackaton/views/feedback/feedback_form.dart';
import 'package:rfid_hackaton/views/map_view.dart';
import 'package:rfid_hackaton/views/profile/test.dart';
import 'package:rfid_hackaton/views/profile_view.dart';
import 'package:rfid_hackaton/services/database.dart';

import '../company/realtime_dashboard.dart';
import '../profile/profile.dart';


class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  int _counter = 0;
  List<Widget> bodyWidgets = [MapView(title: 'New Route'), feedbackForm(), ProfilePage(), RealtimeDashboard(title: 'Realtime Dashboard'), HomePage()];
  int body_widget_index = 0;

  final AuthService _auth = AuthService();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: bodyWidgets[body_widget_index],
      drawer: buildDrawer(context),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
        child: ListView(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text("Prueba Prueba"),
              accountEmail: Text("email@prueba.es"),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text("Home"),
              leading: Icon(Icons.home),
              onTap: (){
                setState(() {
                  body_widget_index = 0;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text("Profile"),
              leading: Icon(Icons.account_circle),
              onTap: (){
                setState(() {
                  body_widget_index = 2;
                  Navigator.pop(context);
                });
              },
            ),
            // ListTile(
            //   title: Text("upload image test"),
            //   leading: Icon(Icons.create_new_folder),
            //   onTap: (){
            //     setState(() {
            //       body_widget_index = 4;
            //       Navigator.pop(context);
            //     });
            //   },
            // ),
            ListTile(
              title: Text("Send feedback"),
              leading: Icon(Icons.feedback_outlined),
              onTap: (){
                setState(() {
                  body_widget_index = 1;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text("Realtime (IoT per buseros)"),
              leading: Icon(Icons.add_location),
              onTap: (){
                setState(() {
                  body_widget_index = 3;
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text("Log Out"),
                leading: Icon(Icons.logout),
              onTap: () async {
                await _auth.signOut();
              },
            ),
            const ListTile(
              title: Text("Version App 0.0.1"),
            ),
          ],
        )
    );
  }
}

// Future addUserTest(String id, String name, int age) async {
//   await DatabaseService(userID: id).updateUserData(name);
// }