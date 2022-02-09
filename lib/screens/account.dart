import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:flutter_projekt_inzynierka/data/user_data.dart';
import 'package:get/get.dart';
import '../widgets/scaffold.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_projekt_inzynierka/methods/format_number.dart';
import 'package:flutter_projekt_inzynierka/methods/get_avatar.dart';

class AccountPage extends StatelessWidget {
  final UserController userController = Get.find<UserController>();
  final auth = FirebaseAuth.instance;

  Widget _buildAvatar() {
    return Column(children: <Widget>[
      CachedNetworkImage(
        imageUrl: getAvatar(userController.userData.avatarUrl),
        imageBuilder: (context, imageProvider) => Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            border: Border.all(
              color: Color(0xFF24223B),
              width: 4.0,
            ),
          ),
        ),
        placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            )),
        errorWidget: (context, url, error) =>
            Container(width: 200, height: 200, child: Icon(Icons.error)),
      ),
      SizedBox(height: 5),
      /*Text(auth.currentUser.email,
          style: TextStyle(
              color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 20),*/
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context)
            .copyWith(scaffoldBackgroundColor: Theme.of(context).cardColor),
        child: CustomScaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text("Konto"),
            ),
            body: Obx(() => SingleChildScrollView(
                child: Container(
                  //margin:
                  //    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),

                  child: userController.userData.isCompleted
                      ? Column(
                    children: <Widget>[
                      Container(

                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: double.infinity,
                          child: Column(children: <Widget>[
                            SizedBox(height: 10),
                            _buildAvatar(),
                            SizedBox(height: 5),
                            Text(userController.userData.name+" "+userController.userData.surname,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 15),
                          ])),
                      Container(

                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 20.0),child: Column(
                        children: <Widget>[
                          Row(children: <Widget>[
                            Icon(
                              Icons.email_rounded,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(width: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "E-mail:",
                                style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14),
                              ),
                            ),
                          ]),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              auth.currentUser.email,
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 5),
                          Divider(color: Theme.of(context).hintColor,),
                          SizedBox(height: 5),
                          Row(children: <Widget>[
                            Icon(
                              Icons.cake_rounded,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(width: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Data urodzenia:",
                                style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14),
                              ),
                            ),
                          ]),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              DateFormat('dd.MM.yyyy').format(
                                      userController.userData.dateOfBirth) +
                                  "r.",
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 5),
                          Divider(color:Theme.of(context).hintColor,),
                          SizedBox(height: 5),
                          Row(children: <Widget>[
                            Icon(
                              Icons.height,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(width: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Wzrost:",
                                style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14),
                              ),
                            ),
                          ]),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userController.userData.height.toString() +
                                  " cm",
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 5),
                          Divider(color: Theme.of(context).hintColor,),
                          SizedBox(height: 5),
                          Row(children: <Widget>[
                            Icon(
                              Icons.monitor_weight_outlined,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(width: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Waga:",
                                style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14),
                              ),
                            ),
                          ]),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formatNumber(userController.userData.weight) + " kg",
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 5),
                          Divider(color: Theme.of(context).hintColor,),
                          SizedBox(height: 5),
                          Row(children: <Widget>[
                            Icon(
                              Icons.wc,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(width: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Płeć:",
                                style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14),
                              ),
                            ),
                          ]),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userController.userData.gender,
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 5),
                          Divider(color: Theme.of(context).hintColor),
                          SizedBox(height: 5),
                          Row(children: <Widget>[
                            Icon(
                              Icons.emoji_people,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(width: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "BMI:",
                                style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14),
                              ),
                            ),
                          ]),

                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userController.userData.bmiDescription+" ("+formatNumber(userController.userData.bmiValue)+")",
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 40),
                                primary: Theme.of(context).scaffoldBackgroundColor
                            ),
                            child: Text(
                              "Edytuj",
                              style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 18
                              ),
                            ),
                            onPressed: () {
                              Get.toNamed("/edit_account");
                            },
                          ),
                        ],),)
                    ],
                  )
                      : Column(
                    children: <Widget>[
                      Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: double.infinity,
                        child: Column(children: <Widget>[
                          SizedBox(height: 10),
                          _buildAvatar(),
                          Text("Szanowny użytkowniku",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text(auth.currentUser.email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 20),
                        ]),
                      ),
                      Container(

                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 20.0),
                        child: Column(children: [
                          SizedBox(height: 20),
                          Text(
                              'Aby korzystać z zakładki "Konto", wymagane jest uzupełnienie informacji o sobie.\n\nKliknięcie w przycisk "Uzupełnij informacje" przekieruje do odpowiedniego formularza.',
                              style: TextStyle(
                                fontSize: 22,
                              ),
                              textAlign: TextAlign.center),
                        ]),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40.0, vertical: 20.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 40),
                                    primary: Theme.of(context).scaffoldBackgroundColor
                                ),
                                child: Text(
                                  "Uzupełnij informacje",
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  Get.toNamed("/edit_account");
                                },
                              ))),
                    ],
                  ),
                )))));
  }
}