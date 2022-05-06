import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rfid_hackaton/services/bus_rt_data.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../services/gps_service.dart';
import '../services/map_service.dart';

class BusView extends StatefulWidget {
  const BusView({Key? key, required this.origin, required this.destination, required this.polylines, required this.polylineCoordinates, required this.markers}) : super(key: key);

  final LatLng origin;
  final LatLng destination;
  final List<LatLng> polylineCoordinates;
  final Map<PolylineId, Polyline> polylines;
  final Map<MarkerId, Marker> markers;

  @override
  State<BusView> createState() => _BusViewState();
}

class _BusViewState extends State<BusView> {
  final Completer<GoogleMapController> _controller = Completer();

  final PanelController _pc = PanelController();

  int _polylineIdCounter = 0;

  bool busesSpawned = false;

  void createPolyLine(List<LatLng> points) {
    final int polylineCount = widget.polylines.length;

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

    if (!widget.polylines.containsKey(polylineId)) {
      setState(() {
        widget.polylines[polylineId] = polyline;
      });
    }
  }


  /// This generates a marker for the map.
  Future<void> generateBusMarker(String busId, int busPeopleNumber, LatLng position) async {
    final MarkerId markerId = MarkerId(busId);

    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(12, 12)),
      "assets/bus_icon.png",
    );


    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(
        title: 'Bus $busId',
        snippet: '$busPeopleNumber people',
      ),
      icon: markerbitmap,
      onTap: () {
        print('Marker Tapped');
      },
    );

    setState(() {
      // adding a new marker to map
      widget.markers[markerId] = marker;
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
    LatLng latLng = widget.markers[MarkerId(query)]!.position;

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
  Future<void> moveToPossibleBusLocation(LatLng location) async {
    final GoogleMapController controller = await _controller.future;

    try {
      widget.polylineCoordinates.add(location);

      final cameraUpdate = CameraUpdate.newLatLngZoom(location, 14);

      controller.animateCamera(cameraUpdate);

    } catch (e) {
      MapService().showAlertDialog(context,  'No location found for');
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
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(circularRadius),
      topRight: Radius.circular(circularRadius),
    );

    return SlidingUpPanel(
      renderPanelSheet: false,
      collapsed: buildCollapsed(radius, isExpanded: false),
      panel: buildBottomSheet(radius),
      body: buildGoogleMaps(context, widget.destination, widget.origin),
      borderRadius:  radius,
      controller: _pc,
      maxHeight: MediaQuery.of(context).size.height * 0.55,
      onPanelSlide: (double pos) {
        setState(() {
          circularRadius = 10 + (pos * 10);
        });
      },
    );
  }


  /// Builds the google maps widget
  Widget buildGoogleMaps(BuildContext context , LatLng destination, LatLng origin) {
    CameraPosition cameraPosition = CameraPosition(
      target: origin,
      zoom: 14,
    );

    if (busesSpawned == false) {
      List<BusRtData> busRtData = BusRealtimeData().generateBusRealtimeData(
          widget.origin, widget.destination);

      for (var i = 0; i < busRtData.length; i++) {
        BusRtData busData = busRtData[i];
        generateBusMarker(
            busData.busId, busData.busPeopleNumber, busData.busLocation);
      }

      moveToPossibleBusLocation(busRtData.last.busLocation);

      busesSpawned = true;
    }
    return GoogleMap(
      zoomControlsEnabled: true,
      mapType: MapType.hybrid,
      initialCameraPosition: cameraPosition,
      markers: Set<Marker>.of(widget.markers.values),
      polylines: Set<Polyline>.of(widget.polylines.values),
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
            child: const Text(
              'Choose the best bus route',
              style: TextStyle(
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
            children: const <Widget>[
              SizedBox(height: 10,),
              Text(
                'Choose a bus route',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ),
      ],
    );

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
