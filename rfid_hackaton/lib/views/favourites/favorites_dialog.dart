import 'package:flutter/material.dart';
import 'package:rfid_hackaton/models/bus_stop.dart';
import 'package:rfid_hackaton/models/favorite_route.dart';
import 'package:rfid_hackaton/models/my_user.dart';
import 'package:rfid_hackaton/services/database.dart';
import 'package:rfid_hackaton/services/map_service.dart';

class FavoritesDialog extends StatefulWidget {
  const FavoritesDialog({Key? key, required this.user, required this.origin, required this.destination, required this.scaffoldKey}) : super(key: key);

  final MyUser user;

  final BusStop origin;
  final BusStop destination;

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<FavoritesDialog> createState() => _FavoritesDialogState();
}

class _FavoritesDialogState extends State<FavoritesDialog> {

  final _formKey = GlobalKey<FormState>();

  String _RouteName = "";

  void addFavoriteDialog(){
    showDialog(
        context: widget.scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add favorite'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Enter route name',
                    ),
                    onSaved: (value) {
                      _RouteName = value.toString();
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Add'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.of(context).pop();

                    FavoriteRoute route = FavoriteRoute(
                        originBusStop: widget.origin,
                        destinationBusStop: widget.destination,
                        name: _RouteName);

                    DatabaseService(userID: widget.user.uid!).addFavoriteRouteToUser(route).then(
                            (value) {

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('$_RouteName  was added to favorites'),
                                duration: const Duration(milliseconds: 1500),
                              ));

                        }
                    );
                  }
                },
              ),
            ],
          );
        },
    );

  }

  @override
  Widget build(BuildContext context) {

    return FloatingActionButton(
        onPressed: () {
          addFavoriteDialog();
        },
        child: const Icon(Icons.favorite),
    );

  }


}
