import 'package:flutter/material.dart';
import 'package:life_events/model/database_helper.dart';
import 'package:life_events/model/lifeevent.dart';
import 'package:life_events/model/strings.dart';
import 'package:life_events/model/on_this_day.dart';
import 'package:life_events/model/colours.dart';
import 'package:life_events/ui/detail_screen.dart';
import 'package:life_events/ui/form.dart';
import 'package:life_events/ui/help.dart';
import 'package:life_events/ui/export.dart';
import 'package:life_events/ui/import.dart';
import 'package:flutter_icons/flutter_icons.dart';

class LifeEvents extends StatefulWidget {
  @override
  _LifeEventsState createState() => _LifeEventsState();
}

class _LifeEventsState extends State<LifeEvents> {
  //Get the database lazily.
  final dbHelper = DatabaseHelper.instance;

  //Sort Descending by default.
  var sortMethod = DatabaseHelper.sortDesc;

  //Grab all types by default.
  int currFilter = LifeEvent.typeAll;

  @override
  Widget build(BuildContext context) {
    //Build the database with some dummy entries.
    //_insertDummyRows();
    //clearDatabase();
    //_body = _buildLifeEvents();

    double cWidth = MediaQuery.of(context).size.width * 0.9;

    Icon filter = Icon(Icons.filter_alt_outlined);

    if (currFilter != LifeEvent.typeAll) {
      filter = Icon(Icons.filter_alt_outlined, color: Colors.yellow);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColours.appBackgroundColour,
        title: Text(AppStrings.appTitle),
        actions: [
          IconButton(
              icon: Icon(Icons.arrow_circle_up_outlined),
              onPressed: _pushSortAsc),
          IconButton(
              icon: Icon(Icons.arrow_circle_down_outlined),
              onPressed: _pushSortDesc),
          IconButton(icon: filter, onPressed: _showFilterDialog),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              margin: EdgeInsets.all(0),
              child: Column(children: [
                Image(
                  image: AssetImage('images/stepping_stones_no_border.png'),
                ),
                SizedBox(height: 12),
                Container(
                  child: Text("Life Events",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  padding: EdgeInsets.all(5),
                ),
              ]),
              decoration: BoxDecoration(color: AppColours.appBackgroundColour),
              padding: EdgeInsets.all(0),
            ),
            Container(
              padding: EdgeInsets.all(10),
              width: cWidth,
              child: Column(children: [
                Flexible(
                    flex: 0,
                    child: Text(
                        "Record the things that matter most, and see what happened on the same day in history!",
                        style: TextStyle(color: Colors.black, fontSize: 14))),
              ]),
            ),
            ListTile(
              leading: Icon(FlutterIcons.md_save_ion),
              title: Text('Export your life events'),
              onTap: _pushExport,
            ),
            ListTile(
              leading: Icon(FlutterIcons.md_cloud_upload_ion),
              title: Text('Import some life events'),
              onTap: _pushImport,
            ),
            ListTile(
              leading: Icon(FlutterIcons.md_help_circle_outline_ion),
              title: Text('Help'),
              onTap: _pushHelp,
            ),
          ],
        ),
      ),
      body: _buildLifeEvents(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LifeEventForm(lifeEvent: null, editMode: false)));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  /*
  void clearDatabase() async {
    int id;
    id = await dbHelper.delete(1);
    id = await dbHelper.delete(2);
    id = await dbHelper.delete(3);
    id = await dbHelper.delete(4);
    id = await dbHelper.delete(5);
  }
   */

  Future<bool> firstRun() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    int rowCount = await dbHelper.queryRowCount();
    if (rowCount == 0) {
      //Nothing in there yet. Create one!
      Map<String, dynamic> row = {
        DatabaseHelper.columnName: "Started using Life Events",
        DatabaseHelper.columnDetails:
            "The happy day that I started using this excellent app to record my life events.",
        DatabaseHelper.columnTheDay: DateTime.now().toString(),
        DatabaseHelper.columnType: LifeEvent.typePersonal,
        DatabaseHelper.columnRelated: 0
      };
      int id = await dbHelper.insert(row);
      print('Initial data inserted. Row id: $id');
      return true;
    } else {
      return false;
    }
  }

  Widget _buildLifeEvents() {
    Widget _waiting = Container(
        alignment: Alignment.center, child: CircularProgressIndicator());
    return FutureBuilder(
        future: dbHelper.getAlllifeEvents(sortMethod, currFilter),
        builder: (context, lifeEventsSnap) {
          if (lifeEventsSnap.connectionState == ConnectionState.waiting) {
            return _waiting;
          }
          if (lifeEventsSnap.data.length == 0) {
            firstRun().then((value) {
              if (value) {
                setState(() {
                  //Nothing to do here
                });
              }
            });
          }
          return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: lifeEventsSnap.data.length,
              itemBuilder: /*1*/ (context, index) {
                LifeEvent le = lifeEventsSnap.data.elementAt(index);
                IconData iconData = LifeEvent.getTypeIcon(le.type);
                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: le.getFormattedDate(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: " - "),
                        TextSpan(text: le.name),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    le.details,
                  ),
                  trailing: IconButton(
                    icon: Icon(iconData),
                  ),
                  onTap: () {
                    OnThisDay otd = new OnThisDay(le.getMonth(), le.getDay());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LifeEventDetailScreen(lifeEvent: le, otd: otd)),
                    );
                  },
                  }
                );
              });
        });
  }

  void _pushHelp() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HelpPage()));
  }

  void _pushExport() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ExportPage()));
  }

  void _pushImport() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ImportPage()));
  }

  void _pushSortAsc() {
    sortMethod = DatabaseHelper.sortAsc;
    this.setState(() {});
  }

  void _pushSortDesc() {
    sortMethod = DatabaseHelper.sortDesc;
    this.setState(() {});
  }

  _showFilterDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose the type to filter on.',
                style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextButton.icon(
                      label: Text(AppStrings.typeAll),
                      //style: ButtonStyle(alignment: Alignment.centerLeft),
                      icon: Icon(LifeEvent.getTypeIcon(LifeEvent.typeAll)),
                      onPressed: () {
                        currFilter = LifeEvent.typeAll;
                        this.setState(() {});
                        Navigator.of(context).pop();
                      }),
                  TextButton.icon(
                      label: Text(AppStrings.typeBirth),
                      icon: Icon(LifeEvent.getTypeIcon(LifeEvent.typeBday)),
                      onPressed: () {
                        currFilter = LifeEvent.typeBday;
                        this.setState(() {});
                        Navigator.of(context).pop();
                      }),
                  TextButton.icon(
                      label: Text(AppStrings.typeDeath),
                      icon: Icon(LifeEvent.getTypeIcon(LifeEvent.typeDeath)),
                      onPressed: () {
                        currFilter = LifeEvent.typeDeath;
                        this.setState(() {});
                        Navigator.pop(context);
                      }),
                  TextButton.icon(
                      label: Text(AppStrings.typePersonal),
                      icon: Icon(LifeEvent.getTypeIcon(LifeEvent.typePersonal)),
                      onPressed: () {
                        currFilter = LifeEvent.typePersonal;
                        this.setState(() {});
                        Navigator.pop(context);
                      }),
                  TextButton.icon(
                      label: Text(AppStrings.typePurchase),
                      icon: Icon(LifeEvent.getTypeIcon(LifeEvent.typePurchase)),
                      onPressed: () {
                        currFilter = LifeEvent.typePurchase;
                        this.setState(() {});
                        Navigator.pop(context);
                      }),
                  TextButton.icon(
                      label: Text(AppStrings.typeWork),
                      icon: Icon(LifeEvent.getTypeIcon(LifeEvent.typeWork)),
                      onPressed: () {
                        currFilter = LifeEvent.typeWork;
                        this.setState(() {});
                        Navigator.pop(context);
                      }),
                ],
              ),
            ),
          );
        });
  }
}
