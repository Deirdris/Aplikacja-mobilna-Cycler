import 'package:flutter/material.dart';
import 'package:flutter_projekt_inzynierka/controllers/stats_controller.dart';
import 'package:flutter_projekt_inzynierka/data/stats_data.dart';
import 'package:flutter_projekt_inzynierka/methods/format_number.dart';
import 'package:flutter_projekt_inzynierka/widgets/future_handler.dart';
import 'package:flutter_projekt_inzynierka/widgets/scaffold.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class _StatsRow extends StatelessWidget {
  _StatsRow({
    Key key,
    @required this.value,
    this.valueUnit,
    @required this.icon,
    this.iconDesc,
    @required this.globalValue,
  }) : super(key: key);

  final num value;
  final String valueUnit;
  final IconData icon;
  final String iconDesc;
  final num globalValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: SizedBox.shrink(),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: formatNumber(value), style: TextStyle(fontSize: 16)),
                          if (valueUnit != null)
                            TextSpan(text: ' $valueUnit', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(icon, color: Theme.of(context).accentColor),
                            alignment: PlaceholderAlignment.middle,
                          ),
                          // if (iconDesc != null)
                          //   TextSpan(text: ' $iconDesc', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: formatNumber(globalValue), style: TextStyle(fontSize: 16)),
                          if (valueUnit != null)
                            TextSpan(text: ' $valueUnit', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (iconDesc != null)
                  Text('$iconDesc', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  final StatsController statsController = Get.find<StatsController>();

  final monthView = true.obs;

  final ifMonth = true.obs;

  final DateTime now = DateTime.now();

  Stats get stats => statsController.stats;
  StatsEntry get statType => ifMonth() ? stats.monthlyStats : stats.weeklyStats;

  @override
  Widget build(BuildContext context) {
    final int weekDate1 = DateTime(now.year, now.month, now.day - (now.weekday - 1)).day;
    final int weekDate2 = DateTime(now.year, now.month, now.day - now.weekday + 7).day;
    return Theme(
      data: Theme.of(context).copyWith(
        // scaffoldBackgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        cardTheme: Theme.of(context)
            .cardTheme
            .copyWith(margin: const EdgeInsets.only(bottom: 16), shape: RoundedRectangleBorder()),
      ),
      child: CustomScaffold(
        appBar: AppBar(
          title: Text('Statystyki'),
        ),
        body: FutureHandler(
          future: statsController.fetchFuture,
          onDone: () => Obx(
                () => Column(
              children: [
                SizedBox(
                  height: 36,
                ),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(12),
                  borderColor: Theme.of(context).hintColor,
                  selectedBorderColor: Theme.of(context).accentColor,
                  selectedColor: Theme.of(context).accentColor,
                  color: Theme.of(context).hintColor,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        '01 ${DateFormat('LLL').format(DateTime.now())} – ${DateTime(now.year, now.month + 1, 0).day} ${DateFormat('LLL').format(DateTime.now())}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        '$weekDate1 ${DateFormat('LLL').format(DateTime.now())} – $weekDate2 ${(weekDate1 < weekDate2) ? DateFormat('LLL').format(DateTime.now()) : DateFormat('LLL').format(DateTime(now.year, now.month + 1))}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                  onPressed: (int index) {
                    monthView.value = index == 0;
                    ifMonth.value = !ifMonth.value;
                  },
                  isSelected: [monthView(), !monthView()],
                ),
                SizedBox(
                  height: 36,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'Okresowe',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'Globalne',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: _StatsRow(
                    value: statType.averageVelocity,
                    valueUnit: 'km/h',
                    icon: Icons.speed,
                    iconDesc: 'śr.',
                    globalValue: stats.globalStats.averageVelocity,
                  ),
                ),
                Expanded(
                  child: _StatsRow(
                    value: statType.highestVelocity,
                    valueUnit: 'km/h',
                    icon: Icons.speed,
                    iconDesc: 'maks.',
                    globalValue: stats.globalStats.highestVelocity,
                  ),
                ),
                Expanded(
                  child: _StatsRow(
                    value: statType.overallDuration >= 60 ? (statType.overallDuration / 60) : statType.overallDuration,
                    valueUnit: statType.overallDuration >= 60 ? 'min' : 's',
                    icon: Icons.timer,
                    globalValue: stats.globalStats.overallDuration,
                  ),
                ),
                Expanded(
                  child: _StatsRow(
                    value: statType.overallDistance,
                    valueUnit: 'km',
                    icon: Icons.directions_bike,
                    globalValue: stats.globalStats.overallDistance,
                  ),
                ),
                Expanded(
                  child: _StatsRow(
                    value: statType.allBurnedCalories,
                    valueUnit: 'kcal',
                    icon: Icons.local_fire_department,
                    globalValue: stats.globalStats.allBurnedCalories,
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