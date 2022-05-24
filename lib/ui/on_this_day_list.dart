import 'package:flutter/material.dart';
import 'package:life_events/ui/on_this_day_detail.dart';
import 'package:life_events/model/on_this_day.dart';
import 'package:life_events/model/colours.dart';

class OnThisDayList extends StatelessWidget {

  final OnThisDay otd;
  final String leDate;
  final int otdType;

  OnThisDayList(this.otd, this.leDate, this.otdType);

  @override
  Widget build(BuildContext context) {

    String otdTypeLabel = "Events";
    switch (otdType) {
      case OnThisDay.typeBirth: {
        otdTypeLabel = "Births";
      } break;
      case OnThisDay.typeDeath: {
        otdTypeLabel = "Deaths";
      } break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(otdTypeLabel + ' (' + leDate + ')'),
        backgroundColor: AppColours.appBackgroundColour,
        actions: [
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      ),
      body: _buildOnThisDay(),
    );
  }

  Widget _buildOnThisDay() {

    return FutureBuilder(
        future: otd.getEvents(0, otdType),
        builder: (context, onThisDaySnap) {
          if (onThisDaySnap.connectionState == ConnectionState.waiting) {
            return Container(child: CircularProgressIndicator());
          }
          return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(8.0),
              itemCount: onThisDaySnap.data.length,
              itemBuilder: /*1*/ (context, index) {
                Event event = onThisDaySnap.data.elementAt(index);
                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: event.year,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    event.description,
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => OnThisDayDetail(event, otdType)));
                  },
                );
              });
        });
  }
}
