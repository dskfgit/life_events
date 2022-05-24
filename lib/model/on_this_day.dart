import 'dart:convert';
import 'package:http/http.dart' as http;

class OnThisDay {

  static const int typeEvent = 0;
  static const int typeBirth = 1;
  static const int typeDeath = 2;

  String month;
  String day;

  OnThisDay(String month, String day) {
    this.month = month;
    this.day = day;
  }

  Future<List<Event>> getEvents(int max, int type) async {

    String eventType = "events.json";
    String eventCollection = "events";
    switch (type) {
      case OnThisDay.typeBirth: {
        eventType = "births.json";
        eventCollection = "births";
    } break;
      case OnThisDay.typeDeath: {
        eventType = "deaths.json";
        eventCollection = "deaths";
      } break;
    }

    http.Response response;
    response = await (http.get(Uri.https('byabbe.se',
        '/on-this-day/' + month + '/' + day + '/' + eventType)));

    if(response.statusCode != 200) {
      return getErrorEvent("Unexpected error getting events (status code: " + response.statusCode.toString() + ")");
    }

    final Map<String, dynamic> maps = jsonDecode(response.body);
    final List<dynamic> events = maps[eventCollection];

    List<Event> theEvents = List.generate(events.length, (i) {
      return Event(
          events[i]['year'],
          events[i]['description'],
          List.generate(events[i]['wikipedia'].length, (j) {
            return Wikipedia(events[i]['wikipedia'][j]['title'],
                events[i]['wikipedia'][j]['wikipedia']);
          }));
    });
    if (max > 0) {
      //Get them from the end.
      int totalSize = theEvents.length;
      if (max > totalSize) {
        max = totalSize;
      }
      return theEvents.sublist((theEvents.length - max), theEvents.length);
    } else {
      return theEvents;
    }
  }

  List<Event> getErrorEvent(String errorMessage) {
    List<Event> theEvents = List.generate(1, (i) {
      return Event(
          "0000",
          errorMessage,
          List.generate(1, (j) {
            return Wikipedia("Error!", "Error!");
          }));
    });
    return theEvents;
  }
}

class Event {
  final String year;
  final String description;
  final List<Wikipedia> wikipedia;

  Event(this.year, this.description, this.wikipedia);
}

class Wikipedia {
  final String title;
  final String wikipedia;
  Wikipedia(this.title, this.wikipedia);
}
