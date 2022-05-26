import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rfid_hackaton/models/favorite_route.dart';
import 'package:rfid_hackaton/models/my_user.dart';
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
      'co2saved': 0.0,
      'km': 0.0,
      'isDarkMode': false,
      'imagePath': imagePath,
      'sex':sex,
      'city': city,
      'viatges' : 0,
      'favourites' : [],
      // 'age':15
    });
  }

  Future addFavoriteRouteToUser(FavoriteRoute route) async{

    MyUser user = await getUserByUID(userID);

    if (user.favourites!.isEmpty){
      user.favourites!.add(route);
    }
    else{
      bool exists = false;
      for (var fav in user.favourites!){
        if (fav.originBusStop == route.originBusStop && fav.destinationBusStop == route.destinationBusStop){
          exists = true;
        }
      }
      if (!exists){
        user.favourites!.add(route);
      }
    }

    List<FavoriteRoute> favs = user.favourites!;

    favs.add(route);

    return await userCol.doc(userID).set({
      'favourites' : favs
    });
  }


  Future<MyUser> getUserByUID(String uid) async {
    DocumentSnapshot snapshot =  await userCol.doc(uid).get();
    if(snapshot.exists) {
      MyUser user = MyUser.fromSnapshot(snapshot.data() as Map<String, dynamic>);
      return user;
    }
    throw("ERROR GET USER BY UID - database.dart");

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