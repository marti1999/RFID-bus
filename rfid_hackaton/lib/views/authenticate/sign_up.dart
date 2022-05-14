import 'package:flutter/material.dart';
import 'package:rfid_hackaton/services/auth.dart';
import 'package:rfid_hackaton/shared/constants.dart';
import 'package:rfid_hackaton/shared/loading.dart';
import 'package:firebase_storage/firebase_storage.dart';


class Register extends StatefulWidget {

  final Function toggleView;
  Register({ required this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

   final AuthService _auth = AuthService();
   final _formKey = GlobalKey<FormState>();
   bool loading = false;

   //text field state
  String email = '';
  String passwd = '';
  String name = '';
  String imagePath = 'none';
  String city = 'Barcelona';
  String sex = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading():Scaffold(
          backgroundColor: Colors.brown[100],
          appBar: AppBar(
            backgroundColor: Colors.brown[400],
            elevation: 0.0,
            title: Text('Sign up'),
            actions: <Widget>[
              TextButton.icon(
                  icon: Icon(Icons.person),
                  label: Text('Sign in'),
                  onPressed: () {
                    widget.toggleView();
                  }
              )
            ],
          ),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Form(
              key: _formKey,
              child:Column(
                children: <Widget>[
                  SizedBox(height: 20.0,),
                  TextFormField(
                    // validator: (val) => val!.isEmpty ? 'Enter an Email': null,

                    decoration: textInputDecoration.copyWith(hintText: 'Name'),
                    validator: (val) {
                      if(val != null && val.isEmpty ){
                        return "Enter an Name";
                      }else{
                        return null;
                      }
                    },
                    onChanged: (val){
                      setState(() => name = val);
                    },
                  ),
                  SizedBox(height: 20.0,),
                  TextFormField(
                    // validator: (val) => val!.isEmpty ? 'Enter an Email': null,

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
                  DropdownButtonFormField(
                    value: city,
                      icon: Icon(Icons.arrow_downward),

                      onChanged: (value){
                        setState(() {
                          city = value.toString();
                        });
                      },
                    items: [
                      DropdownMenuItem(child: Text("Barcelona"), value:"Barcelona"),
                      DropdownMenuItem(child: Text("Sabadell"), value:"Sabadell"),
                      DropdownMenuItem(child: Text("San Cugat"), value:"San Cugat"),
                      DropdownMenuItem(child: Text("Terrassa"), value:"Terrassa")
                    ],
                  ),
                  SizedBox(height: 20.0,),
                  ListTile(
                    title: Text("Male"),
                    leading: Radio(
                      value: "Male",
                      groupValue: sex,
                      onChanged: (value) {
                        setState(() {
                          sex = value.toString();
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                  ListTile(
                    title: Text("Female"),
                    leading: Radio(
                      value: "Female",
                      groupValue: sex,
                      onChanged: (value) {
                        setState(() {
                          sex = value.toString();
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                  ListTile(
                    title: Text("Other"),
                    leading: Radio(
                      value: "Other",
                      groupValue: sex,
                      onChanged: (value) {
                        setState(() {
                          sex = value.toString();
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.pink[400],
                    ),
                    child: const Text('Sign up'),
                    onPressed: () async {
                      if(_formKey.currentState!.validate()){
                        setState(() => loading = true);
                        dynamic result = await _auth.registerWithEmailAndPassword(email, passwd, name, imagePath, sex,city);
                        if(result == null){
                          setState(() {
                            error = 'could not sign in with credentials';
                            loading = false;
                          });
                        }
                      }
                    }
                  ),
                  SizedBox(height: 20.0,),
                  Text(
                    error,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0
                    ),
                  ),
                ],
              )
            )
          )
        );
  }
}
