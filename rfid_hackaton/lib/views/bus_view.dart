import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/bus_real_data.dart';
import '../services/gps_service.dart';
import '../services/map_service.dart';
import '../services/realtime_database.dart';

class BusView extends StatefulWidget {
  const BusView({Key? key, required this.title, this.origin, this.destination, this.polylines, this.polylineCoordinates, this.markers, this.destinationName, this.originName}) : super(key: key);

  final String title;
  final LatLng? origin;
  final LatLng? destination;
  final List<LatLng>? polylineCoordinates;
  final Map<PolylineId, Polyline>? polylines;
  final Map<MarkerId, Marker>? markers;

  final String? originName;
  final String? destinationName;

  @override
  State<BusView> createState() => _BusViewState();
}

class _BusViewState extends State<BusView> {
  late RealDatabaseService _dbref;
  Map<int, BusRtData> busRealTimeData = <int, BusRtData>{};

  final Completer<GoogleMapController> _controller = Completer();

  final PanelController _pc = PanelController();

  int _polylineIdCounter = 0;

  int _currentBusIndex = 0;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};

  bool busesSpawned = false;
  bool  _isMapCreated = false;
  bool _followBus = false;

  String _currentBusText = "";

  void createPolyLine(List<LatLng> points) {
    final int polylineCount = polylines.length;

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

    if (polylines.containsKey(polylineId)) {
      setState(() {
        polylines[polylineId] = polyline;
      });
    }
  }

  late BitmapDescriptor myIcon;

  /// This generates a marker for the map.
  Future<void> generateBusMarker(String busId, int busPeopleNumber, double busLatitude, double busLongitude) async {
    LatLng busPosition = LatLng(busLatitude, busLongitude);

    final MarkerId markerId = MarkerId(busId);

    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/bus_icon.png",
    );

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: busPosition,
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
    LatLng latLng = widget.markers![MarkerId(query)]!.position;

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
  Future<void> moveToPossibleBusLocation(int busId, {double zoom = 10.4746}) async {
    if (busRealTimeData != null && busRealTimeData.isNotEmpty) {
      // get the bus location
      BusRtData busRtData = busRealTimeData[busId]!;

      LatLng busPosition = LatLng(busRtData.busLatitude, busRtData.busLongitude);

      _currentBusText = busPosition.toString();
      // get the bus location


      final GoogleMapController controller = await _controller.future;

      try {
        //widget.polylineCoordinates!.add(busPosition);

        //final cameraUpdate = CameraUpdate.newLatLngZoom(busPosition, zoom);

        final cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
          target: busPosition,
          zoom: zoom,
        ));

        controller.animateCamera(cameraUpdate);

      } catch (e) {
        MapService().showAlertDialog(context,  'No location found for');
      }
    }
    else{
      MapService().showAlertDialog(context,  'No buses are available yet!');
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
    // TODO: implement initState
    super.initState();

    if(widget.markers != null){
      widget.markers!.forEach((key, value) {
        markers[key] = value;
      });
    }

    if (widget.polylines != null) {
      widget.polylines!.forEach((key, value) {
        polylines[key] = value;
      });
    }

    _dbref = RealDatabaseService();

    _dbref
        .getBusesData()
        .onValue
        .listen((event) {
      setState(() {
        dynamic buses = event.snapshot.value;

        if (buses != null) {
          int i = 0;
          for (var bus in buses.values) {
            // convert to json
            var busJson = json.encode(bus);
            print(busJson);
            final parsedJson = jsonDecode(busJson);
            BusRtData busData = BusRtData.fromJson(parsedJson);
            busRealTimeData[i] = busData;
            i++;
          }
        }

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(circularRadius),
      topRight: Radius.circular(circularRadius),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: ()=>{
              setState(() {
                _followBus = !_followBus;
              }),
            },
            child: Text(_followBus ? 'Unfollow Bus' : 'Follow Bus'),
          ),
        ],
      ),
      body: SlidingUpPanel(
        renderPanelSheet: false,
        collapsed: buildCollapsed(radius, isExpanded: false),
        panel: buildBottomSheet(radius),
        body: SlidingUpPanel(
          renderPanelSheet: false,
          borderRadius:  radius,
          collapsed: buildTopPart(),
          panel: buildTopPart(),
          body: buildGoogleMaps(context, widget.destination, widget.origin),
          slideDirection: SlideDirection.DOWN,
        ),
        borderRadius:  radius,
        controller: _pc,
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
    );

  }

  Widget buildTopPart() {
    List<Widget> children  = <Widget> [
      Text(
        "Passengers: ${busRealTimeData[_currentBusIndex]?.busPeopleNumber}",
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.orange,
        ),
      ),
      Text(
        "Current Stop: ${busRealTimeData[_currentBusIndex]?.busStop}",
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.orange,
        ),
      ),
      Text(
        "Next Stop: ${busRealTimeData[_currentBusIndex]?.busNextStop}",
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.orange,
        ),
      ),
    ];

    if (widget.originName != null && widget.destinationName != null) {
      children.add(
        const Divider(
          color: Colors.orange,
          thickness: 1,
        )
      );

      children.add(
        Text(
          'From: ${widget.originName}',
          style: TextStyle(fontSize: 20),
        ),
      );

      children.add(
        Text(
          'To: ${widget.destinationName}',
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(circularRadius),
          bottomRight: Radius.circular(circularRadius),
        ),
      ),
      child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

            ],
          )),
    );
  }

  Widget buildBody(BuildContext context , LatLng? destination, LatLng? origin) {
    return Stack(
      children:
      [
        buildGoogleMaps(context, destination, origin),
        Positioned(
          top: 0,
          child:
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(circularRadius),
                bottomRight: Radius.circular(circularRadius),
              ),
            ),
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Passengers: ${busRealTimeData[_currentBusIndex]?.busPeopleNumber}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      "Current Stop: ${busRealTimeData[_currentBusIndex]?.busStop}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      "Next Stop: ${busRealTimeData[_currentBusIndex]?.busNextStop}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      "Current Location: ${busRealTimeData[_currentBusIndex]?.busLatitude}, ${busRealTimeData[_currentBusIndex]?.busLongitude}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      "Co2: ${busRealTimeData[_currentBusIndex]?.busPeopleNumber}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  /// Builds the google maps widget
  Widget buildGoogleMaps(BuildContext context , LatLng? destination, LatLng? origin) {

    CameraPosition cameraPosition = CameraPosition(
      target: origin ?? const LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );

    if (_isMapCreated) {
      for (var busData in busRealTimeData.values) {
        generateBusMarker(
            busData.busId, busData.busPeopleNumber, busData.busLatitude,
            busData.busLongitude);
      }

      if (_followBus) {
        moveToPossibleBusLocation(_currentBusIndex, zoom: 14.4746);
      }
    }




    return GoogleMap(
      zoomControlsEnabled: true,
      mapType: MapType.normal,
      initialCameraPosition: cameraPosition,
      markers: Set<Marker>.of(markers.values),
      polylines: Set<Polyline>.of(polylines.values),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        setState(() {
          _isMapCreated = true;
          moveToPossibleBusLocation(0);
        });
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
              'Your Buses',
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
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 14.0),
          margin: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 14.0),
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children:  <Widget>[
              const SizedBox(height: 10.0),

              if (busRealTimeData.isNotEmpty)
                _itemRow(context),
              if (busRealTimeData.isEmpty)
                const Center(
                  child: Text('No buses found'),
                ),
            ],
          ),
        ),
      ],
    );

  }

  Widget _itemRow(BuildContext context) {
    return SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // button with left arrow
            TextButton(
              onPressed: ()=>{
                setState(() {
                  _currentBusIndex = (_currentBusIndex - 1).clamp(0, busRealTimeData.length - 1);
                }),
                moveToPossibleBusLocation(_currentBusIndex),
              },
              child: const Icon(Icons.arrow_back_ios, size: 30, color: Colors.blue,),
            ),

            _itemBuilder(context, _currentBusIndex),
            // button with right arrow
            TextButton(
              onPressed: ()=>{
                setState(() {
                  _currentBusIndex = (_currentBusIndex + 1).clamp(0, busRealTimeData.length - 1);
                }),

                moveToPossibleBusLocation(_currentBusIndex),
              },
              child: const Icon(Icons.arrow_forward_ios, size: 30, color: Colors.blue,),
            ),
          ],
        )
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return InkWell(
        child: Card(
          elevation: 10,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(circularRadius),
          ),
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Bus ${busRealTimeData[index]!.busLine}",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "Current Location: ${busRealTimeData[_currentBusIndex]?.busLatitude}, ${busRealTimeData[_currentBusIndex]?.busLongitude}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ],
              )


          ),
        ),
        onTap: () {
          // setState(() {
          //   _selectedIndex = index;
          // });
        }
    );
  }

}
