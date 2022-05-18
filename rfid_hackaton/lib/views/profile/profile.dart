import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rfid_hackaton/models/my_user.dart';
import 'package:rfid_hackaton/views/profile/edit_profile_page.dart';
import 'package:rfid_hackaton/views/profile/utils/user_preferences.dart';
import 'package:rfid_hackaton/views/profile/widgets/appbar_widget.dart';
import 'package:rfid_hackaton/views/profile/widgets/numbers_widget.dart';
import 'package:rfid_hackaton/views/profile/widgets/profile_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rfid_hackaton/services/database.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

String _userid = '';
MyUser _user = MyUser(km: null);

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {


            return Scaffold(
                appBar: buildAppBar(context),
                body: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    ProfileWidget(

                        onClicked: () {
                          // Navigator.of(context).push(
                          //     MaterialPageRoute(builder: (context) => EditProfilePage())
                          // );
                        }
                    ),
                    const SizedBox(height: 24),
                    buildName(_user),
                    NumbersWidget(co2: _user.co2saved!, km: _user.km!, trips: _user.viatges!,),
                  ],
                )
            );// your widget
        } else return CircularProgressIndicator();
        });

  }
}
Widget buildName(MyUser user) => Column(
  children: [
    Text(
      user.name!,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    ),
    const SizedBox(height: 4),
    Text(
      user.email!,
      style: TextStyle(color: Colors.grey),
    )
  ],
);



Future<String> _getCurrentUser() async{
  final prefs = await SharedPreferences.getInstance();
  _userid = prefs.getString('uid') ?? '';
  _user = await DatabaseService(userID: _userid).getUserByUID(_userid);
  return _userid;
}