import 'package:flutter_projekt_inzynierka/data/firestore_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Rank extends FirestoreDocument {
  Rank({
    this.userId,
    this.userName,
    this.highestVelocity,
    this.overallDuration,
    this.overallDistance,
    this.avatarUrl,
    this.averageVelocity
  });

  double highestVelocity;
  int overallDuration;
  double overallDistance;
  String userId;
  String userName;
  String avatarUrl;
  double averageVelocity;






  Rank.from(Rank other) {
    highestVelocity = other.highestVelocity;
    overallDuration = other.overallDuration;
    overallDistance = other.overallDistance;
    userId = other.userId;
    userName=other.userName;
    avatarUrl=other.avatarUrl;
    averageVelocity=other.averageVelocity;
  }

  Rank.fromFirestore(DocumentSnapshot<Map<String, dynamic>> docSnapshot) : super(docSnapshot) {
    var data = docSnapshot.data();
    highestVelocity = data["highest_velocity"].toDouble();
    overallDuration = data["duration"];
    overallDistance = data["distance"].toDouble();
    userId=data["user_id"];
    userName=data["user_name"];
    avatarUrl=data["avatarUrl"];
    averageVelocity=data["averageVelocity"];
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "highest_velocity": highestVelocity,
      "duration": overallDuration,
      "distance": overallDistance,
      "user_id":userId,
      "user_name":userName,
      "avg_velocity": averageVelocity,
      "avatarUrl": avatarUrl,
    };
  }
}