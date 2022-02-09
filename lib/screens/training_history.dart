import 'package:flutter/material.dart';
import 'package:flutter_projekt_inzynierka/controllers/trainings_controller.dart';
import 'package:flutter_projekt_inzynierka/data/training_data.dart';
import 'package:flutter_projekt_inzynierka/methods/format_number.dart';
import 'package:flutter_projekt_inzynierka/widgets/future_handler.dart';
import 'package:flutter_projekt_inzynierka/widgets/scaffold.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TrainingHistory extends StatelessWidget {
  final trainingsController = Get.put(TrainingsController(), permanent: true);

  final isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    SizedBox marginBox = SizedBox(height: 16);
    return CustomScaffold(
      appBar: AppBar(
        title: Text('Historia treningów'),
      ),
      body: FutureHandler(
        future: trainingsController.fetchFuture,
        onDone: () => Obx(
          () => NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 20) {
                  isLoading.value = true;
                  trainingsController.loadNext().whenComplete(() => isLoading.value = false);
                }
              }
              return false;
            },
            child: ListView(
              children: [
                for (var training in trainingsController.trainings) ...[
                  _Training(training: training),
                  marginBox,
                ],
                if (isLoading.value) ...[
                  Center(child: CircularProgressIndicator(color: Theme.of(context).cardColor)),
                  marginBox,
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Training extends StatelessWidget {
  _Training({
    @required this.training,
  });

  final Training training;

  @override
  Widget build(BuildContext context) {
    SizedBox marginBox = SizedBox(height: 16);

    return InkWell(
      onTap: () {
        Get.toNamed("/moreInfo", arguments: training);
      },
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Tooltip(
                      message: training.name,
                      child: Text(
                        training.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: formatNumber(training.distance), style: TextStyle(fontSize: 20)),
                          TextSpan(text: " km", style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                DateFormat("dd LLL yyyy, HH:mm").format(training.dateEnd),
                textAlign: TextAlign.right,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.timer, color: Theme.of(context).accentColor),
                        SizedBox(height: 4),
                        Text(training.duration),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.speed, color: Theme.of(context).accentColor),
                        SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: formatNumber(training.averageVelocity), style: TextStyle(fontSize: 16)),
                              TextSpan(
                                  text: " km/h", style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.local_fire_department, color: Theme.of(context).accentColor),
                        SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: formatNumber(training.calories), style: TextStyle(fontSize: 16)),
                              TextSpan(
                                  text: " kcal", style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                            ],
                          ),
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
    );
  }
}