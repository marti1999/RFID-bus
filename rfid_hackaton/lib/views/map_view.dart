import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rfid_hackaton/services/gps_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/bus_real_data.dart';
import '../services/map_service.dart';
import '../services/realtime_database.dart';
import 'bus_view.dart';
import 'favorites_list.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {


  final Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final PanelController _pc = PanelController();

  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 0;

  List<LatLng> polylineCoordinates = [];

  String _location = 'Unknown';
  String _destination = 'Unknown';

  LatLng _locationLatLng = const LatLng(0, 0);
  LatLng _destinationLatLng = const LatLng(0, 0);

  bool showBuses = false;

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
  /// and then it As the panel again

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

      if (polylineCoordinates.isNotEmpty && polylineCoordinates.length > 1) {
        _destinationLatLng = LatLng(location.latitude, location.longitude);
      }else{
        _locationLatLng = LatLng(location.latitude, location.longitude);
      }

      polylineCoordinates.add(LatLng(location.latitude, location.longitude));

      generateMarker(query, query, location.latitude, location.longitude);

      final cameraUpdate = CameraUpdate.newLatLngZoom(LatLng(location.latitude, location.longitude), 14);

      controller.animateCamera(cameraUpdate).then((value) =>
        showMarkerAnimation(controller, query));

    } catch (e) {
      MapService().showAlertDialog(context,  'No location found for $query');
    }
  }

  Future<void> updateMapLocation() async {
    final GoogleMapController controller = await _controller.future;

    try {
      GpsService().determinePosition().then((value) => {
        controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(value.latitude, value.longitude), 14))
      });

    } catch (e) {
      MapService().showAlertDialog(context,  'No location found for');
    }
  }

  double circularRadius = 10;

  @override
  void initState() {
    super.initState();

    GpsService().getLocationAsAddress().then((value) =>
        setState(() {
          _location = value;
        })
    );
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(circularRadius),
      topRight: Radius.circular(circularRadius),
    );


    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2!,
      textAlign: TextAlign.center,
      child: FutureBuilder<Position>(
        future: GpsService().determinePosition(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
              children = <Widget>[];
              /*if (showBuses){

                children.add(

                );
              }else{*/
                children.add(
                    SlidingUpPanel(
                      renderPanelSheet: false,
                      collapsed: buildCollapsed(radius, isExpanded: false),
                      panel: buildBottomSheet(radius),
                      body: FavoritesList(title: 'Your all time favourites', body:buildGoogleMaps(context, snapshot.data)),
                      borderRadius:  radius,
                      controller: _pc,
                      maxHeight: MediaQuery.of(context).size.height * 0.55,
                      onPanelSlide: (double pos) {
                        setState(() {
                          circularRadius = 10 + (pos * 10);
                        }
                        );
                      },
                    )
                );

              //}
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          return Scaffold(
            body: Center(
              child: Stack(
              children: children,
            ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                updateMapLocation();
              },
              child: const Icon(Icons.my_location),
            ),
          );
        },
      ),
    );
  }



  /// Builds the google maps widget
  Widget buildGoogleMaps(BuildContext context , Position? position) {
    LatLng _currentPosition = const LatLng(0, 0);

    if (position != null) {
      _currentPosition = LatLng(position.latitude, position.longitude);
    }

    CameraPosition _kGooglePlex = CameraPosition(
      target: _currentPosition,
      zoom: 14.4746,
    );

    return GoogleMap(
      zoomControlsEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: (LatLng latLng) {
          MapService().showAlertDialog(context, latLng.toString());
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
                      saveLocation(value, false);
                      FocusScope.of(context).requestFocus(textSecondFocusNode);
                    },
                    controller: TextEditingController(text: _location),
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
                  MapService().zoomToPolyline(_controller, polylineCoordinates);
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                       BusView(title: 'Bus Routes',
                         polylineCoordinates: polylineCoordinates,
                         destination: _destinationLatLng,
                         origin: _locationLatLng,
                         destinationName: _destination,
                          originName: _location,
                         polylines : polylines,
                         markers: markers,),));
                  // setState(() {
                  //   showBuses = true;
                  // });
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
