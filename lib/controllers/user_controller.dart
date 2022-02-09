import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_projekt_inzynierka/data/user_data.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_projekt_inzynierka/data/achievement_progress_data.dart';

class UserController extends GetxController {
  User user;
  DocumentReference userDoc;
  Rxn<UserData> _userData = Rxn<UserData>();
  final auth = FirebaseAuth.instance;
  UserData get userData => _userData();

  set userData(UserData val) {
    _userData.value = val;
  }

  Future fetchFuture;

  @override
  void onInit() {
    super.onInit();


  }

  Future fetchUserData() async {
    //Jak użytkownik nie istnieje to tworzy użytkownika z domyślnymi danymi, jeżeli istnieje to pobiera dane użytkownika
    userDoc = FirebaseFirestore.instance.collection("users").doc(user.uid);
    DocumentSnapshot documentSnapshot = await userDoc.get();
    if (!documentSnapshot.exists) {
      //stworzyc obiekt usera i wrzucic go do bazy

      userData = UserData(
        name: "",
        surname: "",
        nameNS: "",
        nameSN: "",
        dateOfBirth: null,
        height: 0,
        weight: 0,
        gender: "",
        avatarUrl: "",
        isCompleted: false,
        bmiValue: 0,
        bmiDescription: "",
        invites: [],
        friends: []
      );

      await userDoc.set(userData.toFirestore());


    }
    else {
      userData = UserData.fromFirestore(documentSnapshot);

    }
  }

  Future loginUser(String email, String password) async{



    var userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
    userDoc =  FirebaseFirestore.instance.collection('users').doc(userCredential.user.uid);

    DocumentSnapshot documentSnapshot = await userDoc.get();
    userData =  UserData.fromFirestore(documentSnapshot);
  }

  Future registerUser(String email, String password) async{




    var userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    userDoc = FirebaseFirestore.instance.collection('users').doc(userCredential.user.uid);

    DocumentSnapshot documentSnapshot = await userDoc.get();

    if (!documentSnapshot.exists) {
      //stworzyc obiekt usera i wrzucic go do bazy

      userData = UserData(
        name: "",
        surname: "",
        nameNS: "",
        nameSN: "",
        dateOfBirth: null,
        height: 0,
        weight: 0,
        gender: "",
        avatarUrl: "",
        isCompleted: false,
        bmiValue: 0,
        bmiDescription: "",
        invites: [],
        friends: []
      );

      await userDoc.set(userData.toFirestore());


    }
    else {
      userData =  UserData.fromFirestore(documentSnapshot);
    }

  }

  Future logoutUser() async{
    userDoc = null;
    await auth.signOut();
  }

  Future<bool> checkAuthStatus() async {
    //nasluchiwanie czy uzytkownik jest zalogowany
    Completer completer = Completer<bool>();

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!completer.isCompleted) {
        this.user = user;
        if (user != null) await fetchUserData();
        completer.complete(user != null);
      }
    });

    return completer.future;
  }

  Future saveData(UserData userData) async {

    await userDoc.set(userData.toFirestore());
    this.userData = userData;
  }
}

