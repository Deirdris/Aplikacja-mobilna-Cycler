import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/scaffold.dart';
import 'package:flutter/services.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:flutter_projekt_inzynierka/data/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_projekt_inzynierka/methods/format_number.dart';
import 'package:flutter_projekt_inzynierka/methods/get_avatar.dart';

class EditAccountPage extends StatelessWidget {
  final UserController userController = Get.find<UserController>();

  final auth = FirebaseAuth.instance;

  //final textColor = Color.fromRGBO(204, 206, 225, 1);

  final _image = "".obs;
  final _avatarUrl = "".obs;
  final _name = "".obs;
  final _surname = "".obs;
  final _dateOfBirth = DateTime.now().obs;
  final _height = 0.obs;
  final _weight = 0.0.obs;
  final _gender = "".obs;
  final _isCompleted = false.obs;
  final _isAvatarError = false.obs;
  final _isGenderError = false.obs;
  final _isDateOfBirthError = false.obs;
  final _ifSavingData = false.obs;
  final _ifRemoveAvatar = false.obs;

  EditAccountPage() {
    _avatarUrl.value = userController.userData.avatarUrl;
    _name.value = userController.userData.name;
    _surname.value = userController.userData.surname;
    _dateOfBirth.value = userController.userData.dateOfBirth;
    _height.value = userController.userData.height;
    _weight.value = userController.userData.weight;
    _gender.value = userController.userData.gender;
    _isCompleted.value = userController.userData.isCompleted;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<bool> _formValidation() async {
    bool error = false;

    // Walidacja wyboru płci
    if ((_gender.value == null) || (_gender.isEmpty)) {
      error = true;
      _isGenderError.value = true;
    } else
      _isGenderError.value = false;

    // Walidacja daty urodzenia
    if (_dateOfBirth.value == null) {
      error = true;
      _isDateOfBirthError.value = true;
    } else
      _isDateOfBirthError.value = false;

    return error;
  }

  Widget _buildAvatarHelper() {
    if (_image.value == "")
      return CachedNetworkImage(
        imageUrl: getAvatar(_avatarUrl.value),
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
      );
    else {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: FileImage(File(_image.value)), fit: BoxFit.cover),
          border: Border.all(
            color: Color(0xFF24223B),
            width: 4.0,
          ),
        ),
      );
    }
  }

  Future<void> addUserData() {

    int numHeight= num.parse(_height.value.toStringAsFixed(0));
    double numWeight = num.parse(_weight.value.toStringAsFixed(1));
    double bmi = num.parse((numWeight/((numHeight/100)*(numHeight/100))).toStringAsFixed(1));

    final userData = UserData(
      avatarUrl: _avatarUrl.value,
      name: _name.value,
      nameNS: _name.value.toLowerCase()+" "+_surname.value.toLowerCase(),
      nameSN: _surname.value.toLowerCase()+" "+_name.value.toLowerCase(),
      surname: _surname.value,
      dateOfBirth: _dateOfBirth.value,
      height: numHeight,
      weight: numWeight,
      gender: _gender.value,
      isCompleted: _isCompleted.value,
      bmiValue: bmi,
      bmiDescription: _bmiDescription(bmi),
      invites: userController.userData.invites,
      friends: userController.userData.friends
    );
    return Get.put(UserController(), permanent: true).saveData(userData);
  }

  _bmiDescription(double bmi) {
    String description = "";

    if(bmi < 16.0)
      description = "wygłodzenie";
    else if (bmi >= 16.0 && bmi < 17)
      description = "wychudzenie";
    else if (bmi >= 17.0 && bmi < 18.5)
      description = "niedowaga";
    else if (bmi >= 18.5 && bmi < 25)
      description = "waga prawidłowa";
    else if (bmi >= 25 && bmi < 30)
      description = "nadwaga";
    else if (bmi >= 30 && bmi < 35)
      description = "otyłość I stopnia";
    else if (bmi >= 35 && bmi < 40)
      description = "otyłość II stopnia";
    else if (bmi >= 40)
      description = "otyłość III stopnia";


    return description;
  }

  Future saveAvatar() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child("avatars")
        .child("/${auth.currentUser.email}_profilePic.jpg")
        .putFile(File(_image.value));
    TaskSnapshot storageTaskSnapshot = await uploadTask;

    _avatarUrl.value = await storageTaskSnapshot.ref.getDownloadURL();
  }

  Future deleteAvatar() async {
    FirebaseStorage.instance
        .ref()
        .child("avatars")
        .child("/${auth.currentUser.email}_profilePic.jpg")
        .delete();

  }


  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context)
            .copyWith(scaffoldBackgroundColor: Theme.of(context).cardColor),
        child: Scaffold(
            appBar: AppBar(
              title: Text("Edytuj dane konta"),
            ),
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
                child: Container(
                    child: Form(
                        key: _formKey,
                        child: Column(children: <Widget>[
                          Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: double.infinity,
                              child: Column(children: <Widget>[
                                SizedBox(height: 10),
                                Obx(() => _buildAvatarHelper()),
                                SizedBox(height: 5),
                                Text(auth.currentUser.email,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(150, 30),
                                      ),
                                      child: Text(
                                        "Zmień awatar",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final ImagePicker _picker =
                                            ImagePicker();
                                        XFile image = await _picker.pickImage(
                                            source: ImageSource.gallery);

                                        if (image != null) {
                                          _image.value = image.path;
                                          _ifRemoveAvatar.value = false;
                                        } else
                                          _image.value = "";
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(150, 30),
                                      ),
                                      child: Text(
                                        "Usuń awatar",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                title: Text(
                                                    'Czy na pewno chcesz usunąć awatar?',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                                actions: [
                                                  TextButton(
                                                      child: Text(
                                                        'Nie',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      }),
                                                  TextButton(
                                                      child: Text(
                                                        'Tak',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor),
                                                      ),
                                                      onPressed: () async {
                                                        _avatarUrl.value = "";

                                                        _image.value = "";

                                                        _ifRemoveAvatar.value = true;
                                                        Navigator.of(context)
                                                            .pop();
                                                      }),
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ])),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40.0, vertical: 10.0),
                              child: Column(children: <Widget>[
                                TextFormField(
                                    initialValue: _name.value,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.person, color: Theme.of(context).accentColor),
                                      labelText: 'Imię',
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).hintColor,
                                          fontSize: 18
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Proszę podać imię';
                                      else if (!RegExp(
                                              r"^[A-ZŻŹĆĄŚĘŁÓŃ]{1}[a-zżźćńółęą]+$")
                                          .hasMatch(value)) {
                                        return 'Podane imię nie jest prawidłowe';
                                      } else
                                        return null;
                                    },
                                    onChanged: (value) {
                                      _name.value = value;
                                    }),
                                TextFormField(
                                    initialValue: _surname.value,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.group, color: Theme.of(context).accentColor),
                                      labelText: 'Nazwisko',
                                      labelStyle: TextStyle(
                                          color: Theme.of(context).hintColor,
                                          fontSize: 18
                                      ),

                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Proszę podać nazwisko';
                                      else if (!RegExp(
                                              r"^[A-ZŻŹĆĄŚĘŁÓŃ]{1}[a-zżźćńółęą]+$")
                                          .hasMatch(value)) {
                                        return 'Podane nazwisko nie jest prawidłowe';
                                      } else
                                        return null;
                                    },
                                    onChanged: (value) {
                                      _surname.value = value;
                                    }),
                                TextFormField(
                                    initialValue: _height.value != 0
                                        ? _height.value.toString()
                                        : null,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.height, color: Theme.of(context).accentColor),
                                      labelText: 'Wzrost[cm]',
                                      labelStyle: TextStyle(
                                          color: Theme.of(context).hintColor,
                                          fontSize: 18
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Proszę podać swój wzrost';
                                      else {
                                        int height = int.tryParse(value);

                                        if (!(height > 50 && height < 300)) {
                                          return 'Podany wzrost nie jest prawidłowy';
                                        } else
                                          return null;
                                      }
                                    },
                                    onChanged: (value) {
                                      _height.value = int.tryParse(value);
                                    }),
                                TextFormField(
                                    initialValue: _weight.value != 0.0
                                        ? formatNumber(_weight.value)
                                        : null,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.monitor_weight_outlined, color: Theme.of(context).accentColor),
                                      labelText: 'Waga[kg]',
                                      labelStyle: TextStyle(
                                          color: Theme.of(context).hintColor,
                                          fontSize: 18),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9,]')),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Proszę podać swoją wagę';
                                      else {
                                        String temp = "";
                                        for(int i=0; i<value.length; i++)
                                          if(value[i]==",")
                                            temp += ".";
                                          else
                                            temp += value[i];

                                        double weight = double.tryParse(temp);

                                        if (!(weight > 20 && weight < 300)) {
                                          return 'Podana waga nie jest prawidłowa';
                                        } else
                                          return null;
                                      }
                                    },
                                    onChanged: (value) {
                                      String temp = "";
                                      for(int i=0; i<value.length; i++)
                                        if(value[i]==",")
                                          temp += ".";
                                        else
                                          temp += value[i];
                                      _weight.value = double.tryParse(temp);
                                    }),
                                // _buildDateOfBirth(),
                                Obx(
                                  () => TextFormField(
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.cake_rounded, color: Theme.of(context).accentColor),
                                        labelText: 'Data urodzenia',
                                        labelStyle: TextStyle(
                                            color: Theme.of(context).hintColor,
                                            fontSize: 18),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        hintText: _dateOfBirth.value != null
                                            ? DateFormat("dd.MM.yyyy").format(
                                                    _dateOfBirth.value) +
                                                "r."
                                            : "Nie podano",
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime date = DateTime(1900);
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());

                                        date = await showDatePicker(
                                          context: context,
                                          locale: Locale('pl', 'PL'),
                                          initialDate: _dateOfBirth
                                                      .value != null
                                              ? _dateOfBirth.value
                                              : DateTime(DateTime.now().year),
                                          firstDate: DateTime(
                                              DateTime.now().year - 120),
                                          lastDate:
                                              DateTime(DateTime.now().year),
                                        );

                                        if (date != null)
                                          _dateOfBirth.value = date;
                                      }),
                                ),
                                Obx(() => Align(
                                    alignment: Alignment.centerLeft,
                                    child: _isDateOfBirthError.value
                                        ? Text(
                                      "Proszę podać swoją datę urodzenia",
                                      style: TextStyle(color: Colors.redAccent),
                                    )
                                        : Container())),
                                SizedBox(height: 30),
                                Column(
                                  children: <Widget>[
                                    Row(children: <Widget>[
                                      Icon(
                                        Icons.wc,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      SizedBox(width: 5),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Płeć: ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ]),
                                    Obx(
                                          () => RadioListTile<String>(
                                        contentPadding:
                                        EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                                        title: const Text('Mężczyzna'),
                                        value: "mężczyzna",
                                        groupValue: _gender.value,
                                        onChanged: (value) {
                                          _gender.value = value;
                                        },
                                      ),
                                    ),
                                    Obx(
                                          () => RadioListTile<String>(
                                        contentPadding:
                                        EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                                        title: const Text('Kobieta'),
                                        value: "kobieta",
                                        groupValue: _gender.value,
                                        onChanged: (value) {
                                          _gender.value = value;
                                        },
                                      ),
                                    ),
                                    Obx(() => Align(
                                        alignment: Alignment.centerLeft,
                                        child: _isGenderError.value
                                            ? Text(
                                          "Proszę wybrać swoją płeć",
                                          style: TextStyle(color: Colors.redAccent),
                                        )
                                            : Container())),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Obx(() => ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 40),
                                        primary: Theme.of(context)
                                            .scaffoldBackgroundColor),
                                    child: _ifSavingData.value == false
                                        ? Text(
                                            'Zapisz',
                                            style: TextStyle(
                                              color:
                                                  Theme.of(context).hintColor,
                                              fontSize: 18,
                                            ),
                                          )
                                        : Container(
                                            height: 14,
                                            width: 14,
                                            child: CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                    onPressed: () async {
                                      bool error = false;

                                      if (!_formKey.currentState.validate() ||
                                          await _formValidation()) {
                                        error = true;
                                      }

                                      if (await _formValidation()) {
                                        error = true;
                                      }

                                      if (error) return;

                                      _ifSavingData.value = true;

                                      if (_image.value != "")
                                        await saveAvatar();
                                      else
                                        if (_ifRemoveAvatar.value)
                                          await deleteAvatar();

                                      if (!_isCompleted.value)
                                        _isCompleted.value = true;

                                      addUserData();

                                      Get.offNamed("/account");
                                    }))
                              ])),
                        ]))))));
  }
}
