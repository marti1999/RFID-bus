import 'package:rfid_hackaton/models/favorite_route.dart';

class MyUser {
  final String? uid;
  final String? name;
  final String? email;
  final String? city;
  final num? co2saved;
  final num? km;
  final String? sex;
  final bool? isDarkMode;
  final String? imagePath;
  final int? viatges;
  final List<FavoriteRoute>? favourites;



  MyUser({this.sex,
      this.name,
      this.email,
      this.city,
      this.co2saved,
      required this.km,
      this.isDarkMode,
      this.uid,
      this.imagePath,
      this.viatges,
      this.favourites
  });

  MyUser.fromSnapshot(Map<String, dynamic> snapshot,  { String uid : '' })
      : uid = snapshot['uid'] ?? uid,
        name = snapshot['name'],
        email = snapshot['email'],
        city = snapshot['city'],
        co2saved = snapshot['co2saved'],
        km = snapshot['km'],
        isDarkMode = snapshot['isDarkMode'],
        sex = snapshot['sex'],
        imagePath = snapshot['imagePath'],
        viatges = snapshot['viatges'],
        favourites = FavoriteRoute().fromJson(snapshot['favourites']);
}


