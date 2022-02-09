import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/scaffold.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackPage extends StatelessWidget {

  final textColor = Color.fromRGBO(255, 255, 225, 1);

  _launchURL() async {
    String url = Get.arguments.url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildTrackData(String data) {
    return Column(children: <Widget>[
      Align(
        alignment: Alignment.center,
        child:
        Text(
          data,
          style: TextStyle(color: textColor, fontSize: 15),
          textAlign: TextAlign.justify,
        ),
      ),
      SizedBox(height: 10),
      Divider(color: Colors.black),
      SizedBox(height: 10),
    ]);
  }

  Widget _webButton(String nameButton) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 40),
      ),
      child: Text(
        nameButton,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
        ),
      ),
      onPressed: () {
        _launchURL();
      },
    );
  }
  
  Widget _buildPhoto() {
    return Column(children: <Widget>[
      CachedNetworkImage(
        imageUrl: Get.arguments.photoUrl,
        imageBuilder: (context, imageProvider) => Container(
          width: 400,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),

          ),
        ),
        placeholder: (context, url) =>  Container(
            width: 200, height: 200, child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>  Container(
            width: 200, height: 200, child: Icon(Icons.error)),
      ),
      SizedBox(height: 15),

    ]);
  }
  Widget _buildTrackInformation(BuildContext context) {
      return Column(
        children: <Widget>[

          _buildPhoto(),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Icon(Icons.timer,color : Theme.of(context).accentColor),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: Get.arguments.time,
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Icon(Icons.directions_bike,color : Theme.of(context).accentColor),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: Get.arguments.distance.toString(), style: TextStyle(fontSize: 16)),
                            TextSpan(
                                text: " km",
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Icon(Icons.bolt,color : Theme.of(context).accentColor),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: Get.arguments.difficult, style: TextStyle(fontSize: 16)),
                            ],
                        ),
                        textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Icon(Icons.golf_course,color : Theme.of(context).accentColor),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: Get.arguments.start,
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Icon(Icons.compare_arrows,color : Theme.of(context).accentColor),
                      SizedBox(height: 4),

                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Icon(Icons.golf_course,color : Theme.of(context).accentColor),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: Get.arguments.finish, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 30,
          ),
          _buildTrackData("Opis: " + Get.arguments.description),
          if(!Get.arguments.url.isEmpty)
            _webButton("Strona Internetowa"),


        ],
      );
  }
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        appBar: AppBar(
          title: Text(Get.arguments.name),
        ),
        body:  SingleChildScrollView(
              child: Container(
                  margin:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: _buildTrackInformation(context))),
        );
  }
}