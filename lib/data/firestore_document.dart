import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreDocument {
  FirestoreDocument([DocumentSnapshot docSnapshot]){
    this.docSnapshot = docSnapshot;
    this.docReference = docSnapshot?.reference;
  }

  DocumentSnapshot docSnapshot;

  DocumentReference docReference;

  String get id => docReference.id;

  Map toFirestore();
}