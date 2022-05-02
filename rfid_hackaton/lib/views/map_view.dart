import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  final PanelController _pc = PanelController();

  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 0;

  List<LatLng> polylineCoordinates = [];

  void zoomToPolyline() {
    const double polylineWidth = 10;

    const double edgePadding = polylineWidth * .15;

    LatLngBounds bounds = LatLngBounds(
      southwest: polylineCoordinates.first,
      northeast: polylineCoordinates.last
    );

    CameraUpdate cu = CameraUpdate.newLatLngBounds(bounds, edgePadding);

    _controller.future.then((GoogleMapController controller) {
      controller.animateCamera(cu);
    });
  }

  void createPolyLine(List<LatLng> points) {
    final int polylineCount = polylines.length;

    if (polylineCount == 2) {
      return;
    }

    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';

    _polylineIdCounter++;

    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.orange,
      width: 5,
      points: points,
    );

    if (!polylines.containsKey(polylineId)) {
      setState(() {
        polylines[polylineId] = polyline;
      });
    }
  }

  /// This generates a marker for the map.
  void generateMarker(String address, String title, double lat, double lng) {
    final MarkerId markerId = MarkerId(address);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: '*'),
      onTap: () {
        print('Marker Tapped');
      },
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  /// It hides the panel for some seconds so the user can see the map
  /// and then it shows the panel again

  Future<void> showMarkerAnimation(GoogleMapController controller, String query) async {
    _pc.close();

    // hide keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    // wait for 1 second
    await Future.delayed(const Duration(seconds: 3));
    // then move to the marker
    LatLng latLng = markers[MarkerId(query)]!.position;

    LatLng  offsetLoc = LatLng(latLng.latitude - 0.010, latLng.longitude);

    controller.animateCamera(CameraUpdate.newLatLngZoom(offsetLoc, 14.4746));
    // wait for 1 second
    _pc.open();
  }

  /// This function is called when the user writes a query.
  /// It will call the Google Maps API to get the coordinates of the query.
  /// It will then call the generateMarker function to add a marker to the map.
  /// Finally, it will call the showMarkerAnimation function to animate the camera to the marker.
  /// This function is called when the user writes a query.
  Future<void> moveToPossibleLatLong(String query) async {
    final GoogleMapController controller = await _controller.future;

    try {
      List<Location> locations = await locationFromAddress(query);
      Location location = locations.first;

      polylineCoordinates.add(LatLng(location.latitude, location.longitude));

      generateMarker(query, query, location.latitude, location.longitude);

      final cameraUpdate = CameraUpdate.newLatLngZoom(LatLng(location.latitude, location.longitude), 14);

      controller.animateCamera(cameraUpdate).then((value) =>
        showMarkerAnimation(controller, query));

    } catch (e) {
      showAlertDialog(context,  'No location found for $query');
    }
  }

  String _location = "";
  String _destination = "";

  double circularRadius = 10;

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(circularRadius),
      topRight: Radius.circular(circularRadius),
    );

    return Scaffold(
      body: SlidingUpPanel(
        renderPanelSheet: false,
        collapsed: buildCollapsed(radius, isExpanded: false),
        panel: buildBottomSheet(radius),
        body: buildGoogleMaps(context),
        borderRadius:  radius,
        controller: _pc,
          maxHeight: MediaQuery.of(context).size.height * 0.55,
        onPanelSlide: (double pos) {
          setState(() {
            circularRadius = 10 + (pos * 10);
          });
        },
      ),
    );
  }

  /// Builds the google maps widget
  Widget buildGoogleMaps(BuildContext context) {
    return GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: (LatLng latLng) {
          showAlertDialog(context, latLng.toString());
        },
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


  Widget buildCollapsed(BorderRadiusGeometry radius, { bool isExpanded = false }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: radius,
      ),
      margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
      height: isExpanded ? 100.0 : 200.0,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (!isExpanded)
              const Center(
                child: Icon (Icons.keyboard_arrow_up, size: 40, color: Colors.blue,),
              ),
            if (isExpanded)
              const Center(
                      child: Icon (Icons.keyboard_arrow_down, size: 40, color: Colors.blue,),
              ),
            Padding(
              padding:  EdgeInsets.only(left: 16.0, right: 16.0, bottom: (!isExpanded) ?  0.0 : 16.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget buildBottomSheet(BorderRadiusGeometry radius) {

    FocusNode textSecondFocusNode = new FocusNode();
    FocusNode sendButtonFocusNode = new FocusNode();

    return Column(
      children: <Widget>[
        buildCollapsed(radius, isExpanded: true),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(circularRadius),
                bottomRight: Radius.circular(circularRadius),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 20.0,
                  color: Colors.grey,
                ),
              ]
          ),
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          margin: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          child:
          Column(
            children: <Widget>[
              const SizedBox(height: 10,),
              const Text(
                'Your Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10,),
              TextFormField(
                    cursorHeight: 20,
                    onFieldSubmitted: (String value) {
                      saveLocation(value, true);
                      FocusScope.of(context).requestFocus(textSecondFocusNode);
                    },
                    //controller: TextEditingController(),
                    decoration: buildInputDecoration(),
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
              TextFormField(
                cursorHeight: 20,
                //controller: TextEditingController(text: "UAB Escola d'Enginyeria"),
                decoration: buildInputDecoration(),
                focusNode: textSecondFocusNode,
                onFieldSubmitted: (String value) {
                  saveLocation(value, true);
                  FocusScope.of(context).requestFocus(textSecondFocusNode);
                },
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () {
                  createPolyLine(polylineCoordinates);
                  zoomToPolyline();
                },
                child: const Text('Leets goo'),
                focusNode: sendButtonFocusNode,
              ),
            ],
          ),
        ),
      ],
    );

  }

  void saveLocation(String location, bool isDestination) async {
    if (location.isNotEmpty) {
      moveToPossibleLatLong(location);

      setState(() {
        if (isDestination) {
          _destination = location;
        } else {
          _location = location;
        }
      });
    }
  }

  InputDecoration  buildInputDecoration(){
    return InputDecoration(
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
    );
  }

}
