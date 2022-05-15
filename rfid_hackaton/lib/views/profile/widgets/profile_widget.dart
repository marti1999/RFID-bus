import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key, required this.onClicked}) : super(key: key);
  final VoidCallback onClicked;

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

String _userid = '';
String imageUrl = '';
late Image profilePic;

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return FutureBuilder(
        future: getImageURL(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Stack(
                children: [
                  buildImage(),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: buildEditIcon(color),
                  ),
                ],
              ),
            );
          }else return CircularProgressIndicator();
        });
  }

  Widget buildImage() {
    //TODO change this and get it from storage

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: profilePic.image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          //child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: const Icon(
            Icons.add_a_photo,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
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
