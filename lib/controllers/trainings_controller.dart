import 'dart:async';

import 'package:flutter_projekt_inzynierka/controllers/async_data_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:flutter_projekt_inzynierka/data/training_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TrainingsController extends AsyncDataController {
  //Rxn<List<Training>> _trainings = Rxn<List<Training>>();
  // List<Training> get trainings => _trainings();
  final trainings = RxList<Training>();

  // set trainings(List<Training> val) {
  //   _trainings.value = val;
  // }

  CollectionReference<Map<String, dynamic>> get trainingsCollection => userController.userDoc.collection("trainings");


  Future init() async {
    final querySnapshot = await trainingsCollection.orderBy("dateEnd", descending: true).limit(10).get();
    trainings.addAll(querySnapshot.docs.where((e) => !trainings.any((training) => training.id == e.id)).map((e) => Training.fromFirestore(e)));
  }

  Future loadNext() async{
    final querySnapshot = await trainingsCollection.where("dateEnd", isLessThan: trainings[trainings.length - 1].dateEnd).orderBy("dateEnd", descending: true).limit(10).get();
    trainings.addAll(querySnapshot.docs.where((e) => !trainings.any((training) => training.id == e.id)).map((e) => Training.fromFirestore(e)));
  }

  Future add(Training training) async {
    final trainingReference = await trainingsCollection.add(training.toFirestore());
    training.docReference = trainingReference;
    trainings.insert(0, training);
  }
}