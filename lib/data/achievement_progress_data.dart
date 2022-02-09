import 'package:flutter_projekt_inzynierka/data/firestore_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AchProgressEntry extends FirestoreDocument {
  AchProgressEntry({
    this.progress,
    this.stageId,
    this.allCompleted,
  });

  AchProgressEntry.empty()
      : progress = 0,
        stageId = 0,
        allCompleted = false;

  double progress;
  int stageId;
  bool allCompleted;

  AchProgressEntry.fromFirestore(Map<String, dynamic> data) {
    progress = data["progress"].toDouble();
    stageId = data["stageId"];
    allCompleted = data["allCompleted"];
  }

  AchProgressEntry.from(AchProgressEntry other) {
    progress = other.progress;
    stageId = other.stageId;
    allCompleted = other.allCompleted;
  }

  @override
  Map toFirestore() {
    return {
      "progress": progress,
      "stageId": stageId,
      "allCompleted": allCompleted,
    };
  }
}

class AchProgress extends FirestoreDocument {

  AchProgressEntry distance;
  AchProgressEntry speed;
  AchProgressEntry time;
  AchProgressEntry calories;

  AchProgress.empty()
      : distance = AchProgressEntry.empty(),
        speed = AchProgressEntry.empty(),
        time = AchProgressEntry.empty(),
        calories = AchProgressEntry.empty();

  AchProgress.from(AchProgress other) {
    distance = AchProgressEntry.from(other.distance);
    speed = AchProgressEntry.from(other.speed);
    time = AchProgressEntry.from(other.time);
    calories = AchProgressEntry.from(other.calories);

  }

  AchProgress.fromFirestore(DocumentSnapshot<Map<String, dynamic>> docSnapshot) : super(docSnapshot) {
    var data = docSnapshot.data();
    distance = AchProgressEntry.fromFirestore(data['distance']);
    speed = AchProgressEntry.fromFirestore(data['speed']);
    time = AchProgressEntry.fromFirestore(data['time']);
    calories = AchProgressEntry.fromFirestore(data['calories']);
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "distance": distance.toFirestore(),
      "speed": speed.toFirestore(),
      "time": time.toFirestore(),
      "calories": calories.toFirestore(),

    };
  }
}