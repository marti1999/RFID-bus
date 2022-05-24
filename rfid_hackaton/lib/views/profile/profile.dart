import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rfid_hackaton/models/my_user.dart';
import 'package:rfid_hackaton/views/profile/edit_profile_page.dart';
import 'package:rfid_hackaton/views/profile/utils/user_preferences.dart';
import 'package:rfid_hackaton/views/profile/widgets/appbar_widget.dart';
import 'package:rfid_hackaton/views/profile/widgets/numbers_widget.dart';
import 'package:rfid_hackaton/views/profile/widgets/profile_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rfid_hackaton/services/database.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';




class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

String _userid = '';
MyUser _user = MyUser(km: null);

class _ProfilePageState extends State<ProfilePage> {

  RefreshController _refreshController =  RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    //await _getCurrentUser();

    if(mounted)
    setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    //await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if(mounted)
      setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {

            return Scaffold(
                //appBar: buildAppBar(context),
                body: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp:  false,
                  header: WaterDropHeader(),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      SizedBox(height: 70),

                      ProfileWidget(

                          onClicked: () {
                            // Navigator.of(context).push(
                            //     MaterialPageRoute(builder: (context) => EditProfilePage())
                            // );
                          }
                      ),
                      const SizedBox(height: 34),
                      buildName(_user),
                      SizedBox(height: 50),

                      NumbersWidget(co2: _user.co2saved!, km: _user.km!, trips: _user.viatges!,),
                    ],

                )

                )
            );// your widget
        } else return CircularProgressIndicator();
        });

  }
}
Widget buildName(MyUser user) => Column(
  children: [
    Text(
      user.name!,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    ),
    const SizedBox(height: 4),
    Text(
      user.email!,
      style: TextStyle(color: Colors.grey),
    )
  ],
);



Future<String> _getCurrentUser() async{
  final prefs = await SharedPreferences.getInstance();
  _userid = prefs.getString('uid') ?? '';
  _user = await DatabaseService(userID: _userid).getUserByUID(_userid);
  return _userid;
}