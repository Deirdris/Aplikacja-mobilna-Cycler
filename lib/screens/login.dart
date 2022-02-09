import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:flutter_projekt_inzynierka/widgets/snackbar.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final email = ''.obs;
  final password = ''.obs;

  final isLoadingLogin = false.obs;
  final isLoadingRegister = false.obs;

  bool ifRegister = true;

  final auth = FirebaseAuth.instance;

  final UserController userController = Get.put(UserController(), permanent: true);

  Map<String, String> errorMessages = {
    'user-not-found': 'Nieprawidłowy email lub hasło',
    'wrong-password': 'Nieprawidłowy email lub hasło',
    'invalid-email': 'Podany email nie jest prawidłowy',
    'email-already-in-use': 'Podany email jest już zajęty',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty && ifRegister) {
                            return 'Proszę uzupełnić pole.';
                          } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+" )
                              .hasMatch(value) && ifRegister) {
                            return 'Proszę podać poprawny adres email';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Theme.of(context).hintColor,
                          ),
                          labelStyle: TextStyle(color: Theme.of(context).hintColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          email.value = value.trim();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty && ifRegister) {
                            return 'Proszę uzupełnić pole.';
                          } else if (value.length < 8 && ifRegister) {
                            return 'Hasło powinno zawierać co najmniej 8 znaków.';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Hasło',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Theme.of(context).hintColor,
                          ),
                          labelStyle: TextStyle(color: Theme.of(context).hintColor),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          password.value = value.trim();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Obx(
                          () => ElevatedButton(
                            onPressed: () async {
                              ifRegister = true;

                              if (!_formKey.currentState.validate()) {
                                return;
                              }
                              isLoadingRegister.value = true;
                              try {
                                await userController.registerUser(email.value, password.value);

                               Get.offNamed("/training");
                             
                              } catch (e) {
                                print(e);
                                Get.showSnackbar(MySnackbar(message: errorMessages[e.code] ?? 'Błąd rejestracji',));
                                isLoadingRegister.value = false;
                              }
                            },
                            child: isLoadingRegister.value == false
                                ? Text('Zarejestruj')
                                : Container(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Obx(
                          () => ElevatedButton(
                            onPressed: () async {
                              ifRegister = false;
                              _formKey.currentState.validate();

                              if (email.isEmpty || password.isEmpty) {
                                Get.showSnackbar(MySnackbar(message: 'Proszę uzupełnić wszystkie pola',));
                                return;
                              }
                              isLoadingLogin.value = true;
                              try {
                                await userController.loginUser(email.value, password.value);

                                Get.offNamed("/training");

                              } catch (e) {
                                print(e);
                                Get.showSnackbar(MySnackbar(message: errorMessages[e.code] ?? 'Błąd logowania',));
                                isLoadingLogin.value = false;
                              }
                            },
                            child: isLoadingLogin.value == false
                                ? Text('Zaloguj')
                                : Container(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
