import 'package:firebase_database/firebase_database.dart';

class RealDatabaseService {

  final DatabaseReference _messagesRef = FirebaseDatabase(databaseURL: 'https://graphical-bus-348706-default-rtdb.europe-west1.firebasedatabase.app/').reference().child('buses');

  Query getBusesData()
  {
    return _messagesRef;
  }

  Future<void> addMessage(String message) async {
    await _messagesRef.push().set({
      'text': message,
    });
  }


}