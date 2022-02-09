import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_projekt_inzynierka/data/user_data.dart';
import 'package:flutter_projekt_inzynierka/data/track_data.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TrackController extends GetxController {
  User user;
  DocumentReference trackDoc;
  Rxn<TrackData> _trackData = Rxn<TrackData>();
  final auth = FirebaseAuth.instance;
  TrackData get trackData => _trackData();
  //final tracks = RxList<TrackData>();

  set trackData(TrackData val) {
    _trackData.value = val;
  }


  Future fetchFuture;

  @override
  void onInit(){


    fetchTrackData();
    super.onInit();


  }

  Future fetchTrackData() async {
    trackDoc = FirebaseFirestore.instance.collection("track").doc("TligCWSjyy9Xp3Ial5Zz");
    DocumentSnapshot documentSnapshot = await trackDoc.get();

    //FirebaseFirestore.instance.collection("track").get().then((querySnapshot) {
      //querySnapshot.docs.forEach((result) {
       // tracks.addAll(querySnapshot.docs.where((e) => !tracks.any((training) => training.id == e.id)).map((e) => TrackData.fromFirestore(e)));
        //print(result.data());
      //});
    //});
    if (!documentSnapshot.exists) {
      trackData=TrackData(
        name: "g",
        distance: 0,
        difficult: "",
        time: "",
        description: "",

      );




    }
    else {
      trackData =  TrackData.fromFirestore(documentSnapshot);

    }

    }
  }
