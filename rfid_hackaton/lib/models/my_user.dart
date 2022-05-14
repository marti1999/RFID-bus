class MyUser {
  final String? uid;
  final String? name;
  final String? email;
  final String? city;
  final double? co2saved;
  final num? km;
  final String? sex;
  final bool? isDarkMode;
  final String? imagePath;

  MyUser({this.sex,
      this.name,
      this.email,
      this.city,
      this.co2saved,
      required this.km,
      this.isDarkMode,
      this.uid,
      this.imagePath});

  MyUser.fromSnapshot(Map<String, dynamic> snapshot)
      : uid = snapshot['uid'],
        name = snapshot['name'],
        email = snapshot['email'],
        city = snapshot['city'],
        co2saved = snapshot['co2saved'],
        km = snapshot['km'],
        isDarkMode = snapshot['isDarkMode'],
        sex = snapshot['sex'],
        imagePath = snapshot['imagePath'];
}
