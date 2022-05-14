import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:provider/provider.dart';
import 'package:rfid_hackaton/models/my_user.dart';
import 'package:rfid_hackaton/services/auth.dart';
import 'package:rfid_hackaton/views/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAY87vG_P_n9zzGTNOuzVygIbj07FfiZwI",
      appId: "964587985452-udiad96qt2d1e1nmhur4ci4cp0lh4iip.apps.googleusercontent.com",
      messagingSenderId: "Hola",
      projectId: "graphical-bus-348706"
  ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  // utilitzant el stream provider, tot elque penji d'ell teindrà accés
  // al a informació de l'usuari que arriba de la API.
  // Ara mateix s'utilitza per veure si MyUser és null o no, així l'enviem
  // a login o a la pantalla principal
  Widget build(BuildContext context) {
    return StreamProvider<MyUser?>.value(
      catchError: (_,__) {},
      initialData: null,
      value: AuthService().user,
      child:MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        localizationsDelegates: const [
          FormBuilderLocalizations.delegate,
        ],
        darkTheme: ThemeData.dark(),
        home: const Wrapper(),
      ),
    );

  }
}
