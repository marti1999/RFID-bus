import 'package:flutter/material.dart';
import 'package:rfid_hackaton/services/auth.dart';
import 'package:rfid_hackaton/views/authenticate/authenticate.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign in'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: ElevatedButton(
          child: Text('Sign in anonymous'),
          onPressed: () async{
            dynamic result = await _auth.signInAnon();
            if (result == null){
              print('error signing in');
            } else {
              // print('signed in');
              // print(result.uid);
            }
          },
        ),
      )
    );
  }
}