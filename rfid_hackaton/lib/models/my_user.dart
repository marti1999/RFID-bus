class MyUser {
  final String? uid;
  final String? name;
  final String? email;
  final String? city;
  final double? co2saved;
  final int? km;
  final bool? isDarkMode;
  final String? imagePath;

  MyUser({this.name, this.email, this.city, this.co2saved, required this.km, this.isDarkMode, this.uid, this.imagePath});

}