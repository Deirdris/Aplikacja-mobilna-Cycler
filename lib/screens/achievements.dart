import 'package:flutter/material.dart';
import 'package:flutter_projekt_inzynierka/controllers/achievements_info_controller.dart';
import 'package:flutter_projekt_inzynierka/controllers/achievements_progress_controller.dart';
import 'package:flutter_projekt_inzynierka/data/achievement_data.dart';
import 'package:flutter_projekt_inzynierka/data/achievement_progress_data.dart';
import 'package:flutter_projekt_inzynierka/widgets/future_handler.dart';
import 'package:flutter_projekt_inzynierka/widgets/drawer.dart';
import 'package:flutter_projekt_inzynierka/widgets/scaffold.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_projekt_inzynierka/methods/format_number.dart';

class Achievements extends StatelessWidget {
  final achDataController =
      Get.put(AchievementsInfoController(), permanent: true);
  final achProgController =
  Get.put(AchievementsProgressController(), permanent: true);

  final _selectedIndex = 0.obs;
  final _moreInfo = false.obs;
  final Rx<Achievement> _selectedAchievement = new Achievement(
      idAchievement: 0,
      comment: "",
      name: "",
      description: "",
      goal: 1).obs;
  final Rx<AchProgressEntry> _selectedUserProgress = new AchProgressEntry(
      stageId: 0,
      progress: 1).obs;
  final _acquiredSelectedAchievement = false.obs;
  final _selectedUnit = " km".obs;

  void _onItemTapped(int index) {

    if(_selectedIndex.value != index) {

      switch (index) {
        case 0:
          int stageId = achProgController.achProgress.distance.stageId;
          if(achProgController.achProgress.distance.allCompleted) stageId--;
          _changeCategory(achDataController.achDistance[stageId],
              achProgController.achProgress.distance, index, "km");
          break;
        case 1:
          int stageId = achProgController.achProgress.speed.stageId;
          if(achProgController.achProgress.speed.allCompleted) stageId--;
          _changeCategory(achDataController.achSpeed[stageId],
              achProgController.achProgress.speed, index, "km/h");
          break;
        case 2:
          int stageId = achProgController.achProgress.time.stageId;
          if(achProgController.achProgress.time.allCompleted) stageId--;
          _changeCategory(achDataController.achTime[stageId],
              achProgController.achProgress.time, index, "h");
          break;
        case 3:
          int stageId = achProgController.achProgress.calories.stageId;
          if(achProgController.achProgress.calories.allCompleted) stageId--;
          _changeCategory(achDataController.achCalories[stageId],
              achProgController.achProgress.calories, index, "kcal");
          break;
      }

    }
    else
      _moreInfo.value = false;
  }

  _changeCategory(Achievement achievement, AchProgressEntry progress, int index, String unit) {
    _selectedAchievement.value = achievement;
    _selectedUserProgress.value = progress;
    _acquiredSelectedAchievement.value = false;
    _selectedIndex.value = index;
    _selectedUnit.value = unit;
  }

   _showAchievements() {
    switch (_selectedIndex.value) {
      case 0:
        return _showCatAchievements(achDataController.achDistance, achProgController.achProgress.distance);
      case 1:
        return _showCatAchievements(achDataController.achSpeed, achProgController.achProgress.speed);
      case 2:
        return _showCatAchievements(achDataController.achTime, achProgController.achProgress.time);
      case 3:
        return _showCatAchievements(achDataController.achCalories, achProgController.achProgress.calories);

    }
  }

  _progressAchievement() {

    String percentageProgress;
    String numericalProgress;

    if(_selectedAchievement.value.idAchievement == _selectedUserProgress.value.stageId) {
      percentageProgress = ((_selectedUserProgress.value.progress*100)~/_selectedAchievement.value.goal).toString()+"%";
      if(_selectedUnit.value != "h")
        numericalProgress = formatNumber(_selectedUserProgress.value.progress)+" "+_selectedUnit.value+" / "+formatNumber(_selectedAchievement.value.goal)+" "+_selectedUnit.value;
      else
        numericalProgress= formatNumber(num.parse((_selectedUserProgress.value.progress/3600).toStringAsFixed(1)))+" "+_selectedUnit.value+" / "+formatNumber(num.parse((_selectedAchievement.value.goal/3600).toStringAsFixed(1)))+" "+_selectedUnit.value;
    }
    else if(_selectedAchievement.value.idAchievement > _selectedUserProgress.value.stageId) {
      percentageProgress = "0%";
      if(_selectedUnit.value != "h")
        numericalProgress = "0 "+_selectedUnit.value+" / "+ formatNumber(_selectedAchievement.value.goal)+" "+_selectedUnit.value;
      else
        numericalProgress = "0 "+_selectedUnit.value+" / "+ formatNumber(num.parse((_selectedAchievement.value.goal/3600).toStringAsFixed(1)))+" "+_selectedUnit.value;
    }
    else {
      percentageProgress = "100%";
      if(_selectedUnit.value != "h")
        numericalProgress = formatNumber(_selectedAchievement.value.goal)+" "+_selectedUnit.value+ " / "+ formatNumber(_selectedAchievement.value.goal)+" "+_selectedUnit.value;
      else
        numericalProgress =  formatNumber(num.parse((_selectedAchievement.value.goal/3600).toStringAsFixed(1)))+" "+_selectedUnit.value +" / "+ formatNumber(num.parse((_selectedAchievement.value.goal/3600).toStringAsFixed(1)))+" "+_selectedUnit.value;
    }


      return Column(children: [
        Text(
          percentageProgress,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),

        ),
        Text(
          numericalProgress,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
      ]);

  }

  Future<void> dataLoading() async {
    await achProgController.fetchFuture;
    await achDataController.fetchFuture;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Osiągnięcia'),
      ),
      body: Center(
        child: FutureHandler(
          future: dataLoading(),
          onNotDone: () => Container(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              )),
          onDone: () => Obx(() => Stack(
                children: [
                  _showAchievements(),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          border:  Border(
                            top: BorderSide( //                   <--- left side
                              color: _moreInfo.value ? Color(0xff192026): Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        child: AnimatedSize(
                          curve: Curves.fastLinearToSlowEaseIn,
                          duration: const Duration(seconds: 1),
                          child: Container(
                            height: _moreInfo.value ? 300 : 0,
                            child: Column(
                              children: [
                                Container(
                                    color: Color(0xff263238),
                                    child: InkWell(
                                        onTap: () {
                                          _moreInfo.value = false;
                                        },
                                        child: Row(children: [
                                          Icon(
                                            _acquiredSelectedAchievement.value
                                                ? Icons.emoji_events_rounded
                                                : Icons.emoji_events_outlined,
                                            size: 50,
                                            color: Colors.amber[200],
                                          ),
                                          Flexible(
                                            child: Container(
                                              padding: EdgeInsets.all(10.0),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                    _selectedAchievement
                                                        .value.name,
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff9AB6C4),
                                                    )),
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ]))),
                                SizedBox(height: 5),
                                Text(
                                  "Cel:",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[200],
                                  ),

                                ),
                                SizedBox(height: 5),
                                Text(
                                  _selectedAchievement.value.description,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:Colors.white,
                                  ),
                                ),
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Postęp:",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber[200],
                                        )),
                                    SizedBox(height: 5),
                                    _progressAchievement(),
                                  ],
                                )),
                                _selectedAchievement.value.idAchievement < _selectedUserProgress.value.stageId ?
                                Column(children:[
                                  Text(
                                  _selectedAchievement.value.comment,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xff9AB6C4),
                                  ),
                                  textAlign: TextAlign.center,
                                  ),
                                SizedBox(height: 5),
                                ]) : Container(),
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              )),
        ),

      ),
      drawer: CustomDrawer(),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bike_rounded),
              label: 'Dystans',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.speed_rounded),
              label: 'Prędkość',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              label: 'Czas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department),
              label: 'Kalorie',
            ),
          ],
          currentIndex: _selectedIndex.value,
          selectedItemColor: Colors.amber[200],
          selectedFontSize: 16,
          unselectedFontSize: 14,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  _showCatAchievements(List<Achievement> achievementData,AchProgressEntry achievementProgress) {
    return     ListView(
        children: [
          achievementProgress.allCompleted ? _completedAchievements() :
    _currentAchievement(

        achievementData[achievementProgress.stageId], achievementProgress),
    SizedBox(height: 20),
    for (int i = achievementProgress.stageId+1; i < achievementData.length; i++)
        ...[
          _achievement(achievementData[i], achievementProgress, false),
        ],
    for (int i = achievementProgress.stageId-1; i >= 0; i--)
        ...[
          _achievement(achievementData[i], achievementProgress, true),
        ],

    ]);
  }

  _currentAchievement(Achievement achievementData,AchProgressEntry achievementProgress) {
    return Container(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(),
        elevation: 6,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                child: Align(
                  alignment: Alignment.center,
                  child: Text("Aktualne",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[200],
                      )),
                ),
              ),
              SizedBox(height: 10.0),

      InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (_moreInfo.value) {
                    if (_selectedAchievement.value != achievementData) {
                      _selectedAchievement.value = achievementData;
                      _selectedUserProgress.value = achievementProgress;
                      _acquiredSelectedAchievement.value = false;
                    } else
                      _moreInfo.value = !_moreInfo.value;
                  } else {
                    _selectedAchievement.value = achievementData;
                    _selectedUserProgress.value = achievementProgress;
                    _acquiredSelectedAchievement.value = false;
                    _moreInfo.value = !_moreInfo.value;
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff28516E),
                      border: Border.all(
                        color: Colors.amber[200],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(children: [
                    Container(
                      child: Icon(Icons.emoji_events_outlined,
                          size: 50, color: Colors.amber[200]),
                    ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(achievementData.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[200],
                              )),
                        ),
                      ),
                    ),
                    Container(
                      child: Icon(Icons.emoji_events_outlined,
                          size: 50, color: Colors.amber[200]),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _completedAchievements() {
    return Container(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(),
        elevation: 6,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                child: Align(
                  alignment: Alignment.center,
                  child: Text("Ukończono kategorię",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[200],
                      )),
                ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  _achievement(Achievement achievementData,AchProgressEntry achievementProgress,bool acquired) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(5.0),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              if (_moreInfo.value) {
                if (_selectedAchievement.value != achievementData) {
                  _selectedAchievement.value = achievementData;
                  _selectedUserProgress.value = achievementProgress;
                  _acquiredSelectedAchievement.value = acquired;
                } else
                  _moreInfo.value = !_moreInfo.value;
              } else {
                _selectedAchievement.value = achievementData;
                _selectedUserProgress.value = achievementProgress;
                _acquiredSelectedAchievement.value = acquired;
                _moreInfo.value = !_moreInfo.value;
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xff27323a),
                  border: Border.all(
                    color: Color(0xff13181C),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10))),

              margin: EdgeInsets.zero,
              // shape: RoundedRectangleBorder(),
              //elevation: 6,

              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Container(
                      child: Row(children: [
                        Container(
                          child: Icon(
                              acquired
                                  ? Icons.emoji_events_rounded
                                  : Icons.emoji_events_outlined,
                              size: 35,
                              color: Colors.amber[200],),
                        ),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(achievementData.name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff9AB6C4),
                                  )),
                            ),
                          ),
                        ),
                        acquired
                            ? Container(
                                child: Icon(Icons.done_all_sharp,
                                    size: 35, color: Color(0xff042104)),
                              )
                            : Container(
                                child: Icon(Icons.lock_rounded,
                                    size: 35, color: Color(0xff290C0B)),
                              ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

