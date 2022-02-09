import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projekt_inzynierka/controllers/rank_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/stats_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/trainings_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/achievements_progress_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/achievements_info_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/user_controller.dart';
import 'package:flutter_projekt_inzynierka/data/achievement_data.dart';
import 'package:flutter_projekt_inzynierka/data/rank_data.dart';
import 'package:flutter_projekt_inzynierka/data/achievement_progress_data.dart';
import 'package:flutter_projekt_inzynierka/widgets/future_handler.dart';
import 'package:flutter_projekt_inzynierka/data/stats_data.dart';
import 'package:flutter_projekt_inzynierka/data/training_data.dart';
import 'package:flutter_projekt_inzynierka/methods/format_number.dart';
import 'package:flutter_projekt_inzynierka/methods/format_time.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/scaffold.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:geolocator/geolocator.dart';

class _TrainingController extends GetxController {
  final StatsController statsController = Get.put(StatsController(), permanent: true);
  Rxn<LatLng> initialcameraposition = Rxn<LatLng>();
  GoogleMapController _controller;
  location.Location _location = location.Location();
  List<Position> positions = [];
  List positionsDB = [];
  final elapsedMilliseconds = 0.obs;
  final velocity = 0.0.obs;
  final distance = 0.0.obs;
  final avgVelocity = 0.0.obs;
  final maxVelocity = 0.0.obs;
  final calories = 0.0.obs;
  final distBetw = 0.0.obs;
  final paused = true.obs;
  Stopwatch _stopwatch;
  Timer _stopwatchTimer;
  Timer _velocityTimer;
  StreamSubscription _initialLocationSub;
  StreamSubscription _locationSub;
  StreamSubscription _positionStream;
  Rx<Polyline> polyline = new Polyline(
    polylineId: PolylineId('identyfikator'),
    width: 2,
    color: Get.theme.primaryColor,
    endCap: Cap.roundCap,
  ).obs;
  Rx<Circle> circleStart = new Circle(
    circleId: CircleId('kółko'),
    fillColor: Get.theme.primaryColor,
    radius: 10,
    strokeWidth: 2,
  ).obs;
  DateTime dateStart;
  bool firstStart = true;

  final RankController rankController = Get.put(RankController(),permanent:true);
  final UserController userController = Get.find<UserController>();
  final auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _stopwatch = Stopwatch();

    (() async {
      await _location.requestPermission();
      await _location.requestService();

      _initialLocationSub = _location.onLocationChanged.listen((l) {
        if (initialcameraposition() == null) {
          initialcameraposition.value = LatLng(l.latitude, l.longitude);
          _initialLocationSub.cancel();
        }
      });

      _positionStream =
          Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation).listen((position) {
        if (!paused()) {
          _velocityTimer?.cancel();
          velocity.value = position.speed * 3600 / 1000;
          if (velocity() > maxVelocity()) {
            maxVelocity.value = velocity();
          }
          _velocityTimer = Timer(Duration(seconds: 2), () {
            velocity.value = 0;
          });
          if (position != null) {
            if (positions.length == 0) {
              circleStart.value = circleStart().copyWith(
                centerParam: LatLng(position.latitude, position.longitude),
                visibleParam: true,
              );
            }
            positions.add(position);
            positionsDB.add(position.latitude);
            positionsDB.add(position.longitude);
            //toList();
            print(position.latitude);
            print(position.longitude);
            polyline.value = polyline().copyWith(pointsParam: [
              ...polyline().points,
              LatLng(position.latitude, position.longitude),
            ]);
          }
          if (positions.length > 2) {
            positions = positions.skip(1).toList();
            distBetw.value = Geolocator.distanceBetween(
                positions[0].latitude, positions[0].longitude, positions[1].latitude, positions[1].longitude);

            distance.value += distBetw / 1000;
            calories.value += velocity * 0.00625;
            if (distance > 0) {
              avgVelocity.value = 3600000 * distance() / _stopwatch.elapsedMilliseconds;
            }
          }
        }
      });
    })();
  }

  void _setDateStart() {
    if (firstStart) {
      dateStart = DateTime.now();
    } else {
      firstStart = true;
    }
  }

  void onMapCreated(GoogleMapController _ctrl) {
    _controller = _ctrl;

    resumeLocation();
  }

  Future<void> addTraining(String trainingName) {
    final training = Training(
      averageVelocity: num.parse(avgVelocity.toStringAsFixed(1)),
      distance: num.parse(distance.toStringAsFixed(1)),
      calories: num.parse(calories.toStringAsFixed(1)),
      duration: FormatTime().formatTime(_stopwatch.elapsedMilliseconds),
      dateEnd: DateTime.now(),
      dateStart: dateStart,
      name: trainingName,
      positionsDB: [...positionsDB],
    );
    return Get.put(TrainingsController(), permanent: true).add(training);
  }

  Future<void> updateStats() async {
    final DateTime now = DateTime.now();
    await statsController.fetchFuture;
    final stats = statsController.stats;
    stats.update(
      distance: distance(),
      calories: calories(),
      maxVelocity: maxVelocity(),
      duration: _stopwatch.elapsedMilliseconds / 1000,
    );
    stats
      ..month = DateFormat('MMyyyy').format(DateTime.now())
      ..monday = DateTime(now.year, now.month, now.day - (now.weekday - 1)).day.toString();
   return stats.docReference.set(stats.toFirestore());
  }

  Future<void> updateRank() async {
    await rankController.fetchFuture;

    final rank = Rank(
      overallDistance: num.parse((statsController.stats.globalStats.overallDistance).toStringAsFixed(1)),
      highestVelocity: num.parse((statsController.stats.globalStats.highestVelocity).toStringAsFixed(1)),
      overallDuration: (statsController.stats.globalStats.overallDuration).toInt(),
      userId: auth.currentUser.uid,
      userName: (userController.userData.name + ' ' + userController.userData.surname),
      avatarUrl: userController.userData.avatarUrl,
      averageVelocity:  num.parse((statsController.stats.globalStats.overallDistance / (statsController.stats.globalStats.overallDuration / 3600)).toStringAsFixed(1)),
    );
    return rankController.add(rank);
  }

  void playOrPauseTraining() {
    if (paused()) {
      if (firstStart) {
        dateStart = DateTime.now();
        firstStart = false;
      }
      _stopwatch.start();
      _stopwatchTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        elapsedMilliseconds.value = _stopwatch.elapsedMilliseconds;
        // setState(() {});
      });
    } else {
      _stopwatch.stop();
      _stopwatchTimer.cancel();
    }
    paused.value = !paused();
  }

  Future endTraining() async {
    paused.value = true;
    _stopwatch.stop();
    final trainingName = await Get.dialog<String>(_SaveTrainingDialog());
    if (trainingName != null) {
      _setDateStart();
      await addTraining(trainingName);
      await updateStats();
      await updateRank();
      await Get.dialog<String>(_ShowCompletedAchievements( distance: distance(),
          calories: calories(),
          maxVelocity: maxVelocity(),
          duration: _stopwatch.elapsedMilliseconds / 1000));
      positionsDB.clear();
      avgVelocity.value = 0;
      distance.value = 0;
      _stopwatch.reset();
      elapsedMilliseconds.value = 0;
      calories.value = 0;
      polyline.value = polyline().copyWith(pointsParam: []);
      positions.clear();
      circleStart.value = circleStart().copyWith(
        visibleParam: false,
      );
    }
  }

  void resumeLocation() {
    _locationSub ??= _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 15),
        ),
      );
    });
  }

  void pauseLocation() {
    _locationSub?.cancel();
    _locationSub = null;
    _controller?.dispose();
    _controller = null;
  }

  @override
  void onClose() {
    pauseLocation();
    _positionStream?.cancel();
    _stopwatch?.stop();
    _stopwatchTimer?.cancel();

    super.onClose();
  }
}

class TrainingPage extends StatefulWidget {
  TrainingPage({Key key}) : super(key: key);

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final controller = Get.put(_TrainingController(), permanent: true);

  @override
  void dispose() {
    controller.pauseLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        title: Text('Trening'),
      ),
      resizeToAvoidBottomInset: false,
      body: Builder(builder: (context) {
        var orientation = MediaQuery.of(context).orientation;
        var children = [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 24.0),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
              child: Obx(
                () => Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: formatNumber(controller.velocity()).toString(),
                                    style: TextStyle(fontSize: 40)),
                                TextSpan(
                                    text: " KM/H", style: TextStyle(fontSize: 18, color: Theme.of(context).hintColor)),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "Średnia: " + formatNumber(controller.avgVelocity()).toString(),
                                    style: TextStyle(fontSize: 16)),
                                TextSpan(
                                    text: " KM/H", style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Icon(Icons.timer, color: Theme.of(context).accentColor),
                                SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: FormatTime().formatTime(controller.elapsedMilliseconds()),
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Icon(Icons.directions_bike, color: Theme.of(context).accentColor),
                                SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: formatNumber(controller.distance()).toString(),
                                          style: TextStyle(fontSize: 16)),
                                      TextSpan(
                                          text: " km",
                                          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Icon(Icons.local_fire_department, color: Theme.of(context).accentColor),
                                SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: formatNumber(controller.calories()).toString(),
                                          style: TextStyle(fontSize: 16)),
                                      TextSpan(
                                          text: " kcal",
                                          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Obx(
                () => Stack(
                  children: [
                    if (controller.initialcameraposition() != null) ...[
                      Obx(
                        () => GoogleMap(
                          initialCameraPosition: CameraPosition(target: controller.initialcameraposition(), zoom: 15),
                          mapType: MapType.normal,
                          onMapCreated: controller.onMapCreated,
                          myLocationEnabled: true,
                          polylines: {controller.polyline()},
                          circles: {controller.circleStart()},
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                elevation: 8,
                                shape: CircleBorder(),
                                child: ElevatedButton(
                                  onPressed: controller.endTraining,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Icon(Icons.stop_rounded, size: 36),
                                  ),
                                  style: ButtonStyle(shape: MaterialStateProperty.all(CircleBorder())),
                                ),
                              ),
                              Material(
                                elevation: 8,
                                shape: CircleBorder(),
                                child: ElevatedButton(
                                  onPressed: controller.playOrPauseTraining,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child:
                                        Obx(() => Icon(controller.paused() ? Icons.play_arrow : Icons.pause, size: 36)),
                                  ),
                                  style: ButtonStyle(shape: MaterialStateProperty.all(CircleBorder())),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (controller.initialcameraposition() == null) Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
            flex: orientation == Orientation.portrait ? 2 : 1,
          )
        ];

        return orientation == Orientation.portrait ? Column(children: children) : Row(children: children);
      }),
    );
  }
}

class _SaveTrainingDialog extends StatelessWidget {
  _SaveTrainingDialog({Key key}) : super(key: key);

  final showInput = false.obs;
  final trainingName = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: !showInput()
            ? Text('Zakończyć trening?', style: TextStyle(fontSize: 18))
            : Text('Nazwa treningu', style: TextStyle(fontSize: 18)),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
        content: showInput()
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    cursorColor: Theme.of(context).accentColor,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      trainingName.value = value.trim();
                    },
                  ),
                ],
              )
            : null,
        actions: showInput()
            ? [
                TextButton(
                  child: Text('Anuluj', style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () => Get.back(),
                ),
                TextButton(
                  child: Text('Zapisz', style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () => Get.back(result: trainingName()),
                ),
              ]
            : [
                TextButton(
                  child: Text('Nie', style: TextStyle(color: Theme.of(context).accentColor)),
                  onPressed: () => Get.back(),
                ),
                TextButton(
                  child: Text(
                    'Tak',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onPressed: () => showInput.value = true,
                ),
              ],
      ),
    );
  }
}
class _ShowCompletedAchievements extends StatelessWidget {
  _ShowCompletedAchievements({
    @required this.distance,
    @required this.maxVelocity,
    @required this.calories,
    @required this.duration,
  });

  final distance;
  final maxVelocity;
  final calories;
  final duration;
  final AchievementsProgressController achProgController = Get.put(AchievementsProgressController(), permanent: true);
  final AchievementsInfoController achInfoController = Get.put(AchievementsInfoController(), permanent: true);

  final oldDistanceStageId = 0.obs;
  final oldSpeedStageId = 0.obs;
  final oldTimeStageId = 0.obs;
  final oldCaloriesStageId = 0.obs;

  Future<void> dataLoading() async {
    await achProgController.fetchFuture;
    await achInfoController.fetchFuture;

    final achievementProgress = achProgController.achProgress;

    oldDistanceStageId.value = findCompletedAchievements(
        achievementProgress.distance,
        achInfoController.achDistance,
        num.parse(distance.toStringAsFixed(1)),
        false);
    oldSpeedStageId.value = findCompletedAchievements(
        achievementProgress.speed,
        achInfoController.achSpeed,
        num.parse(maxVelocity.toStringAsFixed(1)),
        true);
    oldTimeStageId.value = findCompletedAchievements(
        achievementProgress.time,
        achInfoController.achTime,
        num.parse(duration.toInt().toStringAsFixed(1)),
        false);
    oldCaloriesStageId.value = findCompletedAchievements(
        achievementProgress.calories,
        achInfoController.achCalories,
        num.parse(calories.toStringAsFixed(1)),
        false);

    //await userProgress.docReference.set(userProgress.toFirestore());
    await achProgController.achProgDocument.set(achievementProgress.toFirestore());
  }

  int findCompletedAchievements(AchProgressEntry categoryAchProg, List<Achievement> achData, double newData, bool isSpeed) {

    int oldStageId = categoryAchProg.stageId;
    double newProgress;

    if(!isSpeed)
      newProgress = categoryAchProg.progress + newData;
    else
      newProgress= categoryAchProg.progress < newData ? newData : categoryAchProg.progress;

    for (int i = categoryAchProg.stageId; i < achData.length; i++) {

      if (newProgress < achData[i].goal) {
        categoryAchProg.stageId = i;
        categoryAchProg.progress = newProgress;
        return oldStageId;
      }
      else {
        if(!isSpeed)
          newProgress -= achData[i].goal;
      }

    }

    categoryAchProg.stageId = achData.length;
    categoryAchProg.progress = newProgress;
    categoryAchProg.allCompleted = true;

    return oldStageId;
  }

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title:  Row(children: [
        Text('Osiągnięcia:', style: TextStyle(fontSize: 18)),
      ]),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
      content:  FutureHandler(
          future: dataLoading(),
          onNotDone: () =>
              Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    Container(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        )
                    ),
                  ]
              ),
          onDone:() =>
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child:
                  Container(
                      child:  SingleChildScrollView( child: ListBody(
                          children:  <Widget>[
                            _ShowAchievements(
                                categoryAchProg: achProgController.achProgress.distance,
                                categoryAchData: achInfoController.achDistance,
                                oldStageId: oldDistanceStageId.value,
                                categoryIcon: Icons.directions_bike_rounded,
                                categoryName: "Dystans:"),
                            _ShowAchievements(
                                categoryAchProg: achProgController.achProgress.speed,
                                categoryAchData: achInfoController.achSpeed,
                                oldStageId: oldSpeedStageId.value,
                                categoryIcon: Icons.speed_rounded,
                                categoryName: "Prędkość:"),
                            _ShowAchievements(
                                categoryAchProg: achProgController.achProgress.time,
                                categoryAchData: achInfoController.achTime,
                                oldStageId: oldTimeStageId.value,
                                categoryIcon: Icons.timer_outlined,
                                categoryName: "Czas:"),
                            _ShowAchievements(
                                categoryAchProg: achProgController.achProgress.calories,
                                categoryAchData: achInfoController.achCalories,
                                oldStageId: oldCaloriesStageId.value,
                                categoryIcon: Icons.local_fire_department,
                                categoryName: "Kalorie:"),

                          ])))
              )
      ),
      actions: [
        TextButton(
          child: Text('Świetnie!', style: TextStyle(color: Theme.of(context).accentColor)),
          onPressed: () => Get.back(),
        )
      ],
    );
  }

}

class _ShowAchievements extends StatelessWidget {
  _ShowAchievements({
    @required this.categoryAchProg,
    @required this.categoryAchData,
    @required this.oldStageId,
    @required this.categoryIcon,
    @required this.categoryName,

  });

  final categoryAchProg;
  final categoryAchData;
  final oldStageId;
  final categoryIcon;
  final categoryName;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 20),
      Row(children:[
        Icon(categoryIcon, color: Theme.of(context).accentColor),
        SizedBox(width: 5),
        Text(categoryName, style: TextStyle(fontWeight: FontWeight.bold)),
      ]),
      SizedBox(height: 5),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(children: [
            categoryAchProg.allCompleted ?
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.done_all_sharp , color: Colors.amber[200]),
                SizedBox(width: 5),
                Expanded(child: Text("Ukończono kategorię")),
                SizedBox(width: 10),
              ],) :
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_outlined, color: Colors.amber[200]),
                SizedBox(width: 5),
                Expanded(child: Text(categoryAchData[categoryAchProg.stageId].name)),
                SizedBox(width: 10),
                Text((categoryAchProg.progress*100~/categoryAchData[categoryAchProg.stageId].goal).toString()+"%"),
                ],),
            SizedBox(height: 8),

            for (int i = categoryAchProg.stageId-1; i >= oldStageId; i--)...[
              Column(children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded, color: Colors.amber[200]),
                    SizedBox(width: 5),
                    Expanded(child:Text(categoryAchData[i].name, textAlign: TextAlign.left)),
                    SizedBox(width: 10),
                    Text("100%"),
                  ],
                ),
              SizedBox(height: 8),
              ]),
            ],
    ]))]);
  }
}
