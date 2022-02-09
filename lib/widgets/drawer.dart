import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_projekt_inzynierka/controllers/achievements_info_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/achievements_progress_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/rank_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/stats_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/trainings_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_projekt_inzynierka/methods/get_avatar.dart';

class CustomDrawer extends StatelessWidget {
  final auth = FirebaseAuth.instance;

  UserController get userController => Get.find<UserController>();

  Future<List> futureWait() async {
    return Future.wait([
      Future(() => userController.logoutUser()),
      Future(() => Get.delete<UserController>(force: true)),
      Future(() => Get.delete<TrainingsController>(force: true)),
      Future(() => Get.delete<AchievementsProgressController>(force: true)),
      Future(() => Get.delete<AchievementsInfoController>(force: true)),
      Future(() => Get.delete<RankController>(force: true)),
      Future(() => Get.delete<StatsController>(force: true)),
      Future(() => Get.offNamed('/login')),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
            bodyText1: TextStyle(
              fontSize: 18,
              color: Color(0xFFcfd1e3),
            ),
            subtitle1: TextStyle(
              fontSize: 18,
            ),
          ),
          iconTheme: IconThemeData(size: 32),
        ),
        child: ListTileTheme(
          iconColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: getAvatar(userController.userData.avatarUrl),
                      imageBuilder: (context, imageProvider) => Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                          border: Border.all(
                            color: Color(0xFF24223B),
                            width: 4.0,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                          width: 115,
                          height: 115,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          )),
                      errorWidget: (context, url, error) => Container(
                          width: 115, height: 115, child: Icon(Icons.error)),
                    ),
                    Text(
                      userController.userData.name != "" ? userController.userData.name+" "+userController.userData.surname : auth.currentUser.email,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Konto'),
                onTap: () async {
                  try {
                    Get.toNamed('/account');
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.pedal_bike),
                title: Text('Trening'),
                onTap: () => Get.offNamed('/training'),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Historia treningów'),
                onTap: () => Get.offNamed('/history'),
              ),
              ListTile(
                leading: Icon(Icons.query_stats),
                title: Text('Statystyki'),
                onTap: () {
                  Get.offNamed('/stats');
                },
              ),
              ListTile(
                leading: Icon(Icons.emoji_events),
                title: Text('Osiągnięcia'),
                onTap: () {
                  Get.offNamed('/achievements');

                },
              ),
              ListTile(
                leading: Icon(Icons.location_on_outlined),
                title: Text('Trasy treningowe'),
                onTap: () async{
                  try {
                    Get.toNamed('/tracks');
                  }
                  catch(e){
                    print(e);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Wyloguj'),
                onTap: () async {
                  try {
                    futureWait();
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}