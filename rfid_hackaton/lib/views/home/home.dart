import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rfid_hackaton/services/auth.dart';
import 'package:rfid_hackaton/views/map_view.dart';
import 'package:rfid_hackaton/views/profile_view.dart';
import 'package:rfid_hackaton/services/database.dart';


class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  int _counter = 0;

  final AuthService _auth = AuthService();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(

      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: const MapView(title: 'New Route',),
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Profile"),
              leading: Icon(Icons.account_circle),
              onTap: (){},
            ),
            ListTile(
              title: Text("add user test"),
              leading: Icon(Icons.create_new_folder),
              onTap: (){
                addUserTest('15', 'marti', 34);
              },
            ),
            ListTile(
              title: Text("log out"),
                leading: Icon(Icons.logout),
              onTap: () async {
                await _auth.signOut();
              },
            ),
            ListTile(
              title: Text("Version App 0.0.1"),

            ),
          ],
        )
    );
  }
}

Future addUserTest(String id, String name, int age) async {
  await DatabaseService(userID: id).updateUserData(name, age);
}