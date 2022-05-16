import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


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

}