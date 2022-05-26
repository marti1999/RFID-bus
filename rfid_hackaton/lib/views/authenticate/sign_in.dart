import 'package:flutter/material.dart';
import 'package:rfid_hackaton/services/auth.dart';
import 'package:rfid_hackaton/shared/constants.dart';
import 'package:rfid_hackaton/shared/loading.dart';

import '../company/realtime_dashboard.dart';

class SignIn extends StatefulWidget {
  // const SignIn({Key? key}) : super(key: key);

  final Function toggleView;
  SignIn({ required this.toggleView });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String email = '';
  String passwd = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading():Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text('Sign In'),
        actions: <Widget>[
          TextButton.icon(
              icon: Icon(Icons.person),
              label: Text('Register'),
              onPressed: () {
                widget.toggleView();
              }
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Stack(
              children: <Widget>[
                  Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Form(
                    key: _formKey,
                    child:Column(
                      children: <Widget>[
                        SizedBox(height: 20.0,),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(hintText: 'Email'),
                          validator: (val) {
                            if(val != null && val.isEmpty ){
                              return "Enter an Email";
                            }else{
                              return null;
                            }
                          },
                          onChanged: (val){
                            setState(() => email = val);
                          },
                        ),
                        SizedBox(height: 20.0,),
                        TextFormField(
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(hintText: 'Password'),
                          validator: (val) {
                            if (val!.length < 6) {
                              return 'Enter an password 6+ chars long';
                            }
                            else {
                              return null;
                            }

                          },
                          onChanged: (val){
                            setState(() => passwd = val);
                          },
                        ),
                        SizedBox(height: 20.0,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.pink[400],
                          ),
                          child: const Text('Sign in'),
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              setState(() => loading = true);
                              dynamic result = await _auth.signInWithEmailAndPassword(email, passwd);
                              if(result == null){
                                setState(() {
                                  error = 'could not sign in with credentials';
                                  loading = false;
                                });
                              }
                            }
                          },
                        ),
                        SizedBox(height: 20.0,),
                        Text(
                          error,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.0
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          child: Text('Realtime (IoT per buseros)'),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RealtimeDashboard(title: 'IoT Bus Company',)));
                          },
                        ),
                      ],
                    )
                  )
                )
      ]))
    );
  }
}
