import 'package:flutter/material.dart';
import 'package:rfid_hackaton/views/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // return Home o Authenticate, depenent si està logejat

    return Home(title: 'RFID Bus Tracker') ;
  }
}
