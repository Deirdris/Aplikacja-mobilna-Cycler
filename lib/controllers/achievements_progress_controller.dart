import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_projekt_inzynierka/data/achievement_data.dart';
import 'package:flutter_projekt_inzynierka/data/achievement_progress_data.dart';
import 'package:flutter_projekt_inzynierka/controllers/async_data_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AchievementsProgressController extends AsyncDataController {


  DocumentReference get achProgDocument => userController.userDoc.collection("achievements").doc("_");

  AchProgress achProgress;

  Future init() async {
    final docSnapshot = await achProgDocument.get();

    if (!docSnapshot.exists) {
      achProgress = AchProgress.empty();

      await achProgDocument.set(achProgress.toFirestore());
    } else {
      achProgress = AchProgress.fromFirestore(docSnapshot);

      }
    }

}



