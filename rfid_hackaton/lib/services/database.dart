import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
class DatabaseService {

  final String userID;
  DatabaseService({required this.userID});
  // collection reference
  final CollectionReference userCol = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, int age) async {
    return await userCol.doc(userID).set({
      'name':name,
      'age':age,
    });
  }

}