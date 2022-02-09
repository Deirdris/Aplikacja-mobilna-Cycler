
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MySnackbar extends GetBar{
  MySnackbar({message}): super(
    message: message,
    backgroundColor: Theme.of(Get.context).colorScheme.primary,
    animationDuration: 250.milliseconds,
    duration: 2.seconds,
    onTap: (GetBar snackbar) => Get.back(),
  );
}