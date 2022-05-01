import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
  double circularRadius = 10;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (LatLng latLng) {
              showAlertDialog(context, latLng.toString());

              /*setState(() {
                showAlertDialog(context, latLng.toString());
              });*/
            },
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: buildBottomSheet(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToTheLake,
        tooltip: 'Next',
        child: const Icon(Icons.navigate_next),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  showAlertDialog(BuildContext context , String message) {

    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () { Navigator.pop(context); },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("My title"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  Widget buildBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(circularRadius),
            topRight: Radius.circular(circularRadius),
          )
      ),
      height: MediaQuery.of(context).size.height * 0.35,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Your Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              cursorHeight: 20,
              autofocus: false,
              controller: TextEditingController(text: "Our House. In the middle of the street, our house."),
              decoration: InputDecoration(
                hintText: "Enter your Name",
                prefixIcon: const Icon(Icons.location_city),
                contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(circularRadius),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(circularRadius),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  gapPadding: 0.0,
                  borderRadius: BorderRadius.circular(circularRadius),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            const Text(
              'Your destination',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              cursorHeight: 20,
              autofocus: false,
              controller: TextEditingController(text: "UAB Escola d'Enginyeria"),
              decoration: InputDecoration(
                hintText: "Enter your Name",
                prefixIcon: const Icon(Icons.location_city),
                contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(circularRadius),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(circularRadius),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  gapPadding: 0.0,
                  borderRadius: BorderRadius.circular(circularRadius),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
