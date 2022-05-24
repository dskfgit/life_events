import 'package:flutter/material.dart';
import 'package:life_events/model/on_this_day.dart';
import 'package:url_launcher/url_launcher.dart' as Launch;
import 'package:life_events/model/colours.dart';

class OnThisDayDetail extends StatelessWidget {
  final Event event;
  final int otdType;

  OnThisDayDetail(this.event, this.otdType);

  @override
  Widget build(BuildContext context) {
    String otdTypeLabel = "Event";
    IconData iconData = Icons.event_outlined;
    switch (otdType) {
      case OnThisDay.typeBirth:
        {
          otdTypeLabel = "Birth";
          iconData = Icons.child_friendly_outlined;
        }
        break;
      case OnThisDay.typeDeath:
        {
          otdTypeLabel = "Death";
          iconData = Icons.hourglass_bottom_outlined;
        }
        break;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(otdTypeLabel + ' on this day'),
          backgroundColor: AppColours.appBackgroundColour,
          actions: [
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              iconData,
              size: 100,
            ),
            SizedBox(width: 100, height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 40.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                text: event.year,
              ),
            ),
            SizedBox(width: 100, height: 20),
            SizedBox(width: 100, height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                text: event.description,
              ),
            ),
            SizedBox(width: 100, height: 20),
            _buildWikipedias(),
          ]),
        ));
  }

  Widget _buildWikipedias() {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(8.0),
        itemCount: event.wikipedia.length,
        itemBuilder: (context, index) {
          Wikipedia wikipedia = event.wikipedia.elementAt(index);
          return ListTile(
            title: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: wikipedia.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            subtitle: InkWell(
              child: Text(
                wikipedia.wikipedia,
              ),
              onTap: () {
                _launchURL(wikipedia.wikipedia);
              },
            ),
            onTap: () {},
          );
        });
  }

  void _launchURL(String url) async {
    //await Launch.canLaunch(url) ? await Launch.launch(url) : throw 'Could not launch $url';
    await Launch.canLaunchUrl(Uri.parse(url)) ? await Launch.launchUrl(Uri.parse(url)) : throw 'Could not launch $url';
  }

}
