import 'package:flutter/material.dart';
import 'package:flutter_projekt_inzynierka/controllers/tracks_controller.dart';
import 'package:flutter_projekt_inzynierka/data/track_data.dart';
import 'package:flutter_projekt_inzynierka/widgets/future_handler.dart';
import 'package:flutter_projekt_inzynierka/widgets/scaffold.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Tracks extends StatelessWidget {
  final tracksController = Get.put(TracksController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    SizedBox marginBox = SizedBox(height: 16);
    return CustomScaffold(
      appBar: AppBar(
        title: Text('Trasy'),
      ),
      body: FutureHandler(
        future: tracksController.fetchFuture,
        onDone: () => Obx(
              () => ListView(
            children: [
              for (var track in tracksController.tracks) ...[
                _Tracks(tracks: track),
                marginBox,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Tracks extends StatelessWidget {
  _Tracks({
    @required this.tracks,
  });

  final TrackData tracks;
  final _numberFormatter = NumberFormat('0.0');

  String formatNumber(num number) => _numberFormatter.format(number);

  @override
  Widget build(BuildContext context) {
    SizedBox marginBox = SizedBox(height: 16);

    return InkWell(
      onTap: (){
        Get.toNamed("/track", arguments: tracks);
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
                      message: tracks.name,
                      child: Text(
                        tracks.name,
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
                          TextSpan(text: formatNumber(tracks.distance), style: TextStyle(fontSize: 20)),
                          TextSpan(text: " km", style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                tracks.difficult),

              SizedBox(height: 24),
              Row(
                children: [

                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.golf_course, color: Theme.of(context).accentColor),
                        SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: tracks.start, style: TextStyle(fontSize: 16)),

                            ],
                          ),
                          textAlign: TextAlign.center, ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.timer, color: Theme.of(context).accentColor),
                        SizedBox(height: 4),
                        Text(tracks.time,textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.golf_course, color: Theme.of(context).accentColor),
                        SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text:tracks.finish, style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          textAlign: TextAlign.center,),
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
