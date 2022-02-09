import 'dart:async';

import 'package:flutter_projekt_inzynierka/controllers/async_data_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'dart:async';

import 'package:flutter_projekt_inzynierka/controllers/async_data_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:flutter_projekt_inzynierka/data/stats_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StatsController extends AsyncDataController {
  Stats stats;
  final DateTime now = DateTime.now();

  DocumentReference get statsDocument => userController.userDoc.collection("stats").doc("_");

  Future init() async {
    final docSnapshot = await statsDocument.get();
    if (!docSnapshot.exists) {
      stats = Stats.empty();
      stats.docReference = statsDocument;

      await statsDocument.set(stats.toFirestore());
    } else {
      stats = Stats.fromFirestore(docSnapshot);

      if (DateFormat('MMyyyy').format(DateTime.now()) != stats.month) {
        stats
          ..month = DateFormat('MMyyyy').format(DateTime.now())
          ..monthlyStats = StatsEntry.empty();

        await statsDocument.set(stats.toFirestore());
      }

      if (DateTime(now.year, now.month, now.day - (now.weekday - 1)).day.toString() != stats.monday) {
        stats
          ..monday = DateTime(now.year, now.month, now.day - (now.weekday - 1)).day.toString()
          ..weeklyStats = StatsEntry.empty();

        await statsDocument.set(stats.toFirestore());
      }
    }
  }

  Future add(Stats stats) async {
    await statsDocument.set(stats.toFirestore());
    this.stats = stats;
  }
}
