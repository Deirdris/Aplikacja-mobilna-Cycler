import 'package:flutter_projekt_inzynierka/data/firestore_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackData extends FirestoreDocument {

  TrackData({
    this.name,
    this.distance,
    this.difficult,
    this.time,
    this.description,
    this.photoUrl,
    this.start,
    this.finish,
    this.url
  });


  String name;
  double distance;
  String difficult;
  String time;
  String description;
  String photoUrl;
  String start;
  String finish;
  String url;


  TrackData.from(TrackData other) {
    name = other.name;
    distance = other.distance;
    difficult = other.difficult;
    time = other.time;
    description = other.description;
    photoUrl=other.photoUrl;
    start=other.start;
    finish=other.finish;
    url=other.url;
  }

  TrackData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> docSnapshot) : super(docSnapshot) {
    var data = docSnapshot.data();
    name = data["name"];
    distance = data["distance"];
    difficult = data["difficult"];
    time = data["time"];
    description = data["description"];
    photoUrl=data["photo_url"];
    start=data["start"];
    finish=data["finish"];
    url=data["url"];
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "distance":distance,
      "difficult": difficult,
      "time": time,
      "description": description,
      "photo_url":photoUrl,
      "start":start,
      "finish":finish,
      "url":url

    };
  }
}