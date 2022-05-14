import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../services/gps_service.dart';

class FavoritesList extends StatefulWidget {
  const FavoritesList({Key? key, required this.title, required this.body}) : super(key: key);

  final String title;
  final Widget body;

  @override
  State<FavoritesList> createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  double circularRadius = 10;
  final PanelController _pc = PanelController();

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      bottomLeft: Radius.circular(circularRadius),
      bottomRight: Radius.circular(circularRadius),
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

            children.add(
                SlidingUpPanel(
                  renderPanelSheet: false,
                  collapsed: buildCollapsed(radius, isExpanded: false),
                  panel: buildBottomSheet(radius),
                  body: widget.body,
                  borderRadius:  radius,
                  controller: _pc,
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                  slideDirection: SlideDirection.DOWN,
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
          );
        },
      ),
    );
  }

  Widget buildBottomSheet(BorderRadiusGeometry radius) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary,),
            title: Text('Santpedor - Manresa'),
            onTap: () {
              _pc.close();
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary,),
            title: Text('RENFE-RECTORAT PER CIÈNCIES - EUREKA - CIÈNCIES I BIOCIÈNCIES'),
            onTap: () {
              _pc.close();
            },
          ),
          ]
      ),
    );
  }

  Widget buildCollapsed(BorderRadiusGeometry radius, { bool isExpanded = false }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: radius,
      ),
      margin: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      height: isExpanded ? 100.0 : 200.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if (isExpanded)
            const Center(
              child: Icon (Icons.keyboard_arrow_up, size: 40, color: Colors.blue,),
            ),
          if (!isExpanded)
            const Center(
              child: Icon (Icons.keyboard_arrow_down, size: 40, color: Colors.blue,),
            ),
          Padding(
            padding:  EdgeInsets.only(left: 16.0, right: 16.0, bottom: (!isExpanded) ?  0.0 : 16.0),
            child:  Text(
              widget.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
