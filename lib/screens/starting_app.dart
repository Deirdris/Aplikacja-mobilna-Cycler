import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:get/get.dart';


class CurrentUserController extends GetxController{

  @override
  void onInit() {
    super.onInit();

    final UserController userController = Get.put(UserController(), permanent: true);

    userController.checkAuthStatus().then((value) {
      if (! value) {
        Get.offNamed('/login');
      } else {
        Get.offNamed('/training');
      }
    });

  }

}


class StartingApp extends StatelessWidget{

  final CurrentUserController controller = Get.put(CurrentUserController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

}