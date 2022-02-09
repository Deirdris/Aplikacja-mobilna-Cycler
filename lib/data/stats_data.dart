import 'package:flutter_projekt_inzynierka/data/firestore_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatsEntry extends FirestoreDocument {
  StatsEntry({
    this.highestVelocity,
    this.overallDuration,
    this.overallDistance,
    this.allBurnedCalories,
  });

  StatsEntry.empty()
      : highestVelocity = 0,
        overallDuration = 0,
        overallDistance = 0,
        allBurnedCalories = 0;

  double highestVelocity;
  int overallDuration;
  double overallDistance;
  double allBurnedCalories;

  double get averageVelocity => overallDuration != 0 ? (overallDistance / (overallDuration / 3600)) : 0.0;

  StatsEntry.fromFirestore(Map<String, dynamic> data) {
    highestVelocity = data["highestVelocity"].toDouble();
    overallDuration = data["overallDuration"];
    overallDistance = data["overallDistance"].toDouble();
    allBurnedCalories = data["allBurnedCalories"].toDouble();
  }

  StatsEntry.from(StatsEntry other) {
    highestVelocity = other.highestVelocity;
    overallDuration = other.overallDuration;
    overallDistance = other.overallDistance;
    allBurnedCalories = other.allBurnedCalories;
  }

  void update({double distance, double calories, double maxVelocity, double duration}) {
    overallDistance = num.parse((overallDistance + distance).toStringAsFixed(1));
    allBurnedCalories = num.parse((allBurnedCalories + calories).toStringAsFixed(1));
    highestVelocity = num.parse((maxVelocity > highestVelocity ? maxVelocity : highestVelocity).toStringAsFixed(1));
    overallDuration = (duration + overallDuration).toInt();
  }

  @override
  Map toFirestore() {
    return {
      "highestVelocity": highestVelocity,
      "overallDuration": overallDuration,
      "overallDistance": overallDistance,
      "allBurnedCalories": allBurnedCalories,
    };
  }
}

class Stats extends FirestoreDocument {
  StatsEntry globalStats;
  int trainingCount;

  StatsEntry monthlyStats;
  String month;

  StatsEntry weeklyStats;
  String monday;

  Stats.empty()
      : globalStats = StatsEntry.empty(),
        monthlyStats = StatsEntry.empty(),
        weeklyStats = StatsEntry.empty(),
        month = DateFormat('MMyyyy').format(DateTime.now()) {
    final now = DateTime.now();
    monday = DateTime(now.year, now.month, now.day - (now.weekday - 1)).day.toString();
    trainingCount = 0;
  }

  Stats.from(Stats other) {
    globalStats = StatsEntry.from(other.globalStats);
    trainingCount = other.trainingCount;

    monthlyStats = StatsEntry.from(other.monthlyStats);
    month = other.month;

    weeklyStats = StatsEntry.from(other.weeklyStats);
    monday = other.monday;
  }

  Stats.fromFirestore(DocumentSnapshot<Map<String, dynamic>> docSnapshot) : super(docSnapshot) {
    var data = docSnapshot.data();
    globalStats = StatsEntry.fromFirestore(data['global']);
    trainingCount = data['global']['trainingCount'];
    //${DateFormat('MMyyyy').format(DateTime.now())}

    monthlyStats = StatsEntry.fromFirestore(data['monthly']);
    month = data['monthly']["month"];

    weeklyStats = StatsEntry.fromFirestore(data['weekly']);
    monday = data['weekly']["monday"];
  }

  void update({double distance, double calories, double maxVelocity, double duration}) {
    globalStats.update(distance: distance, calories: calories, maxVelocity: maxVelocity, duration: duration);
    monthlyStats.update(distance: distance, calories: calories, maxVelocity: maxVelocity, duration: duration);
    weeklyStats.update(distance: distance, calories: calories, maxVelocity: maxVelocity, duration: duration);
    trainingCount++;
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "global":{
        "trainingCount": trainingCount,
        ...globalStats.toFirestore(),
      },
      "monthly": {
        "month": month,
        ...monthlyStats.toFirestore(),
      },
      "weekly": {
        "monday": monday,
        ...weeklyStats.toFirestore(),
      }
    };
  }
}
