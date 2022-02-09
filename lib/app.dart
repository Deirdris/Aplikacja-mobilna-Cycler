import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projekt_inzynierka/screens/login.dart';
import 'package:flutter_projekt_inzynierka/screens/starting_app.dart';
import 'package:flutter_projekt_inzynierka/screens/account.dart';
import 'package:flutter_projekt_inzynierka/screens/tracks.dart';
import 'package:flutter_projekt_inzynierka/screens/track.dart';
import 'package:flutter_projekt_inzynierka/screens/edit_account.dart';
import 'package:flutter_projekt_inzynierka/screens/stats.dart';
import 'package:flutter_projekt_inzynierka/screens/training_history.dart';
import 'package:flutter_projekt_inzynierka/screens/training_more_info.dart';
import 'package:flutter_projekt_inzynierka/screens/achievements.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'assets/colors.dart';
import 'package:flutter_projekt_inzynierka/screens/training.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: GetMaterialApp(
        title: 'Flutter Demo',
        initialRoute: '/',
        routes: {
          '/': (context) => StartingApp(),
          '/login': (context) => LoginScreen(),
          '/training': (context) => TrainingPage(),
          '/account': (context) => AccountPage(),
          '/edit_account': (context) => EditAccountPage(),
          '/history': (context) => TrainingHistory(),
          '/stats': (context) => StatsPage(),
          '/moreInfo': (context) => TrainingMoreInfo(),
          '/achievements': (context) => Achievements(),
          '/tracks': (context) => Tracks(),
          '/track': (context) => TrackPage(),
        },
        theme: ThemeData(
          primaryColor: primary,
          primarySwatch: primary,
          // primaryColor: Color(0xFF24223B),
          canvasColor: primary[800],
          textTheme: TextTheme(),
          hintColor: Color(0xFFcfd1e3),
          brightness: Brightness.dark,
          appBarTheme: AppBarTheme(backgroundColor: primary[700]),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          cardColor: primary[800],
          scaffoldBackgroundColor: primary,
          elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(primary: primary[700])),
          buttonTheme: ButtonThemeData(buttonColor: primary[800]),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(primary: Colors.white)),
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('pl', 'PL'),
        ],
        //locale: Locale("pl"),
      ),
    );
  }
}