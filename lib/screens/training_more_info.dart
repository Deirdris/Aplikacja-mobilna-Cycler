import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_projekt_inzynierka/controllers/stats_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/trainings_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:flutter_projekt_inzynierka/data/training_data.dart';
import 'package:flutter_projekt_inzynierka/methods/format_number.dart';
import 'package:flutter_projekt_inzynierka/widgets/future_handler.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class GoogleMapController extends GetxController {
  final Set<Polyline> _polyline = {};
  final Set<Circle> _circle = {};
  final List<LatLng> polylineCords = [];
  final layerLink = LayerLink();

  @override
  void onInit() {
    super.onInit();
    for (int i = 1; i < Get.arguments.positionsDB.length; i += 2) {
      polylineCords.add(LatLng(Get.arguments.positionsDB[i - 1], Get.arguments.positionsDB[i]));
    }
    _circle.add(Circle(
        circleId: CircleId('kółko1'),
        fillColor: Get.theme.primaryColor,
        radius: 10,
        strokeWidth: 2,
        center: LatLng(Get.arguments.positionsDB[0], Get.arguments.positionsDB[1])));
    _circle.add(Circle(
        circleId: CircleId('kółko2'),
        fillColor: Get.theme.primaryColor,
        radius: 10,
        strokeWidth: 2,
        center: LatLng(Get.arguments.positionsDB[Get.arguments.positionsDB.length - 2],
            Get.arguments.positionsDB[Get.arguments.positionsDB.length - 1])));
    _polyline.add(Polyline(
      polylineId: PolylineId('trasa'),
      width: 2,
      color: Get.theme.primaryColor,
      endCap: Cap.roundCap,
      points: polylineCords,
    ));
  }
}

class TrainingMoreInfo extends StatelessWidget {
  // final GoogleMapController controller = Get.put(GoogleMapController(), permanent: true);
  final String trainingId = (Get.arguments as Training).id;

  final String trainingDateEnd = DateFormat("dd LLL yyyy, HH:mm").format(Get.arguments.dateEnd).toString();
  final String trainingDateStart = DateFormat("dd LLL yyyy, HH:mm").format(Get.arguments.dateStart).toString();

  final trainingNewName = ''.obs;
  final trainingName = ''.obs;

  //final LatLng _initialcameraposition = LatLng((Get.arguments as Training).positionsDB[0], (Get.arguments as Training).positionsDB[1]);

  UserController get userController => Get.find<UserController>();

  TrainingsController get trainingsController => Get.find<TrainingsController>();

  StatsController get statsController => Get.find<StatsController>();

  final List<String> labelList = ['Trening', 'Całościowa', 'Miesięczna', 'Tygodniowa'];

  List<double> get velocityList => [
        Get.arguments.averageVelocity,
        statsController.stats.globalStats.averageVelocity,
        statsController.stats.monthlyStats.averageVelocity,
        statsController.stats.weeklyStats.averageVelocity,
      ];

  double get maxValue => velocityList.fold(0, (value, element) => max(value, element));

  @override
  Widget build(BuildContext context) {
    trainingName.value = Get.arguments.name;
    print(Get.arguments.positionsDB[0]);
    print(Get.arguments.positionsDB[1]);
    return GetBuilder<GoogleMapController>(
      init: GoogleMapController(),
      builder: (controller) => Theme(
        data: Theme.of(context).copyWith(scaffoldBackgroundColor: Theme.of(context).cardColor),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('Szczegóły treningu'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.delete),
                tooltip: 'Usuń wpis z historii',
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Theme.of(context).primaryColor,
                          title: Text(
                            'Usunąć trening?',
                            style: TextStyle(fontSize: 20),
                          ),
                          actions: [
                            TextButton(
                                child: Text(
                                  'Nie',
                                  style: TextStyle(color: Theme.of(context).accentColor),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            TextButton(
                                child: Text(
                                  'Tak',
                                  style: TextStyle(color: Theme.of(context).accentColor),
                                ),
                                onPressed: () {
                                  userController.userDoc.collection("trainings").doc(trainingId).delete();
                                  trainingsController.trainings.removeWhere((training) => training.id == trainingId);
                                  Navigator.of(context).pop();
                                  Get.back();
                                }),
                          ],
                        );
                      });
                },
                splashRadius: 26,
              ),
            ],
          ),
          body: FutureHandler(
            future: statsController.fetchFuture,
            onDone: () => Stack(
              children: [
                SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 0.0, 12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Nazwa treningu',
                                              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              trainingName.value,
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        tooltip: 'Zmień nazwę',
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                                                  backgroundColor: Theme.of(context).primaryColor,
                                                  title: Text('Nazwa treningu'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        cursorColor: Theme.of(context).accentColor,
                                                        decoration: InputDecoration(
                                                          focusedBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged: (value) {
                                                          trainingNewName.value = value.trim();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        child: Text('Anuluj',
                                                            style: TextStyle(color: Theme.of(context).accentColor)),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        }),
                                                    TextButton(
                                                        child: Text('Zapisz',
                                                            style: TextStyle(color: Theme.of(context).accentColor)),
                                                        onPressed: () {
                                                          userController.userDoc
                                                              .collection("trainings")
                                                              .doc(trainingId)
                                                              .update({'name': trainingNewName.value});
                                                          trainingsController
                                                              .trainings[trainingsController.trainings
                                                                  .indexWhere((training) => training.id == trainingId)]
                                                              .name = trainingNewName.value;
                                                          trainingName.value = trainingNewName.value;
                                                          trainingsController.trainings.refresh();
                                                          Navigator.of(context).pop();
                                                          Get.back(); // todo temporary fix, bez tego wywala nulla na argumenty z routa
                                                        }),
                                                  ],
                                                );
                                              });
                                        },
                                        splashRadius: 26,
                                      ),
                                    ],
                                  )),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.timer, color: Theme.of(context).accentColor),
                                            SizedBox(height: 4),
                                            Text(Get.arguments.duration),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.speed, color: Theme.of(context).accentColor),
                                            SizedBox(height: 4),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: formatNumber(Get.arguments.averageVelocity).toString(),
                                                      style: TextStyle(fontSize: 16)),
                                                  TextSpan(
                                                      text: " km/h",
                                                      style:
                                                          TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.local_fire_department, color: Theme.of(context).accentColor),
                                            SizedBox(height: 4),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: formatNumber(Get.arguments.calories).toString(),
                                                      style: TextStyle(fontSize: 16)),
                                                  TextSpan(
                                                      text: " kcal",
                                                      style:
                                                          TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.directions_bike, color: Theme.of(context).accentColor),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Text('Dystans', style: TextStyle(fontSize: 16)),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    text: formatNumber(Get.arguments.distance).toString(),
                                                    style: TextStyle(fontSize: 22)),
                                                TextSpan(
                                                    text: " km",
                                                    style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Divider(
                                        thickness: 1,
                                        height: 1,
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(Icons.play_arrow, color: Theme.of(context).accentColor),
                                                SizedBox(width: 16),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Początek',
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                    SizedBox(height: 4),
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                              text: trainingDateStart,
                                                              style: TextStyle(
                                                                  color: Theme.of(context).hintColor, fontSize: 12)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Divider(
                                        thickness: 1,
                                        height: 1,
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(Icons.stop, color: Theme.of(context).accentColor),
                                                SizedBox(width: 16),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Koniec',
                                                      style: TextStyle(fontSize: 14),
                                                    ),
                                                    SizedBox(height: 4),
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                              text: trainingDateEnd,
                                                              style: TextStyle(
                                                                  color: Theme.of(context).hintColor, fontSize: 12)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Column(
                              //   children: [
                              //     Text('Całkowity dystans', style: TextStyle(fontSize: 16)),
                              //     SizedBox(
                              //       height: 12,
                              //     ),
                              //     RichText(
                              //       text: TextSpan(
                              //         children: [
                              //           TextSpan(text: Get.arguments.distance.toString(), style: TextStyle(fontSize: 22)),
                              //           TextSpan(
                              //               text: " km", style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
                              //         ],
                              //       ),
                              //     ),
                              //     SizedBox(
                              //       height: 12,
                              //     ),
                              //     Row(
                              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       crossAxisAlignment: CrossAxisAlignment.center,
                              //       children: [
                              //         RichText(
                              //           text: TextSpan(
                              //             children: [
                              //               TextSpan(text: 'Początek: ', style: TextStyle(fontSize: 14)),
                              //               TextSpan(
                              //                   text: trainingDateStart,
                              //                   style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                              //             ],
                              //           ),
                              //         ),
                              //         RichText(
                              //           text: TextSpan(
                              //             children: [
                              //               TextSpan(text: 'Koniec: ', style: TextStyle(fontSize: 14)),
                              //               TextSpan(
                              //                   text: trainingDateEnd,
                              //                   style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                              //             ],
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        if (LatLng((Get.arguments as Training).positionsDB[0],
                                (Get.arguments as Training).positionsDB[1]) !=
                            null) ...[
                          CompositedTransformTarget(
                            link: controller.layerLink,
                            child: Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: SizedBox.shrink(),
                            ),
                          ),
                        ],
                        if (LatLng((Get.arguments as Training).positionsDB[0],
                                (Get.arguments as Training).positionsDB[1]) ==
                            null)
                          Center(child: CircularProgressIndicator()),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Średnia prędkość',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        Flexible(
                          // child: RotatedBox(
                          //   quarterTurns: 1,
                          //   child: Padding(
                          //     padding: const EdgeInsets.fromLTRB(16.0, 16.0, 0.0, 0.0),
                          //     child: BarChart(
                          //       BarChartData(
                          //         titlesData: FlTitlesData(
                          //           leftTitles: SideTitles(showTitles: false),
                          //           topTitles: SideTitles(showTitles: false),
                          //           bottomTitles: SideTitles(showTitles: true, rotateAngle: -90),
                          //           rightTitles: SideTitles(showTitles: true, rotateAngle: -90),
                          //         ),
                          //         borderData: FlBorderData(show: false),
                          //         gridData: FlGridData(show: false),
                          //         barGroups: [
                          //           for (int i = 0; i < 4; i++)
                          //             BarChartGroupData(
                          //               x: i,
                          //               barRods: [
                          //                 BarChartRodData(
                          //                   y: velocityList[i],
                          //                 ),
                          //               ],
                          //             ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < 4; i++)
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          labelList[i],
                                          style: TextStyle(color: Theme.of(context).hintColor),
                                        ),
                                        SizedBox(height: 2),
                                        FractionallySizedBox(
                                          widthFactor: velocityList[i] / maxValue,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: Theme.of(context).accentColor.withOpacity(.84),
                                                  ),
                                                  height: 8,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                formatNumber(velocityList[i]).toString(),
                                                style: TextStyle(color: Theme.of(context).accentColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CompositedTransformFollower(
                  showWhenUnlinked: false,
                  link: controller.layerLink,
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng((Get.arguments as Training).positionsDB[0],
                              (Get.arguments as Training).positionsDB[1]),
                          zoom: 15),
                      mapType: MapType.normal,
                      //onMapCreated: _onMapCreated,
                      polylines: controller._polyline,
                      circles: controller._circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}