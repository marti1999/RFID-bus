import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:rfid_hackaton/models/my_user.dart';
import 'package:rfid_hackaton/views/profile/utils/user_preferences.dart';
import 'package:rfid_hackaton/views/profile/widgets/appbar_widget.dart';
import 'package:rfid_hackaton/views/profile/widgets/numbers_widget.dart';
import 'package:rfid_hackaton/views/profile/widgets/profile_widget.dart';
import 'package:rfid_hackaton/views/profile/profile.dart';
import 'package:rfid_hackaton/views/profile/widgets/textfield_widget.dart';


class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  MyUser user = UserPreferences.user;

  @override
  Widget build(BuildContext context) =>Scaffold(
        appBar: buildAppBar(context),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          physics: BouncingScrollPhysics(),
          children: [
            ProfileWidget(
              imagePath: user.imagePath!,
              isEdit: true,
              onClicked: () async {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Full Name',
              text: user.name!,
              onChanged: (name) {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Email',
              text: user.email!,
              onChanged: (email) {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(              label: 'City',
              text: user.city!,
              maxLines: 5,
              onChanged: (about) {},
            ),
          ],
        ),

  );
}