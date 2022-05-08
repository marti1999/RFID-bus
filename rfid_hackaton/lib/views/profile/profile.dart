import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rfid_hackaton/models/my_user.dart';
import 'package:rfid_hackaton/views/profile/utils/user_preferences.dart';
import 'package:rfid_hackaton/views/profile/widgets/appbar_widget.dart';
import 'package:rfid_hackaton/views/profile/widgets/numbers_widget.dart';
import 'package:rfid_hackaton/views/profile/widgets/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = UserPreferences.user;
    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        physics: BouncingScrollPhysics(),
          children: [
            ProfileWidget(
                imagePath: user.imagePath!,
                onClicked: () async{}
            ),
            const SizedBox(height: 24),
            buildName(user),
            NumbersWidget(),
          ],
      )
    );
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