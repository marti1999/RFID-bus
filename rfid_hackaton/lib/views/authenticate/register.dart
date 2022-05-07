import 'package:flutter/material.dart';
import 'package:rfid_hackaton/views/authenticate/sign_in.dart';
import 'package:rfid_hackaton/services/auth.dart';

class Register extends StatefulWidget {

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

   final AuthService _auth = AuthService();

   //text field state
  String email = '';
  String passwd = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.brown[100],
          appBar: AppBar(
            backgroundColor: Colors.brown[400],
            elevation: 0.0,
            title: Text('Sing Up'),
          ),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Form(
              child:Column(
                children: <Widget>[
                  SizedBox(height: 20.0,),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email'
                    ),
                    onChanged: (val){
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(height: 20.0,),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Password'
                    ),
                    onChanged: (val){
                      setState(() => passwd = val);
                    },
                  ),
                  SizedBox(height: 20.0,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.pink[400],
                    ),
                    child: const Text('Sign Up'),
                    onPressed: () async {
                      print(email);
                      print(passwd);
                    },
                  ),
                ],
              )
            )
          )
        );
  }
}
