import 'package:firebase_database/firebase_database.dart';

class RealDatabaseService {

  final String userID;

  RealDatabaseService({required this.userID});

  final DatabaseReference _messagesRef = FirebaseDatabase.instance.reference()
      .child('buses');

  Query getBusesData() {
    return _messagesRef;
  }

  Future<void> addMessage(String message) async {
    await _messagesRef.push().set({
      'text': message,
    });
  }
}