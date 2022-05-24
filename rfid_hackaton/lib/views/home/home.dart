import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rfid_hackaton/services/auth.dart';
import 'package:rfid_hackaton/views/feedback/feedback_form.dart';
import 'package:rfid_hackaton/views/map_view.dart';
import 'package:rfid_hackaton/views/profile/test.dart';
import 'package:rfid_hackaton/models/my_user.dart';
import 'package:rfid_hackaton/views/profile/utils/user_preferences.dart';
import 'package:rfid_hackaton/views/profile_view.dart';
import 'package:rfid_hackaton/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rfid_hackaton/views/profile/widgets/profile_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../company/realtime_dashboard.dart';
import '../profile/profile.dart';


class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Home> createState() => _MyHomePageState();
}
String _userid = '';
String imageUrl = '';
MyUser _user = MyUser(km: null);
late Image profilePic;

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
    return FutureBuilder(
        future: _getCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: bodyWidgets[body_widget_index],
              drawer: buildDrawer(context),
            );
          }else return CircularProgressIndicator();
        }
    );

  }

  @override
  Widget buildDrawer(BuildContext context) {
    return Drawer(
        child: ListView(
          children: <Widget>[

            UserAccountsDrawerHeader(
              accountName: Text(_user.name!),
              accountEmail: Text(_user.email!),

              currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.transparent,
                backgroundImage: profilePic.image,
              ),
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
Future<String> _getCurrentUser() async{
  final prefs = await SharedPreferences.getInstance();
  _userid = prefs.getString('uid') ?? '';
  _user = await DatabaseService(userID: _userid).getUserByUID(_userid);
  await getImageURL();
  return _userid;
}

Future<String> getImageURL() async {
  // final gsReference = FirebaseStorage.instance.refFromURL("gs://graphical-bus-348706.appspot.com/YfY0jrDouVVCfkMCl21aOSJvjpf2.jpg");
  // imageUrl = await gsReference.getDownloadURL();
  // final Image image = Image.network(await gsReference.getDownloadURL());
  // return image;

  final prefs = await SharedPreferences.getInstance();
  _userid = prefs.getString('uid') ?? '';

  final ref = FirebaseStorage.instance.ref().child(_userid + '.jpg');
  String a = await ref.getDownloadURL();
  imageUrl = a;

  profilePic = Image.network(a.toString());

  print('puta merda fluter');
  return a;
}

// Future addUserTest(String id, String name, int age) async {
//   await DatabaseService(userID: id).updateUserData(name);
// }