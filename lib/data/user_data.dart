import 'package:flutter_projekt_inzynierka/data/firestore_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData extends FirestoreDocument {

  UserData({
    this.avatarUrl,
    this.name,
    this.surname,
    this.nameNS,
    this.nameSN,
    this.dateOfBirth,
    this.height,
    this.weight,
    this.gender,
    this.isCompleted,
    this.bmiValue,
    this.bmiDescription,
    this.friends,
    this.invites
  });

  String avatarUrl;
  String name;
  String surname;
  String nameNS;
  String nameSN;
  DateTime dateOfBirth;
  int height;
  double weight;
  String gender;
  bool isCompleted;
  double bmiValue;
  String bmiDescription;
  List friends;
  List invites;

  UserData.from(UserData other) {
    avatarUrl = other.avatarUrl;
    name = other.name;
    surname = other.surname;
    nameNS = other.nameNS;
    nameSN = other.nameSN;
    dateOfBirth = other.dateOfBirth;
    height = other.height;
    weight = other.weight;
    gender = other.gender;
    isCompleted = other.isCompleted;
    bmiValue = other.bmiValue;
    bmiDescription = other.bmiDescription;
    friends = other.friends;
    invites = other.invites;
  }

  UserData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> docSnapshot) : super(docSnapshot) {
    var data = docSnapshot.data();
    avatarUrl = data["avatarUrl"];
    name = data["name"];
    surname = data["surname"];
    nameNS = data["nameNS"];
    nameSN = data["nameSN"];
    dateOfBirth = data["dateOfBirth"] != null ? data["dateOfBirth"].toDate() : null;
    height = data["height"];
    weight = data["weight"].toDouble();
    gender = data["gender"];
    isCompleted = data["isCompleted"];
    bmiValue = data["bmiValue"].toDouble();
    bmiDescription = data["bmiDescription"];
    friends = data["friends"];
    invites = data["invites"];
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "avatarUrl": avatarUrl,
      "name": name,
      "surname": surname,
      "nameNS": nameNS,
      "nameSN": nameSN,
      "dateOfBirth": dateOfBirth,
      "height": height,
      "weight": weight,
      "gender": gender,
      "isCompleted": isCompleted,
      "bmiValue": bmiValue,
      "bmiDescription": bmiDescription,
      "friends": friends,
      "invites": invites,
    };
  }
}