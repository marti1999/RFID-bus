import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rfid_hackaton/models/favorite_route.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class FavoritesList extends StatefulWidget {
  const FavoritesList({Key? key, required this.title, required this.body, this.FavoritesStops, required this.onFavoriteStopSelected}) : super(key: key);

  final List<FavoriteRoute>? FavoritesStops;
  final String title;
  final Widget body;
  final ValueChanged<FavoriteRoute> onFavoriteStopSelected;

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

    List<Widget> children;

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


    return Scaffold(
      body: Center(
        child: Stack(
          children: children,
        ),
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
      child: buildListView(),
    );
  }

  Widget buildListView(){
    if (widget.FavoritesStops == null || widget.FavoritesStops!.isEmpty) {
      return const Center(
        child: Text('No favorites yet'),
      );
    }
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      itemCount: widget.FavoritesStops!.length,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        final FavoriteRoute item = widget.FavoritesStops![index];

        return ListTile(
          leading: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary,),
          title: Text(item.name!),
          subtitle: Text(item.originBusStop!.stopName + " - " + item.destinationBusStop!.stopName),
          onTap: () {
            _pc.close();
            widget.onFavoriteStopSelected(item);
          },
        );
      },
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


 /* ListTile(
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
  ),*/
}
