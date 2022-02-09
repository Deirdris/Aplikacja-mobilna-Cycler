import 'package:flutter_projekt_inzynierka/data/firestore_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Achievement extends FirestoreDocument {

  Achievement({
    this.idAchievement,
    this.name,
    this.description,
    this.comment,
    this.goal,

  });

  int idAchievement;
  String name;
  String description;
  String comment;
  double goal;

  Achievement.from(Achievement other) {
    idAchievement = other.idAchievement;
    name = other.name;
    description = other.description;
    comment = other.comment;
    goal = other.goal;

  }

  Achievement.fromFirestore(DocumentSnapshot<Map<String, dynamic>> docSnapshot) : super(docSnapshot) {
    var data = docSnapshot.data();
    idAchievement = data["idAchievement"];
    name = data["name"];
    description = data["description"];
    comment = data["comment"];
    goal = data["goal"].toDouble();

  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "idAchievement": idAchievement,
      "name": name,
      "description": description,
      "comment": comment,
      "goal": goal,
    };
  }
}
