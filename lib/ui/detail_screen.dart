import 'dart:async';
import 'package:flutter/material.dart';
import 'package:life_events/model/database_helper.dart';
import 'package:life_events/model/lifeevent.dart';
import 'package:life_events/model/colours.dart';
import 'package:life_events/model/strings.dart';
import 'package:life_events/ui/list.dart';
import 'package:life_events/ui/dialogs.dart';
import 'package:life_events/ui/form.dart';
import 'package:life_events/model/on_this_day.dart';
import 'package:life_events/ui/on_this_day_detail.dart';
import 'package:life_events/ui/on_this_day_list.dart';

class LifeEventDetailScreen extends StatelessWidget {
  final LifeEvent lifeEvent;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final OnThisDay otd;

  LifeEventDetailScreen({Key key, @required this.lifeEvent, @required this.otd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final double cWidth = MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      appBar: AppBar(
          title: Text("Life Event: " + lifeEvent.getFormattedDate()),
          backgroundColor: AppColours.appBackgroundColour,
          actions: [
            IconButton(
                icon: Icon(Icons.delete_forever_outlined),
                onPressed: () {
                  showCustomDialog(context, "Delete this Life Event?",
                          "Do you want to delete this Life Event?")
                      .then((val) {
                    if (val) {
                      _pushDeleteLifeEvent(lifeEvent.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LifeEvents(),
                        ),
                      );
                    }
                  });
                }),
            IconButton(
                icon: Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LifeEventForm(lifeEvent: lifeEvent, editMode: true),
                    ),
                  );
                }),
          ]),
      bottomNavigationBar: _buildBottomNav(context),
      body: Container(
        padding: const EdgeInsets.all(0),
        alignment: Alignment.center,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image(
            image: AssetImage('images/stepping_stones_banner.png'),
          ),
          SizedBox(height: 8),
          Icon(
            LifeEvent.getTypeIcon(lifeEvent.type),
            size: 70,
          ),
          SizedBox(width: 100, height: 10),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 32.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              text: lifeEvent.getFormattedDate(),
            ),
          ),
          SizedBox(width: 100, height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.black,
              ),
              text: lifeEvent.name,
            ),
          ),
          SizedBox(width: 100, height: 12),
          Padding(
            child:
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.black,
              ),
              text: lifeEvent.details,
            ),
          ),
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          ),
          SizedBox(width: 100, height: 12),
          Divider(
            height: 1,
            color: Colors.black,
          ),
          SizedBox(width: 100, height: 6),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 19.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              text: AppStrings.appLabelDetailScreenOTD,
            ),
          ),
          SizedBox(width: 100, height: 6),
          //Expanded(child:
          _buildOnThisDay(),
          //flex: 1),
          SizedBox(width: 100, height: 6),

        ]),
      ),
    );
  }

  Future<int> _pushDeleteLifeEvent(int _id) async {
    int id = await dbHelper.delete(_id);
    return id;
  }

  Widget _buildOnThisDay() {
    int type = OnThisDay.typeEvent;
    switch (lifeEvent.type) {
      case LifeEvent.typeBday:
        {
          type = OnThisDay.typeBirth;
        }
        break;
      case LifeEvent.typeDeath:
        {
          type = OnThisDay.typeDeath;
        }
        break;
    }
    return FutureBuilder(
        future: otd.getEvents(3, type),
        builder: (context, onThisDaySnap) {
          if (onThisDaySnap.connectionState == ConnectionState.waiting) {
            return Container(child: CircularProgressIndicator());
          }
          if (onThisDaySnap.data == null) {
            return Container(
                child: Text(
                    "Cannot get the On this Day information! Are you online?"));
          }
          return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(8.0),
              itemCount: onThisDaySnap.data.length,
              itemBuilder: (context, index) {
                Event event = onThisDaySnap.data.elementAt(index);
                return ListTile(
                  isThreeLine: true,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OnThisDayDetail(event, type)),
                    );
                  },
                );
              });
        });
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedIconTheme: IconThemeData(color: Colors.white),
      selectedItemColor: Colors.white,
      unselectedIconTheme: IconThemeData(color: Colors.white),
      unselectedItemColor: Colors.white,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          label: "Events",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.child_friendly_outlined),
          label: "Births",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.hourglass_bottom_outlined),
          label: "Deaths",
        ),
      ],
      onTap: (int index) {
        switch (index) {
          case 0:
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OnThisDayList(otd,
                          lifeEvent.getFormattedDate(), OnThisDay.typeEvent)));
            }
            break;
          case 1:
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OnThisDayList(otd,
                          lifeEvent.getFormattedDate(), OnThisDay.typeBirth)));
            }
            break;
          case 2:
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OnThisDayList(otd,
                          lifeEvent.getFormattedDate(), OnThisDay.typeDeath)));
            }
            break;
        }
      },
    );
  }
}
