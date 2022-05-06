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

void zoomToPolyline(final Completer<GoogleMapController> _controller, List<LatLng> polylineCoordinates) async {
  const double polylineWidth = 10;

  const double edgePadding = polylineWidth * .15;

  if (polylineCoordinates.first.latitude <= polylineCoordinates.last.latitude) {
    final southwest = LatLng(polylineCoordinates.first.latitude - edgePadding, polylineCoordinates.first.longitude - edgePadding);
    final northeast = LatLng(polylineCoordinates.last.latitude + edgePadding, polylineCoordinates.last.longitude + edgePadding);
    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    await _controller.future.then((GoogleMapController controller) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 10));
    });
  } else {
    final southwest = LatLng(polylineCoordinates.last.latitude - edgePadding, polylineCoordinates.last.longitude - edgePadding);
    final northeast = LatLng(polylineCoordinates.first.latitude + edgePadding, polylineCoordinates.first.longitude + edgePadding);
    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    await _controller.future.then((GoogleMapController controller) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 10));
    });
  }
}

}