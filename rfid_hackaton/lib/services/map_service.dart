import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'gps_service.dart';

enum MarkerType {
  destination,
  origin,
  bus,
  busStop,
  userLocation,
}


class MapService {



  showAlertDialog(BuildContext context , String message) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () { Navigator.pop(context); },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Error"),
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

  void zoomToMarkers(final Completer<GoogleMapController> _controller, LatLng location1, LatLng location2) async {
    // zoom camera so that location1 and location2 are in the center of the screen
    final GoogleMapController controller = await _controller.future;

    if (location1 != null && location2 != null) {

      if (location1.latitude > location2.latitude && location1.longitude > location2.longitude) {
        controller.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
                northeast: location1,
                southwest: location2
            ),
            100
        ));
      } else {
        controller.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
                northeast: location2,
                southwest: location1
            ),
            100
        ));
      }

    }
  }

  void zoomToPolyline(final Completer<GoogleMapController> _controller, Set<Polyline> p) async {
    /*const double polylineWidth = 10;

  const double edgePadding = polylineWidth * .15;

  if (polylineCoordinates.first.latitude <= polylineCoordinates.last.latitude) {
    final southwest = LatLng(polylineCoordinates.first.latitude - edgePadding, polylineCoordinates.first.longitude - edgePadding);
    final northeast = LatLng(polylineCoordinates.last.latitude + edgePadding, polylineCoordinates.last.longitude + edgePadding);
    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    await _controller.future.then((GoogleMapController controller) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 20));
    });
  } else {
    final southwest = LatLng(polylineCoordinates.last.latitude - edgePadding, polylineCoordinates.last.longitude - edgePadding);
    final northeast = LatLng(polylineCoordinates.first.latitude + edgePadding, polylineCoordinates.first.longitude + edgePadding);
    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    await _controller.future.then((GoogleMapController controller) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 20));
    });
  }*/

    double minLat = p.first.points.first.latitude;
    double minLong = p.first.points.first.longitude;
    double maxLat = p.first.points.first.latitude;
    double maxLong = p.first.points.first.longitude;
    p.forEach((poly) {
      poly.points.forEach((point) {
        if(point.latitude < minLat) minLat = point.latitude;
        if(point.latitude > maxLat) maxLat = point.latitude;
        if(point.longitude < minLong) minLong = point.longitude;
        if(point.longitude > maxLong) maxLong = point.longitude;
      });
    });

    GoogleMapController mapController = await _controller.future;

    mapController.moveCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
        southwest: LatLng(minLat, minLong),
        northeast: LatLng(maxLat,maxLong)
    ), 20));

  }

  bool createPolyLine(List<LatLng> points, Map<PolylineId, Polyline> polylines) {
    final int polylineCount = polylines.length;

    final String polylineIdVal = 'polyline_id_$polylineCount';

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
      polylines[polylineId] = polyline;

      return true;
    }

    return false;
  }

  /// This generates a marker for the map.
  Future<void> generateMarker(String busId, InfoWindow? infoWindow, double markerLatitude, double markerLongitude, MarkerType markerType, Map<MarkerId, Marker> markers) async {
    LatLng markerPosition = LatLng(markerLatitude, markerLongitude);

    final MarkerId markerId = MarkerId(busId);

    // hue red es el tipic de color vermell del google maps
    BitmapDescriptor markerbitmap = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    if (markerType == MarkerType.bus) {
      markerbitmap = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/bus_icon.png",
      );

    } else if (markerType == MarkerType.busStop) {
      markerbitmap = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        "assets/bus_stop_icon.png",
      );
    }
    else if (markerType == MarkerType.origin) {
      markerbitmap = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
    else if (markerType == MarkerType.userLocation) {
      markerbitmap = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: markerPosition,
      infoWindow: infoWindow ?? InfoWindow(title: busId),
      icon: markerbitmap,
      onTap: () {
        print('Marker Tapped');
      },
    );

    markers[markerId] = marker;
  }

  Future<void> updateMapLocation(Function callback, BuildContext context, LatLng? value, final Completer<GoogleMapController> _controller, Map<MarkerId, Marker> markers) async {
    final GoogleMapController controller = await _controller.future;

    try {
      if (value != null) {

        generateMarker('You are here', null, value.latitude, value.longitude, MarkerType.userLocation, markers);

        callback();

        controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(value.latitude, value.longitude), 14.4746)).then((_) async {
          await Future.delayed(Duration(seconds: 1));
          controller.showMarkerInfoWindow(MarkerId('You are here'));
        });

      }else{
        GpsService().determinePosition().then((value) => {
          controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(value.latitude, value.longitude), 14.4746))
        }).then((_) async {
          if (value != null) {
            generateMarker('You are here', null, value.latitude, value.longitude, MarkerType.userLocation, markers);
          }

          callback();

          await Future.delayed(Duration(seconds: 1));
          controller.showMarkerInfoWindow(MarkerId('You are here'));
        });
      }
    } catch (e) {
      MapService().showAlertDialog(context,  'Could not determine your location');
    }
  }
}