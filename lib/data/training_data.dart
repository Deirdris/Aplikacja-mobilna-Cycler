import 'package:flutter_projekt_inzynierka/data/firestore_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Training extends FirestoreDocument {
  Training({
    this.averageVelocity,
    this.duration,
    this.dateEnd,
    this.dateStart,
    this.distance,
    this.calories,
    this.name,
    this.positionsDB,
  });

  double averageVelocity;
  String duration;
  DateTime dateEnd;
  DateTime dateStart;
  double distance;
  double calories;
  String name;
  List positionsDB;

  Training.from(Training other) {
    averageVelocity = other.averageVelocity;
    duration = other.duration;
    dateEnd = other.dateEnd;
    dateStart = other.dateStart;
    distance = other.distance;
    calories = other.calories;
    name = other.name;
    positionsDB = other.positionsDB;
  }

  Training.fromFirestore(DocumentSnapshot<Map<String, dynamic>> docSnapshot) : super(docSnapshot) {
    var data = docSnapshot.data();
    averageVelocity = data["averageVelocity"].toDouble();
    duration = data["duration"];
    dateEnd = data["dateEnd"].toDate();
    dateStart = data["dateStart"].toDate();
    distance = data["distance"].toDouble();
    calories = data["calories"].toDouble();
    name = data["name"];
    positionsDB = data["positionsDB"];
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "averageVelocity": averageVelocity,
      "duration": duration,
      "dateEnd": dateEnd,
      "dateStart": dateStart,
      "distance": distance,
      "calories": calories,
      "name": name,
      "positionsDB": positionsDB,
    };
  }
}