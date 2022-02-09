import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_projekt_inzynierka/data/achievement_data.dart';
import 'package:flutter_projekt_inzynierka/data/achievement_progress_data.dart';
import 'package:flutter_projekt_inzynierka/controllers/async_data_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AchievementsInfoController extends AsyncDataController {

  CollectionReference<Map<String, dynamic>> get achDistanceColl => FirebaseFirestore.instance.collection("achievements").doc("distance").collection("_");
  CollectionReference<Map<String, dynamic>> get achSpeedColl => FirebaseFirestore.instance.collection("achievements").doc("speed").collection("_");
  CollectionReference<Map<String, dynamic>> get achTimeColl => FirebaseFirestore.instance.collection("achievements").doc("time").collection("_");
  CollectionReference<Map<String, dynamic>> get achCaloriesColl => FirebaseFirestore.instance.collection("achievements").doc("calories").collection("_");

  final achDistance = RxList<Achievement>();
  final achSpeed = RxList<Achievement>();
  final achTime = RxList<Achievement>();
  final achCalories = RxList<Achievement>();

  Future init() async {

    final querySnapshot1 = await achDistanceColl.orderBy("idAchievement", descending: false).get();
    achDistance.addAll(querySnapshot1.docs.where((e) => !achDistance.any((ach) => ach.id == e.id)).map((e) => Achievement.fromFirestore(e)));

    final querySnapshot2 = await achSpeedColl.orderBy("idAchievement", descending: false).get();
    achSpeed.addAll(querySnapshot2.docs.where((e) => !achSpeed.any((ach) => ach.id == e.id)).map((e) => Achievement.fromFirestore(e)));

    final querySnapshot3 = await achTimeColl.orderBy("idAchievement", descending: false).get();
    achTime.addAll(querySnapshot3.docs.where((e) => !achTime.any((ach) => ach.id == e.id)).map((e) => Achievement.fromFirestore(e)));

    final querySnapshot4 = await achCaloriesColl.orderBy("idAchievement", descending: false).get();
    achCalories.addAll(querySnapshot4.docs.where((e) => !achCalories.any((ach) => ach.id == e.id)).map((e) => Achievement.fromFirestore(e)));

  }
}
