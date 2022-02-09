import 'package:get/get.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
//import 'package:flutter_projekt_inzynierka/data/user_data.dart';

abstract class AsyncDataController extends GetxController {
  String get uid => userController.userDoc.id;

  UserController get userController => Get.find<UserController>();

  //AppUser get appUser => userController.appUser;

  Future _fetchFuture;

  Future get fetchFuture {
    if (!hasFetchFuture) {
      _fetchFuture = init();
    }
    return _fetchFuture;
  }

  bool get hasFetchFuture => _fetchFuture != null;
  //
  // @override
  // void onInit() {
  //   super.onInit();
  //
  //   _fetchFuture = init();
  // }

  Future init();
}
