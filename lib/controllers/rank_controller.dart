import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projekt_inzynierka/controllers/async_data_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:flutter_projekt_inzynierka/data/stats_data.dart';
import 'package:flutter_projekt_inzynierka/data/rank_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RankController extends AsyncDataController {
  Rank ranks;
  User user;
  final auth = FirebaseAuth.instance;
  DocumentReference get rankDocument => FirebaseFirestore.instance.collection("ranking").doc(auth.currentUser.uid);

  Future init() async {
    final docSnapshot = await rankDocument.get();
    if (!docSnapshot.exists) {
      ranks = Rank(
          highestVelocity: 0.0,
          overallDuration: 0,
          overallDistance: 0.0,
          userId: "1",
          userName: "Wa",
          avatarUrl: ""
      );

      await rankDocument.set(ranks.toFirestore());
    } else {
      ranks = Rank.fromFirestore(docSnapshot);


      await rankDocument.set(ranks.toFirestore());
    }

  }

  Future add(Rank ranks) async {
    await rankDocument.set(ranks.toFirestore());
    this.ranks = ranks;
  }
}