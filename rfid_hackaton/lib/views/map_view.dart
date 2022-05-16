import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rfid_hackaton/models/bus_stop.dart';
import 'package:rfid_hackaton/services/gps_service.dart';
import 'package:rfid_hackaton/services/realtime_database.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/bus_real_data.dart';
import '../services/database_bus_service.dart';
import '../services/map_service.dart';
import 'bus_view.dart';
import 'favorites_list.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  final DatabaseBusService dbService = DatabaseBusService();

  final Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final PanelController _pc = PanelController();

  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  Map<String, List<LatLng>> polylinesCoords = <String, List<LatLng>>{};
  int _polylineIdCounter = 0;

  List<String> linesToUse = [];
  //List<LatLng> polylineCoordinates = [];

  String _location = "";
  String _destination = "";

  LatLng _currentPosition = LatLng(0, 0);
  LatLng _locationLatLng =  LatLng(0, 0);
  LatLng _destinationLatLng =  LatLng(0, 0);

  BusStop? originBusStop = null;
  BusStop? destinationBusStop = null;

  //bool showBuses = false;
  bool locationSet = false;
  bool destinationSet = false;

  final List<BusStop> _busStops = [];
  final List<BusRtData> _busLines = [];

  List<DropdownMenuItem<String>> get dropdownItems{
    if (_busStops.isEmpty) {
      List<DropdownMenuItem<String>> items = [];
      items.add(const DropdownMenuItem(
        child: Text('No stops found'),
        value: '-1',
      ));
      return items;
    }

    List<DropdownMenuItem<String>> items = [];

    for (BusStop busStop in _busStops) {
      items.add(DropdownMenuItem(
        value: busStop.stopName,
        child: Text(busStop.stopName),
      ));
    }

    return items;
  }

  bool _getPolyline()  {

    BusStop busStopOrigin = getBusStop(_location);
    BusStop busStopDestination = getBusStop(_destination);


    Map<String, List<BusStop>> possibleRoutes =  GpsService().getRouteBetweenCoordinates(busStopOrigin, busStopDestination, _busStops, _busLines);

    if (possibleRoutes.isNotEmpty) {
      for (String route in possibleRoutes.keys) {
        setState(() {
          List<LatLng> routeCoordinates  = [];

          for (int i = 0; i < possibleRoutes[route]!.length; i++) {

            BusStop busStop = possibleRoutes[route]![i];

            LatLng coord = LatLng(busStop.stopLatitude, busStop.stopLongitude);

            generateMarker(route, route, coord.latitude, coord.longitude, false);
            routeCoordinates.add(coord);
          }

          polylinesCoords[route] = routeCoordinates;
          linesToUse.add(route);
          createPolyLine(routeCoordinates);

        });
      }
      return true;
    } else {
      MapService().showAlertDialog(context, 'No route found our route has transfers and are not developed yet');
      return false;
    }

  }

  void createPolyLine(List<LatLng> points) {
    final int polylineCount = polylines.length;

    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';

    _polylineIdCounter++;

    final PolylineId polylineId = PolylineId(polylineIdVal);

    // get the color for the polyline based on the index of the polyline
    final Color color = Color.fromARGB(255, (200 + polylineCount * 50) % 255, (200 + polylineCount * 50) % 255, (200 + polylineCount * 50) % 255);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: color,
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
  Future<void> generateMarker(String address, String title, double lat, double lng, bool isDestination) async {
    final MarkerId markerId = MarkerId(address);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title),
      onTap: () {
        print('Marker Tapped');
      },
      icon: isDestination ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed) : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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

  void genMarkerAndZoom(GoogleMapController controller, String query, LatLng latLng, bool isDestination) {
    // remove old markers
    markers.clear();
    generateMarker(originBusStop!.stopName, originBusStop!.stopName, originBusStop!.stopLatitude, originBusStop!.stopLongitude, isDestination);

    generateMarker(query, query, latLng.latitude, latLng.longitude, isDestination);

    final cameraUpdate = CameraUpdate.newLatLngZoom(LatLng(latLng.latitude, latLng.longitude), 14.4746);

    controller.animateCamera(cameraUpdate).then((value) =>
        showMarkerAnimation(controller, query));
  }

  BusStop getBusStop(String query) {
    for (BusStop busStop in _busStops) {
      if (busStop.stopName == query) {
        return busStop;
      }
    }
    return _busStops.first;
  }

  /// This function is called when the user writes a query.
  /// It will call the Google Maps API to get the coordinates of the query.
  /// It will then call the generateMarker function to add a marker to the map.
  /// Finally, it will call the showMarkerAnimation function to animate the camera to the marker.
  /// This function is called when the user writes a query.
  Future<void> moveToPossibleLatLong(String query, bool isDestination) async {
    final GoogleMapController controller = await _controller.future;

    try {
      if (!isDestination) {
        if (_locationLatLng.latitude != 0 && _locationLatLng.longitude != 0) {
          genMarkerAndZoom(controller, query, _locationLatLng, isDestination);
        }
        else{
          List<Location> locations = await locationFromAddress(query);
          Location location = locations.first;

          _locationLatLng = LatLng(location.latitude, location.longitude);

          genMarkerAndZoom(controller, query, _locationLatLng, isDestination);
        }
      }
      else {
        if (_destinationLatLng.latitude != 0.0 && _destinationLatLng.longitude != 0.0) {
          genMarkerAndZoom(controller, query, _destinationLatLng, isDestination);
        }
        else{
          List<Location> locations = await locationFromAddress(query);
          Location location = locations.first;

          _destinationLatLng = LatLng(location.latitude, location.longitude);

          genMarkerAndZoom(controller, query, _destinationLatLng, isDestination);
        }
      }

    } catch (e) {
      print(e);
      MapService().showAlertDialog(context,  '$query was not found on Google Maps');
    }
  }

  Future<void> updateMapLocation(LatLng? value) async {
    final GoogleMapController controller = await _controller.future;

    try {
      if (value != null) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(value.latitude, value.longitude), 14.4746));
      }else{
        GpsService().determinePosition().then((value) => {
          controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(value.latitude, value.longitude), 14.4746))
        });
      }
    } catch (e) {
      MapService().showAlertDialog(context,  'No location found for');
    }
  }

  double circularRadius = 10;

  String setNearestBusStop()  {
    if (_busStops.isNotEmpty) {
      String locationName  =  GpsService().getNearestBusStop(_currentPosition.latitude, _currentPosition.longitude, _busStops);
      String possibleDestinationName  =  GpsService().getFurtherBusStop(_currentPosition.latitude, _currentPosition.longitude, _busStops);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Nearest bus stop is $locationName'),
        duration: const Duration(milliseconds: 1500),
      ));

      bool savedLocation = saveLocation(locationName, false);
      bool savedDestination = saveLocation(possibleDestinationName, true);


      if (savedLocation && savedDestination) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$locationName was saved'),
          duration: const Duration(milliseconds: 1500),
        ));
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$locationName was not saved'),
          duration: const Duration(milliseconds: 1500),
        ));
      }


    }else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No bus stops found'),
        duration: Duration(milliseconds: 1500),
      ));
    }

    return _location;
  }

  void fillBusLines(DataSnapshot? buses) {
    if (buses != null) {
      for (var bus in buses.value.values)
      {
        // convert to json
        var busJson = json.encode(bus);
        print(busJson);

        final parsedJson = jsonDecode(busJson);
        BusRtData busData = BusRtData.fromJson(parsedJson);
        _busLines.add(busData);

      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (polylines.isNotEmpty) {
      setState(() {
        polylines.clear();
        linesToUse.clear();
      });
    }

    dbService.getBusStopsStream().get().then((value) =>
        value.docs.forEach((doc) =>
            setState(() {
              var map = Map<String, dynamic>.from(doc.data() as Map<dynamic, dynamic>);
              _busStops.add(BusStop.fromJson(map));
              _busStops.sort((a, b) => a.stopName.compareTo(b.stopName));
            })
        )
    );

    RealDatabaseService().getBusesData().get().then((buses) =>
      fillBusLines(buses),
    );

    // aixo es perque es cridi quan sha pintat la pantalla  i per tant ja tenim la posicio
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () => setNearestBusStop());
    });

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

            _currentPosition = LatLng(snapshot.data!.latitude, snapshot.data!.longitude);

            children.add(
                SlidingUpPanel(
                  renderPanelSheet: false,
                  collapsed: buildCollapsed(radius, isExpanded: false),
                  panel: buildBottomSheet(radius),
                  body: FavoritesList(title: 'Your all time favourites', body: buildGoogleMaps(context, _currentPosition)),
                  borderRadius:  radius,
                  controller: _pc,
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                )
            );
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
                updateMapLocation(null);
              },
              child: const Icon(Icons.my_location),
            ),
          );
        },
      ),
    );
  }

  /// Builds the google maps widget
  Widget buildGoogleMaps(BuildContext context, LatLng location) {
    LatLng _currentPosition = const LatLng(0, 0);

    if (location != null && location.latitude != 0 && location.longitude != 0)
    {
      _currentPosition = LatLng(location.latitude, location.longitude);
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

    FocusNode textFirstFocusNode = FocusNode();
    FocusNode textSecondFocusNode = FocusNode();
    FocusNode sendButtonFocusNode = FocusNode();

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
              if (_location == null)
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
              if (_location == null)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                ),
              if (_location != "")
                const Text(
                  'Your Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_location != "")
                const SizedBox(height: 10,),
              if (_location != "")
                DropdownButtonFormField(
                    focusNode: textFirstFocusNode,
                    decoration: buildInputDecoration(),
                    value: _location,
                    validator: (value) => value == null ? "Select a origin" : null,
                    onChanged: (String? newValue){
                      bool saved = saveLocation(newValue!, false);

                      if (saved) {
                        FocusScope.of(context).requestFocus(textSecondFocusNode);
                      }
                      else{
                        FocusScope.of(context).requestFocus(textFirstFocusNode);
                      }
                    },
                    items: dropdownItems
                ),
              if (_destination != "")
                const SizedBox(height: 10,),
              if (_destination != "")
                const Text(
                  'Your destination',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_destination != "")
                const SizedBox(height: 10,),
              if (_destination != "")
                DropdownButtonFormField(
                    focusNode: textSecondFocusNode,
                    decoration: buildInputDecoration(),
                    value: _destination,
                    validator: (value) => value == null ? "Select a destination" : null,
                    onChanged: (String? newValue){
                      bool saved = saveLocation(newValue!, true);

                      if (saved) {
                        FocusScope.of(context).requestFocus(sendButtonFocusNode);
                      }
                      else{
                        FocusScope.of(context).requestFocus(textSecondFocusNode);
                      }
                    },
                    items: dropdownItems
                ),
              if (_destination != "")
                const SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: () {
                    _goToNextScreen();
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

  /* Draws the bus line on the map and goes to the real time buses screen */
  void _goToNextScreen(){

    bool routeFound = _getPolyline();

    if (polylines.isNotEmpty && routeFound) {
      Set<Polyline> polylinesSet = Set<Polyline>.of(
          polylines.values);

      MapService().zoomToPolyline(_controller, polylinesSet);


      // wait for the map to finish rendering
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.push(context, MaterialPageRoute(builder: (
            context) =>
            BusView(title: 'Bus Routes',
              isClient : true,
              origin: originBusStop,
              destination: destinationBusStop,
              polylines: polylines,
              linesToUse: linesToUse,
              markers: markers,),)
        );
      });
    }

  }


  bool saveLocation(String location, bool isDestination)  {
    if (location.isNotEmpty) {
      BusStop busStop = getBusStop(location);

      LatLng latLng = LatLng (busStop.stopLatitude, busStop.stopLongitude);

      if (!isDestination && originBusStop != null && originBusStop!.stopId == busStop.stopId) {
        MapService().showAlertDialog(context, "You can't set the same origin and destination");
        return false;
      }

      if (isDestination && busStop.stopId == originBusStop!.stopId) {
        MapService().showAlertDialog(context, "You can't go to the same stop as the origin");
        return false;
      }

      setState(() {
        if (isDestination) {
          _destination = location;
          _destinationLatLng = latLng;
          destinationSet = true;

          destinationBusStop = busStop;

          polylines.clear();
          linesToUse.clear();
        } else {
          _location = location;
          _locationLatLng = latLng;
          locationSet = true;

          originBusStop = busStop;
        }
      });

      moveToPossibleLatLong(busStop.stopName, isDestination);

      return true;
    }
    else{
      setState(() {
        if (isDestination) {
          _destination = "";
          destinationSet = false;
        } else {
          _location = "";
          locationSet = false;
        }
      });

      MapService().showAlertDialog(context, "Please enter a correct location");

      return false;
    }
  }

  InputDecoration  buildInputDecoration(){
    return InputDecoration(
      //hintText: "Enter a location",
      //prefixIcon: const Icon(Icons.location_city),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(circularRadius),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
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
