import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
class DatabaseService {

  final String userID;
  DatabaseService({required this.userID});
  // collection reference
  final CollectionReference userCol = FirebaseFirestore.instance.collection('users');
  final CollectionReference feedbackCol = FirebaseFirestore.instance.collection('feedback');

  Future updateUserData(String email, String name, String imagePath, String sex, String city) async {
    return await userCol.doc(userID).set({
      'email':email,
      'name': name,
      'co2': 0.0,
      'km': 0.0,
      'darkMode': false,
      'imagePath': imagePath,
      'sex':sex,
      'city': city
      // 'age':15
    });
  }


  Future updateFeedback(GlobalKey<FormBuilderState> _formKey) async{
    return await feedbackCol.doc().set({
      'userID': userID,
      'name': _formKey.currentState?.value['name'],
      'email': _formKey.currentState?.value['email'],
      'type': _formKey.currentState?.value['type'],
      'message': _formKey.currentState?.value['message']

    });
  }

}