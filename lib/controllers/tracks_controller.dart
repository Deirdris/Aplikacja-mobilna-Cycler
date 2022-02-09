import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_projekt_inzynierka/data/user_data.dart';
import 'package:flutter_projekt_inzynierka/data/track_data.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TracksController extends GetxController {
  User user;
  DocumentReference trackDoc;
  Rxn<TrackData> _trackData = Rxn<TrackData>();
  final auth = FirebaseAuth.instance;
  TrackData get trackData => _trackData();
  final tracks = RxList<TrackData>();

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

    FirebaseFirestore.instance.collection("track").get().then((querySnapshot) {

    tracks.addAll(querySnapshot.docs.map((e) => TrackData.fromFirestore(e)));


    });

  }
}
