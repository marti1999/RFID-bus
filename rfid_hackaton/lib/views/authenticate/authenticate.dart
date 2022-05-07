import 'package:flutter/material.dart';
import 'package:rfid_hackaton/views/authenticate/sign_in.dart';
import 'package:rfid_hackaton/views/authenticate/register.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // child: SignIn(),
      child: Register(),
    );
  }
}
